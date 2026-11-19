import XCTest
@testable import PaperTerritory

final class ProgressionAndEconomyTests: XCTestCase {
    func testMatchRewardsScaleProportionallyWithTerritoryPercentage() {
        let smallMatch = MatchOutcomeSnapshot(
            peakPercentage: 10.0,
            finalPercentage: 8.0,
            kills: 0,
            elapsedSeconds: 20,
            isVictory: false,
            finalRank: 6,
            countryStageId: nil
        )
        let bigMatch = MatchOutcomeSnapshot(
            peakPercentage: 65.0,
            finalPercentage: 65.0,
            kills: 3,
            elapsedSeconds: 80,
            isVictory: false,
            finalRank: 1,
            countryStageId: nil
        )

        let smallRewards = EconomyCalculator.calculateRewards(outcome: smallMatch, currentRankPoints: 0)
        let bigRewards = EconomyCalculator.calculateRewards(outcome: bigMatch, currentRankPoints: 0)

        XCTAssertGreaterThan(smallRewards.goldEarned, 0)
        XCTAssertGreaterThan(smallRewards.diamondsEarned, 0)
        XCTAssertGreaterThan(bigRewards.goldEarned, smallRewards.goldEarned)
        XCTAssertGreaterThan(bigRewards.diamondsEarned, smallRewards.diamondsEarned)
        XCTAssertGreaterThan(bigRewards.rankPointsDelta, smallRewards.rankPointsDelta)
    }

    func testTenRankTiersHaveStrictlyIncreasingThresholdsAndProgress() {
        XCTAssertEqual(RankTier.allCases.count, 10)
        XCTAssertEqual(RankTier.allCases.first, .bronze)
        XCTAssertEqual(RankTier.allCases.last, .legend)

        for idx in 1..<RankTier.allCases.count {
            XCTAssertGreaterThan(RankTier.allCases[idx].minPoints, RankTier.allCases[idx - 1].minPoints)
        }

        XCTAssertEqual(RankTier.tier(for: 0), .bronze)
        XCTAssertEqual(RankTier.tier(for: 150), .silver)
        XCTAssertEqual(RankTier.tier(for: 1_200), .diamond)
        XCTAssertEqual(RankTier.tier(for: 6_500), .legend)
        XCTAssertEqual(RankTier.progressToNext(points: 9_999), 1.0, accuracy: 1e-6)
    }

    func testDailyMissionsGenerateThreeDistinctMissionsAndUnlockChestAtThreeOfThree() {
        var state = DailyMissionSystem.generateDailyState(forDayKey: "2026-11-19")
        XCTAssertEqual(state.missions.count, 3)
        XCTAssertEqual(Set(state.missions.map(\.kind)).count, 3)
        XCTAssertFalse(state.canClaimChest)

        // Complete all 3 missions and verify chest becomes claimable.
        for idx in state.missions.indices {
            state.missions[idx].progress = state.missions[idx].target
        }
        XCTAssertTrue(state.allCompleted)
        XCTAssertTrue(state.canClaimChest)
    }

    func testDailyMissionChestHasOnePercentSkinRateAndNeverExceedsOneThousandCurrencies() {
        var rng = SeededRandomGenerator(seed: 0xCAFE_BABE_1234)
        let owned: Set<String> = [SkinCatalog.starterSkinId]
        var skinDrops = 0
        let totalRolls = 2_000

        for _ in 0..<totalRolls {
            let reward = DailyMissionSystem.rollDailyChest(ownedSkinIds: owned, rng: &rng)
            XCTAssertLessThanOrEqual(reward.gold, 1_000)
            XCTAssertLessThanOrEqual(reward.diamonds, 1_000)
            if let skinId = reward.unlockedSkinId {
                skinDrops += 1
                XCTAssertFalse(owned.contains(skinId))
            } else {
                XCTAssertGreaterThan(reward.gold, 0)
                XCTAssertGreaterThan(reward.diamonds, 0)
            }
        }

        // 1% of 2,000 = 20 expected; verify statistically sound range (5...45).
        XCTAssertGreaterThanOrEqual(skinDrops, 5)
        XCTAssertLessThanOrEqual(skinDrops, 45)
    }

    func testWorldMapHasSixContinentsWithEightCountriesEachAndUnlocksNextAtEightOfEight() {
        XCTAssertEqual(WorldMapCatalog.continents.count, 6)
        for continent in WorldMapCatalog.continents {
            XCTAssertEqual(continent.countries.count, 8, "Continent \(continent.name) must have 8 countries")
        }

        var completed = Set<String>()
        XCTAssertTrue(WorldMapCatalog.isContinentUnlocked("asia", completedCountryIds: completed))
        XCTAssertFalse(WorldMapCatalog.isContinentUnlocked("europe", completedCountryIds: completed))

        let asiaIds = WorldMapCatalog.continents[0].countries.map(\.id)
        for id in asiaIds.prefix(7) {
            completed.insert(id)
        }
        XCTAssertFalse(WorldMapCatalog.isContinentUnlocked("europe", completedCountryIds: completed))

        completed.insert(asiaIds[7])
        XCTAssertTrue(WorldMapCatalog.isContinentUnlocked("europe", completedCountryIds: completed))
        XCTAssertFalse(WorldMapCatalog.isContinentUnlocked("north_america", completedCountryIds: completed))
    }

    @MainActor
    func testProfileStoreShopHeroChestsWorldUnlockAndPersistence() {
        let suiteName = "paper_territory_test_\(UUID().uuidString)"
        guard let defaults = UserDefaults(suiteName: suiteName) else {
            XCTFail("Failed to create isolated UserDefaults suite")
            return
        }
        defer { defaults.removePersistentDomain(forName: suiteName) }

        let store = PlayerProfileStore(defaults: defaults, seed: 0x1234_ABCD)
        store.fulfillStoreOffer(StoreCatalog.goldOffers[1]) // +5,000 Gold
        store.fulfillStoreOffer(StoreCatalog.diamondOffers[1]) // +450 Diamonds
        XCTAssertGreaterThanOrEqual(store.profile.gold, 5_000)
        XCTAssertGreaterThanOrEqual(store.profile.diamonds, 450)

        // Buy a Gold skin and a Diamond skin
        let goldSkin = SkinCatalog.skin(withId: "ocean_wave")
        let diamondSkin = SkinCatalog.skin(withId: "lava_core")
        XCTAssertTrue(store.buySkin(goldSkin))
        XCTAssertTrue(store.buySkin(diamondSkin))
        XCTAssertEqual(store.profile.equippedSkinId, diamondSkin.id)

        // Open Common, Rare, and Super Hero Chests using Diamonds
        store.fulfillStoreOffer(StoreCatalog.diamondOffers[2]) // +1,400 Diamonds
        for tier in HeroChestTier.allCases {
            let beforeDiamonds = store.profile.diamonds
            let reward = store.openHeroChest(tier)
            XCTAssertNotNil(reward)
            XCTAssertEqual(store.profile.diamonds, beforeDiamonds - tier.diamondCost + (reward?.diamonds ?? 0))
        }

        // Verify persistence round-trip
        let reloaded = PlayerProfileStore(defaults: defaults, seed: 0x1234_ABCD)
        XCTAssertTrue(reloaded.profile.ownedSkinIds.contains(goldSkin.id))
        XCTAssertTrue(reloaded.profile.ownedSkinIds.contains(diamondSkin.id))
        XCTAssertEqual(reloaded.profile.equippedSkinId, diamondSkin.id)
    }
}
