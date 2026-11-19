import Combine
import Foundation

/// Serializable player save payload persisted locally via `UserDefaults`.
struct PlayerProfile: Codable, Equatable, Sendable {
    var gold: Int
    var diamonds: Int
    var rankPoints: Int
    var ownedSkinIds: Set<String>
    var equippedSkinId: String
    var completedCountryIds: Set<String>
    var dailyMissions: DailyMissionState
    var bestPercentage: Double
    var totalKills: Int
    var matchesPlayed: Int
    var settings: MatchSettings

    static func initial(dayKey: String) -> PlayerProfile {
        PlayerProfile(
            gold: 150,
            diamonds: 25,
            rankPoints: 0,
            ownedSkinIds: [SkinCatalog.starterSkinId],
            equippedSkinId: SkinCatalog.starterSkinId,
            completedCountryIds: [],
            dailyMissions: DailyMissionSystem.generateDailyState(forDayKey: dayKey),
            bestPercentage: 0,
            totalKills: 0,
            matchesPlayed: 0,
            settings: .default
        )
    }
}

/// Central @MainActor profile store managing economy, 10 ranks, daily missions, world map, skins, and chests.
@MainActor
final class PlayerProfileStore: ObservableObject {
    private static let storageKey = "paper_territory_profile_v2"

    @Published private(set) var profile: PlayerProfile
    @Published var latestChestReward: ChestReward?
    @Published var feedbackBanner: String?

    private let defaults: UserDefaults
    private var rng: SeededRandomGenerator

    init(
        defaults: UserDefaults = .standard,
        now: Date = Date(),
        seed: UInt64 = UInt64(Date().timeIntervalSince1970 * 1_000)
    ) {
        self.defaults = defaults
        self.rng = SeededRandomGenerator(seed: seed == 0 ? 0x5041_5045_5239 : seed)

        let todayKey = DailyMissionSystem.dayKey(for: now)
        if let loaded = Self.loadProfile(from: defaults) {
            self.profile = loaded
        } else {
            self.profile = PlayerProfile.initial(dayKey: todayKey)
        }
        ensureDailyMissionsCurrent(now: now)
    }

    var currentRankTier: RankTier {
        RankTier.tier(for: profile.rankPoints)
    }

    var equippedSkin: SkinDefinition {
        SkinCatalog.skin(withId: profile.equippedSkinId)
    }

    func ensureDailyMissionsCurrent(now: Date = Date()) {
        let todayKey = DailyMissionSystem.dayKey(for: now)
        let isStaleDay = profile.dailyMissions.dayKey != todayKey
        let hasWrongCount = profile.dailyMissions.missions.count != GameConfig.dailyMissionCount
        if isStaleDay || hasWrongCount {
            profile.dailyMissions = DailyMissionSystem.generateDailyState(forDayKey: todayKey)
            persist()
        }
    }

    @discardableResult
    func recordMatchOutcome(_ outcome: MatchOutcomeSnapshot, now: Date = Date()) -> MatchRewardBreakdown {
        ensureDailyMissionsCurrent(now: now)

        let grant = processWorldConquestVictory(for: outcome)
        let rawRewards = EconomyCalculator.calculateRewards(
            outcome: outcome,
            currentRankPoints: profile.rankPoints,
            countryBonusGold: grant?.bonusGold ?? 0,
            countryBonusDiamonds: grant?.bonusDiamonds ?? 0
        )

        profile.gold += rawRewards.goldEarned
        profile.diamonds += rawRewards.diamondsEarned
        profile.rankPoints += rawRewards.rankPointsDelta
        profile.matchesPlayed += 1
        profile.totalKills += outcome.kills
        profile.bestPercentage = max(profile.bestPercentage, outcome.peakPercentage)

        DailyMissionSystem.applyMatch(
            outcome,
            conqueredCountry: grant != nil,
            to: &profile.dailyMissions
        )
        persist()

        return MatchRewardBreakdown(
            goldEarned: rawRewards.goldEarned,
            diamondsEarned: rawRewards.diamondsEarned,
            rankPointsDelta: rawRewards.rankPointsDelta,
            previousTier: rawRewards.previousTier,
            newTier: rawRewards.newTier,
            countryConqueredName: grant?.countryName,
            continentUnlockedName: grant?.unlockedContinentName
        )
    }

    @discardableResult
    func claimDailyMissionChest() -> ChestReward? {
        guard profile.dailyMissions.canClaimChest else { return nil }
        let reward = DailyMissionSystem.rollDailyChest(ownedSkinIds: profile.ownedSkinIds, rng: &rng)
        profile.dailyMissions.chestClaimed = true
        applyChestReward(reward)
        return reward
    }

    @discardableResult
    func openHeroChest(_ tier: HeroChestTier) -> ChestReward? {
        guard profile.diamonds >= tier.diamondCost else {
            feedbackBanner = "Not enough Diamonds (\(tier.diamondCost) needed)."
            return nil
        }
        profile.diamonds -= tier.diamondCost
        let reward = HeroChestRoller.roll(tier: tier, ownedSkinIds: profile.ownedSkinIds, rng: &rng)
        applyChestReward(reward)
        return reward
    }

    @discardableResult
    func buySkin(_ skin: SkinDefinition) -> Bool {
        if profile.ownedSkinIds.contains(skin.id) {
            equipSkin(skin.id)
            return true
        }
        switch skin.price {
        case .free:
            profile.ownedSkinIds.insert(skin.id)
            profile.equippedSkinId = skin.id
            persist()
            return true
        case let .gold(cost):
            guard profile.gold >= cost else {
                feedbackBanner = "Not enough Gold (\(cost) needed)."
                return false
            }
            profile.gold -= cost
            profile.ownedSkinIds.insert(skin.id)
            profile.equippedSkinId = skin.id
            feedbackBanner = "Unlocked \(skin.name)!"
            persist()
            return true
        case let .diamonds(cost):
            guard profile.diamonds >= cost else {
                feedbackBanner = "Not enough Diamonds (\(cost) needed)."
                return false
            }
            profile.diamonds -= cost
            profile.ownedSkinIds.insert(skin.id)
            profile.equippedSkinId = skin.id
            feedbackBanner = "Unlocked \(skin.name)!"
            persist()
            return true
        case .realMoney:
            return false
        }
    }

    func equipSkin(_ skinId: String) {
        guard profile.ownedSkinIds.contains(skinId) else { return }
        profile.equippedSkinId = skinId
        persist()
    }

    func fulfillStoreOffer(_ offer: StoreOffer) {
        switch offer.kind {
        case let .goldPack(amount):
            profile.gold += amount
            feedbackBanner = "Added +\(amount) Gold!"
        case let .diamondPack(amount):
            profile.diamonds += amount
            feedbackBanner = "Added +\(amount) Diamonds!"
        case let .skin(skinId):
            profile.ownedSkinIds.insert(skinId)
            profile.equippedSkinId = skinId
            let name = SkinCatalog.skin(withId: skinId).name
            feedbackBanner = "Unlocked \(name)!"
        }
        persist()
    }

    func updateSettings(_ newSettings: MatchSettings) {
        profile.settings = newSettings
        persist()
    }

    private func applyChestReward(_ reward: ChestReward) {
        profile.gold += reward.gold
        profile.diamonds += reward.diamonds
        if let skinId = reward.unlockedSkinId {
            profile.ownedSkinIds.insert(skinId)
            profile.equippedSkinId = skinId
        }
        latestChestReward = reward
        persist()
    }

    private struct WorldConquestGrant {
        let countryName: String
        let bonusGold: Int
        let bonusDiamonds: Int
        let unlockedContinentName: String?
    }

    private func processWorldConquestVictory(for outcome: MatchOutcomeSnapshot) -> WorldConquestGrant? {
        let stage = outcome.countryStageId.flatMap { WorldMapCatalog.country(withId: $0) }
        guard outcome.isVictory, let stage, !profile.completedCountryIds.contains(stage.id) else {
            return nil
        }

        profile.completedCountryIds.insert(stage.id)
        var unlockedName: String?
        if let continent = WorldMapCatalog.continent(withId: stage.continentId) {
            let cleared = WorldMapCatalog.isContinentCompleted(
                continent,
                completedCountryIds: profile.completedCountryIds
            )
            if cleared {
                unlockedName = WorldMapCatalog.nextContinent(after: continent.id)?.name
            }
        }

        return WorldConquestGrant(
            countryName: stage.name,
            bonusGold: stage.rewardGold,
            bonusDiamonds: stage.rewardDiamonds,
            unlockedContinentName: unlockedName
        )
    }

    private static func loadProfile(from defaults: UserDefaults) -> PlayerProfile? {
        guard let data = defaults.data(forKey: storageKey) else { return nil }
        return try? JSONDecoder().decode(PlayerProfile.self, from: data)
    }

    private func persist() {
        guard let encoded = try? JSONEncoder().encode(profile) else { return }
        defaults.set(encoded, forKey: Self.storageKey)
    }
}
