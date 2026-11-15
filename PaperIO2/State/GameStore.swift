import Combine
import Foundation
import SwiftUI

/// Match outcome summary returned when a match finishes.
struct MatchSummary: Identifiable {
    let id = UUID()
    let mode: GameModeType
    let countryName: String?
    let peakTerritoryPercent: Double
    let kills: Int
    let rank: Int
    let coinsEarned: Int
    let gemsEarned: Int
    let isVictory: Bool
    let countryDeltaPercent: Int
}

/// Persistent user state persisted as JSON in UserDefaults.
struct PersistedPlayerState: Codable {
    var playerName: String
    var starScore: Int
    var coins: Int
    var gems: Int
    var equippedSkinId: String
    var unlockedSkinIds: Set<String>
    var heroLevels: [String: Int]
    var heroCards: [String: Int]
    var selectedCountryId: String
    var countryProgress: [String: Int] // 0...100
    var activeMode: GameModeType
    var dailyMissions: [MissionItem]
    var lifetimeMissions: [MissionItem]
    var dailyMilestoneClaimed: Bool
    var loginStreak: Int
    var lastLoginDayStamp: String
    var claimedDailyRewardDays: Set<Int>
    var totalKills: Int
    var chestsOpened: Int
    var powerOrbsUsed: Int
    var powerUpsUsed: Int
    var revivesUsed: Int
    var bestTerritoryPercent: Double
    var matchesPlayed: Int
    var matchesWon: Int
    var soundEnabled: Bool
    var hapticsEnabled: Bool
    var controlSensitivity: Double
    var hasNoAds: Bool
    var freeCardsClaimedToday: Bool
    var freeDroidChestClaimedToday: Bool
    var classicShopSkinBoughtToday: Bool
}

/// Central reactive store driving all menus, progression, economy, missions, and gameplay results.
@MainActor
final class GameStore: ObservableObject {
    @Published var selectedTab: MainTab = .home
    @Published var state: PersistedPlayerState
    @Published var isPlaying: Bool = false
    @Published var startFiveXActive: Bool = false

    // Modal triggers
    @Published var showSkinShowcase: Bool = false
    @Published var showcaseSkinId: String = "wizard"
    @Published var showSettings: Bool = false
    @Published var showModesModal: Bool = false
    @Published var showDailyRewards: Bool = false
    @Published var showProfileModal: Bool = false
    @Published var showNoAdsModal: Bool = false
    @Published var chestReveal: (rarity: ChestRarity, rewards: [ChestRevealReward])? = nil
    @Published var lastMatchSummary: MatchSummary? = nil
    @Published var toastMessage: String? = nil

    // Live countdown for offers/daily reset (e.g. 5h 32m like video)
    @Published var resetRemainingSeconds: Int = 5 * 3600 + 32 * 60

    private let storageKey = "paperio2_ios_state_v1"
    private var timerCancellable: AnyCancellable?

    init() {
        if let raw = UserDefaults.standard.data(forKey: storageKey),
           let decoded = try? JSONDecoder().decode(PersistedPlayerState.self, from: raw) {
            self.state = decoded
        } else {
            self.state = GameStore.createDefaultState()
        }
        syncAudioSettings()
        evaluateMilestoneUnlocks()
        checkDailyLoginStreak()
        startCountdownTimer()
    }

    static func createDefaultState() -> PersistedPlayerState {
        let initialFree = Set(SkinCatalog.all.filter { $0.unlockRule == .free }.map { $0.id })
        return PersistedPlayerState(
            playerName: "PLAYER",
            starScore: 1588,
            coins: 13780,
            gems: 44,
            equippedSkinId: "wizard",
            unlockedSkinIds: initialFree,
            heroLevels: ["hero_cubey": 1],
            heroCards: ["hero_cubey": 1, "hero_droid": 6],
            selectedCountryId: "panama",
            countryProgress: [
                "usa": 100,
                "mexico": 100,
                "colombia": 100,
                "venezuela": 100,
                "peru": 100,
                "panama": 74
            ],
            activeMode: .worldConquest,
            dailyMissions: MissionTemplates.defaultDailyMissions(),
            lifetimeMissions: MissionTemplates.defaultLifetimeMissions(),
            dailyMilestoneClaimed: false,
            loginStreak: 1,
            lastLoginDayStamp: "",
            claimedDailyRewardDays: [],
            totalKills: 77,
            chestsOpened: 13,
            powerOrbsUsed: 25,
            powerUpsUsed: 0,
            revivesUsed: 0,
            bestTerritoryPercent: 74.0,
            matchesPlayed: 18,
            matchesWon: 5,
            soundEnabled: true,
            hapticsEnabled: true,
            controlSensitivity: 1.0,
            hasNoAds: false,
            freeCardsClaimedToday: false,
            freeDroidChestClaimedToday: false,
            classicShopSkinBoughtToday: false
        )
    }

    // MARK: - Computed Helpers

    var equippedSkin: SkinDefinition {
        SkinCatalog.skin(id: state.equippedSkinId)
    }

    var selectedCountry: WorldCountry {
        WorldMapCatalog.country(id: state.selectedCountryId)
    }

    var selectedCountryProgress: Int {
        state.countryProgress[state.selectedCountryId] ?? 0
    }

    var completedCountriesCount: Int {
        state.countryProgress.values.filter { $0 >= 100 }.count
    }

    var southAmericaCompletedCount: Int {
        let saIds = Set(WorldMapCatalog.allCountries.filter { $0.continent == .southAmerica }.map { $0.id })
        return saIds.filter { (state.countryProgress[$0] ?? 0) >= 100 }.count
    }

    var southAmericaTotalCount: Int {
        WorldMapCatalog.allCountries.filter { $0.continent == .southAmerica }.count
    }

    var completedDailyMissionsCount: Int {
        state.dailyMissions.filter { $0.isCompleted }.count
    }

    var uncollectedShopBadgeCount: Int {
        var count = 0
        if !state.freeCardsClaimedToday { count += 1 }
        if !state.freeDroidChestClaimedToday { count += 1 }
        return count
    }

    var formattedCountdown: String {
        let hrs = resetRemainingSeconds / 3600
        let mins = (resetRemainingSeconds % 3600) / 60
        return String(format: "%dh %02dm", hrs, mins)
    }

    func isSkinUnlocked(_ id: String) -> Bool {
        state.unlockedSkinIds.contains(id)
    }

    func heroLevel(for id: String) -> Int {
        state.heroLevels[id] ?? 1
    }

    func heroCardsCount(for id: String) -> Int {
        state.heroCards[id] ?? 0
    }

    func heroCardsTarget(for skin: SkinDefinition) -> Int {
        let level = heroLevel(for: skin.id)
        let base: Int
        switch skin.unlockRule {
        case .heroCards(let target): base = target
        default: base = 40
        }
        return base * level
    }

    func milestoneProgress(for rule: SkinUnlockRule) -> (current: Int, target: Int)? {
        switch rule {
        case .loginStreak(let target):
            return (min(state.loginStreak, target), target)
        case .totalKills(let target):
            return (min(state.totalKills, target), target)
        case .chestsOpened(let target):
            return (min(state.chestsOpened, target), target)
        case .powerOrbsUsed(let target):
            return (min(state.powerOrbsUsed, target), target)
        case .countriesCompleted(let target):
            return (min(completedCountriesCount, target), target)
        case .powerUpsUsed(let target):
            return (min(state.powerUpsUsed, target), target)
        case .revivesUsed(let target):
            return (min(state.revivesUsed, target), target)
        default:
            return nil
        }
    }

    // MARK: - Actions

    func startMatch(mode: GameModeType? = nil, countryId: String? = nil) {
        if let mode = mode {
            state.activeMode = mode
        }
        if let countryId = countryId {
            state.selectedCountryId = countryId
        }
        lastMatchSummary = nil
        SoundHapticsManager.shared.playTap()
        isPlaying = true
        persist()
    }

    func openShowcase(skinId: String? = nil) {
        showcaseSkinId = skinId ?? state.equippedSkinId
        SoundHapticsManager.shared.playTap()
        showSkinShowcase = true
    }

    func equipSkin(_ id: String) {
        guard isSkinUnlocked(id) else { return }
        state.equippedSkinId = id
        SoundHapticsManager.shared.playReward()
        persist()
    }

    func purchaseSkinWithCoins(_ skin: SkinDefinition, cost: Int) -> Bool {
        guard state.coins >= cost else {
            showToast("Not enough Coins!")
            return false
        }
        state.coins -= cost
        state.unlockedSkinIds.insert(skin.id)
        state.equippedSkinId = skin.id
        SoundHapticsManager.shared.playReward()
        showToast("Unlocked \(skin.name)!")
        persist()
        return true
    }

    func purchaseSkinWithGems(_ skin: SkinDefinition, cost: Int) -> Bool {
        guard state.gems >= cost else {
            showToast("Not enough Gems!")
            return false
        }
        state.gems -= cost
        state.unlockedSkinIds.insert(skin.id)
        state.equippedSkinId = skin.id
        SoundHapticsManager.shared.playReward()
        showToast("Unlocked \(skin.name)!")
        persist()
        return true
    }

    func upgradeHero(_ skin: SkinDefinition) {
        let currentCards = heroCardsCount(for: skin.id)
        let target = heroCardsTarget(for: skin)
        guard currentCards >= target else { return }
        state.heroCards[skin.id] = currentCards - target
        state.heroLevels[skin.id] = heroLevel(for: skin.id) + 1
        state.unlockedSkinIds.insert(skin.id)
        SoundHapticsManager.shared.playReward()
        showToast("\(skin.name) reached Lv. \(heroLevel(for: skin.id))!")
        persist()
    }

    func toggleStartFiveX() {
        startFiveXActive.toggle()
        SoundHapticsManager.shared.playTap()
        if startFiveXActive {
            showToast("5x Larger Start activated for next match!")
        }
    }

    func selectCountry(_ country: WorldCountry) {
        state.selectedCountryId = country.id
        state.activeMode = .worldConquest
        SoundHapticsManager.shared.playTap()
        persist()
    }

    // MARK: - Missions

    func claimMission(_ mission: MissionItem) {
        guard mission.isCompleted, !mission.isClaimed else { return }
        if mission.isLifetime {
            if let idx = state.lifetimeMissions.firstIndex(where: { $0.id == mission.id }) {
                state.lifetimeMissions[idx].isClaimed = true
            }
        } else {
            if let idx = state.dailyMissions.firstIndex(where: { $0.id == mission.id }) {
                state.dailyMissions[idx].isClaimed = true
            }
        }
        state.coins += mission.rewardCoins
        state.gems += mission.rewardGems
        SoundHapticsManager.shared.playReward()
        persist()
    }

    func rerollDailyMission(_ mission: MissionItem) {
        guard let idx = state.dailyMissions.firstIndex(where: { $0.id == mission.id }),
              !mission.isClaimed else { return }
        let existingTitles = Set(state.dailyMissions.map { $0.title })
        let candidates = MissionTemplates.dailyPool.filter { !existingTitles.contains($0.0) }
        if let pick = candidates.randomElement() {
            state.dailyMissions[idx] = MissionItem(
                id: UUID().uuidString,
                title: pick.0,
                metric: pick.1,
                target: pick.2,
                progress: 0,
                rewardCoins: pick.3,
                rewardGems: 0,
                isClaimed: false,
                isLifetime: false
            )
            SoundHapticsManager.shared.playSwipeCard()
            persist()
        }
    }

    func claimDailyChestMilestone() {
        guard completedDailyMissionsCount >= 3, !state.dailyMilestoneClaimed else { return }
        state.dailyMilestoneClaimed = true
        state.gems += 15
        SoundHapticsManager.shared.playReward()
        showToast("+15 Gems Claimed!")
        persist()
    }

    // MARK: - Shop & Chests

    func claimFreeDailyCards() {
        guard !state.freeCardsClaimedToday else { return }
        state.freeCardsClaimedToday = true
        let hero = SkinCatalog.commonHeroes.first { $0.id == "hero_cubey" } ?? SkinCatalog.commonHeroes[0]
        state.heroCards[hero.id, default: 0] += 6
        SoundHapticsManager.shared.playReward()
        showToast("+6 \(hero.name) Cards!")
        persist()
    }

    func claimFreeDroidChest() {
        guard !state.freeDroidChestClaimedToday else { return }
        state.freeDroidChestClaimedToday = true
        state.chestsOpened += 1
        state.heroCards["hero_droid", default: 0] += 20
        state.unlockedSkinIds.insert("hero_droid")
        let reward = ChestRevealReward(
            title: "Droid Cubey Pack",
            subtitle: "Unlocked + 20 Hero Cards",
            coins: 350,
            gems: 5,
            heroId: "hero_droid",
            heroCardsAmount: 20,
            unlockedSkinId: "hero_droid"
        )
        state.coins += reward.coins
        state.gems += reward.gems
        updateMissionMetric(.openChests, delta: 1)
        evaluateMilestoneUnlocks()
        SoundHapticsManager.shared.playReward()
        chestReveal = (.common, [reward])
        persist()
    }

    func buyShopClassicDeal() {
        guard !state.classicShopSkinBoughtToday else { return }
        let targetSkin = SkinCatalog.classicSkins.first { !isSkinUnlocked($0.id) } ?? SkinCatalog.skin(id: "rhino")
        if purchaseSkinWithCoins(targetSkin, cost: 4750) {
            state.classicShopSkinBoughtToday = true
            persist()
        }
    }

    func openChest(rarity: ChestRarity) {
        guard state.gems >= rarity.gemCost else {
            showToast("Need \(rarity.gemCost) Gems!")
            return
        }
        state.gems -= rarity.gemCost
        state.chestsOpened += 1

        var rewards: [ChestRevealReward] = []
        let coinRoll: Int
        let cardRoll: Int
        let heroPool: [SkinDefinition]

        switch rarity {
        case .common:
            coinRoll = Int.random(in: 250...550)
            cardRoll = Int.random(in: 8...16)
            heroPool = SkinCatalog.commonHeroes
        case .rare:
            coinRoll = Int.random(in: 900...1600)
            cardRoll = Int.random(in: 18...32)
            heroPool = SkinCatalog.rareHeroes + SkinCatalog.commonHeroes
        case .epic:
            coinRoll = Int.random(in: 2000...3500)
            cardRoll = Int.random(in: 28...48)
            heroPool = SkinCatalog.epicHeroes + SkinCatalog.rareHeroes
        case .legendary:
            coinRoll = Int.random(in: 4500...7500)
            cardRoll = Int.random(in: 45...75)
            heroPool = SkinCatalog.legendaryHeroes + SkinCatalog.epicHeroes
        }

        let pickedHero = heroPool.randomElement() ?? SkinCatalog.commonHeroes[0]
        state.coins += coinRoll
        state.heroCards[pickedHero.id, default: 0] += cardRoll
        if (state.heroCards[pickedHero.id] ?? 0) >= 40 {
            state.unlockedSkinIds.insert(pickedHero.id)
        }

        rewards.append(ChestRevealReward(
            title: "Coins Bonus",
            subtitle: "Treasury Loot",
            coins: coinRoll,
            gems: 0,
            heroId: nil,
            heroCardsAmount: 0,
            unlockedSkinId: nil
        ))

        rewards.append(ChestRevealReward(
            title: "\(pickedHero.name) Cards",
            subtitle: "+\(cardRoll) Hero Cards",
            coins: 0,
            gems: 0,
            heroId: pickedHero.id,
            heroCardsAmount: cardRoll,
            unlockedSkinId: isSkinUnlocked(pickedHero.id) ? pickedHero.id : nil
        ))

        // Chance to unlock a locked Classic skin in Rare+ chests
        if rarity != .common,
           let lockedClassic = SkinCatalog.classicSkins.filter({ !isSkinUnlocked($0.id) }).randomElement() {
            state.unlockedSkinIds.insert(lockedClassic.id)
            rewards.append(ChestRevealReward(
                title: lockedClassic.name,
                subtitle: "New Classic Skin Unlocked!",
                coins: 0,
                gems: 0,
                heroId: nil,
                heroCardsAmount: 0,
                unlockedSkinId: lockedClassic.id
            ))
        }

        updateMissionMetric(.openChests, delta: 1)
        evaluateMilestoneUnlocks()
        SoundHapticsManager.shared.playReward()
        chestReveal = (rarity, rewards)
        persist()
    }

    func purchaseGemPack(_ pack: GemPackItem) {
        state.gems += pack.gems
        SoundHapticsManager.shared.playReward()
        showToast("Added +\(pack.gems) Gems!")
        persist()
    }

    func purchaseCoinPack(_ pack: CoinPackItem) {
        guard state.gems >= pack.gemCost else {
            showToast("Not enough Gems!")
            return
        }
        state.gems -= pack.gemCost
        state.coins += pack.coins
        SoundHapticsManager.shared.playReward()
        showToast("Converted +\(pack.coins.compactFormatted) Coins!")
        persist()
    }

    func activateNoAdsDemo() {
        state.hasNoAds = true
        state.gems += 50
        SoundHapticsManager.shared.playReward()
        showToast("Ad-Free Mode Enabled (+50 Bonus Gems)!")
        persist()
    }

    // MARK: - Daily Login Rewards

    func claimDailyLoginReward(_ reward: DailyLoginReward) {
        guard reward.dayNumber <= state.loginStreak,
              !state.claimedDailyRewardDays.contains(reward.dayNumber) else { return }
        state.claimedDailyRewardDays.insert(reward.dayNumber)
        state.coins += reward.coins
        state.gems += reward.gems
        if let skinId = reward.specialSkinId {
            state.unlockedSkinIds.insert(skinId)
        }
        SoundHapticsManager.shared.playReward()
        showToast("Claimed Day \(reward.dayNumber): \(reward.title)!")
        persist()
    }

    // MARK: - Gameplay Completion & Recording

    func recordOrbCollected(type: PowerUpOrbType) {
        state.powerOrbsUsed += 1
        state.powerUpsUsed += 1
        updateMissionMetric(.collectOrbs, delta: 1)
        evaluateMilestoneUnlocks()
        persist()
    }

    func spendGemToRevive() -> Bool {
        let cost = 10
        guard state.gems >= cost else { return false }
        state.gems -= cost
        state.revivesUsed += 1
        updateMissionMetric(.revivesUsed, delta: 1)
        evaluateMilestoneUnlocks()
        persist()
        return true
    }

    func finishMatch(
        mode: GameModeType,
        peakPercent: Double,
        kills: Int,
        rank: Int,
        isVictory: Bool,
        outsideStreakSeconds: Int,
        insideEnemyStreakSeconds: Int
    ) {
        isPlaying = false
        startFiveXActive = false

        state.matchesPlayed += 1
        if isVictory {
            state.matchesWon += 1
        }
        state.totalKills += kills
        state.bestTerritoryPercent = max(state.bestTerritoryPercent, peakPercent)
        state.starScore += Int(peakPercent * 2.5) + kills * 15

        let baseCoins = max(80, Int(peakPercent * 14.0) + kills * 45 + (isVictory ? 350 : 0))
        let bonusGems = isVictory ? 8 : (peakPercent >= 50 ? 2 : 0)
        state.coins += baseCoins
        state.gems += bonusGems

        var countryDelta = 0
        var countryName: String? = nil

        if mode == .worldConquest {
            let cid = state.selectedCountryId
            countryName = WorldMapCatalog.country(id: cid).name
            let oldPct = state.countryProgress[cid] ?? 0
            let gain = isVictory ? 100 : max(8, Int(peakPercent * 0.65))
            let newPct = min(100, oldPct + gain)
            countryDelta = max(0, newPct - oldPct)
            state.countryProgress[cid] = newPct
            if oldPct < 100 && newPct >= 100 {
                updateMissionMetric(.completeCountries, delta: 1)
            }
        }

        // Unlock seasonal event skins upon strong runs or victory!
        if mode == .halloweenEvent && (isVictory || peakPercent >= 40) {
            state.unlockedSkinIds.insert("event_pumpkin")
            if isVictory {
                state.unlockedSkinIds.insert("event_vampire")
            }
        } else if mode == .christmasEvent && (isVictory || peakPercent >= 40) {
            state.unlockedSkinIds.insert("event_santa")
            if isVictory {
                state.unlockedSkinIds.insert("event_snowman")
            }
        }

        // Update missions
        updateMissionMetric(.defeatEnemies, delta: kills)
        updateMissionMetric(.outsideTerritorySeconds, maxValue: outsideStreakSeconds)
        updateMissionMetric(.insideEnemyTerritorySeconds, maxValue: insideEnemyStreakSeconds)
        updateMissionMetric(.reachPercentage, maxValue: Int(peakPercent))
        if mode == .teamBattle {
            updateMissionMetric(.playTeamMatches, delta: 1)
        }
        if isVictory && mode == .classic {
            updateMissionMetric(.winMatches, delta: 1)
        }

        evaluateMilestoneUnlocks()
        persist()

        lastMatchSummary = MatchSummary(
            mode: mode,
            countryName: countryName,
            peakTerritoryPercent: peakPercent,
            kills: kills,
            rank: rank,
            coinsEarned: baseCoins,
            gemsEarned: bonusGems,
            isVictory: isVictory,
            countryDeltaPercent: countryDelta
        )
    }

    func doubleMatchCoinsReward() {
        guard let summary = lastMatchSummary else { return }
        state.coins += summary.coinsEarned
        SoundHapticsManager.shared.playReward()
        showToast("+\(summary.coinsEarned) Bonus Coins!")
        lastMatchSummary = nil
        persist()
    }

    // MARK: - Settings & Maintenance

    func updateSettings(sound: Bool? = nil, haptics: Bool? = nil, sensitivity: Double? = nil, playerName: String? = nil) {
        if let sound = sound { state.soundEnabled = sound }
        if let haptics = haptics { state.hapticsEnabled = haptics }
        if let sensitivity = sensitivity { state.controlSensitivity = sensitivity }
        if let name = playerName {
            let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
            if !trimmed.isEmpty {
                state.playerName = String(trimmed.prefix(14))
            }
        }
        syncAudioSettings()
        persist()
    }

    func resetAllProgress() {
        state = GameStore.createDefaultState()
        syncAudioSettings()
        evaluateMilestoneUnlocks()
        persist()
        showToast("Progress reset to starter profile")
    }

    func showToast(_ message: String) {
        toastMessage = message
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.4) { [weak self] in
            if self?.toastMessage == message {
                self?.toastMessage = nil
            }
        }
    }

    // MARK: - Internal Helpers

    private func updateMissionMetric(_ metric: MissionMetric, delta: Int) {
        for i in state.dailyMissions.indices where state.dailyMissions[i].metric == metric {
            state.dailyMissions[i].progress = min(state.dailyMissions[i].target, state.dailyMissions[i].progress + delta)
        }
        for i in state.lifetimeMissions.indices where state.lifetimeMissions[i].metric == metric {
            state.lifetimeMissions[i].progress = min(state.lifetimeMissions[i].target, state.lifetimeMissions[i].progress + delta)
        }
    }

    private func updateMissionMetric(_ metric: MissionMetric, maxValue: Int) {
        for i in state.dailyMissions.indices where state.dailyMissions[i].metric == metric {
            state.dailyMissions[i].progress = min(state.dailyMissions[i].target, max(state.dailyMissions[i].progress, maxValue))
        }
        for i in state.lifetimeMissions.indices where state.lifetimeMissions[i].metric == metric {
            state.lifetimeMissions[i].progress = min(state.lifetimeMissions[i].target, max(state.lifetimeMissions[i].progress, maxValue))
        }
    }

    private func evaluateMilestoneUnlocks() {
        for skin in SkinCatalog.all {
            if let pair = milestoneProgress(for: skin.unlockRule), pair.current >= pair.target {
                state.unlockedSkinIds.insert(skin.id)
            }
        }
    }

    private func checkDailyLoginStreak() {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let today = formatter.string(from: Date())
        if state.lastLoginDayStamp != today {
            if !state.lastLoginDayStamp.isEmpty {
                state.loginStreak = min(7, state.loginStreak + 1)
            }
            state.lastLoginDayStamp = today
            state.freeCardsClaimedToday = false
            state.freeDroidChestClaimedToday = false
            state.classicShopSkinBoughtToday = false
            evaluateMilestoneUnlocks()
            persist()
        }
    }

    private func syncAudioSettings() {
        SoundHapticsManager.shared.soundEnabled = state.soundEnabled
        SoundHapticsManager.shared.hapticsEnabled = state.hapticsEnabled
    }

    private func startCountdownTimer() {
        timerCancellable = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let self = self else { return }
                if self.resetRemainingSeconds > 0 {
                    self.resetRemainingSeconds -= 1
                } else {
                    self.resetRemainingSeconds = 24 * 3600
                }
            }
    }

    private func persist() {
        if let encoded = try? JSONEncoder().encode(state) {
            UserDefaults.standard.set(encoded, forKey: storageKey)
        }
    }
}
