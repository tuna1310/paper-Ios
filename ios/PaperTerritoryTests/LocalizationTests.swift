import XCTest
@testable import PaperTerritory

final class LocalizationTests: XCTestCase {
    func testAllGameStringsAndBotNamesAreEnglishAndNonEmpty() {
        var strings = [
            L10n.appTitle,
            L10n.demoControlsHint,
            L10n.leaderboardTitle,
            L10n.playerDefaultName,
            L10n.restartButton,
            L10n.pausedTitle,
            L10n.resumeButton,
            L10n.killsLabel,
            L10n.bestLabel,
            L10n.gameOverTitle,
            L10n.victoryTitle,
            L10n.playAgainButton,
            L10n.endVictorySubtitle,
            L10n.endSelfTrail,
            L10n.endBoundary,
            L10n.endHeadOnMutual,
            L10n.endStarvation,
            L10n.endEnemyTrail(killerName: "Lucas"),
            L10n.endHeadOnLoss(killerName: "Mia"),
            L10n.percentageText(12.5),
            L10n.killsText(3)
        ]
        strings.append(contentsOf: GameConfig.botNames)
        strings.append(contentsOf: RankTier.allCases.map(\.displayName))
        strings.append(contentsOf: WorldMapCatalog.continents.map(\.name))
        strings.append(contentsOf: WorldMapCatalog.allCountries.map(\.name))
        strings.append(contentsOf: SkinCatalog.all.map(\.name))
        strings.append(contentsOf: HeroChestTier.allCases.map(\.displayName))
        strings.append(contentsOf: HeroChestTier.allCases.map(\.oddsDescription))
        strings.append(contentsOf: StoreCatalog.allOffers.map(\.title))
        strings.append(contentsOf: StoreCatalog.allOffers.map(\.subtitle))
        let sampleMissions = DailyMissionSystem.generateDailyState(forDayKey: "2026-11-19").missions
        strings.append(contentsOf: sampleMissions.map(\.title))

        let forbiddenChars = CharacterSet(
            charactersIn: "ăâđêôơưĂÂĐÊÔƠƯáàảãạấầẩẫậắằẳẵặéèẻẽẹếềểễệíìỉĩịóòỏõọốồổỗộớờởỡợúùủũụứừửữựýỳỷỹỵ"
        )

        for value in strings {
            XCTAssertFalse(value.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            XCTAssertNil(
                value.rangeOfCharacter(from: forbiddenChars),
                "Found non-English Vietnamese character in string: \(value)"
            )
        }
        XCTAssertEqual(L10n.appTitle, "Paper Territory")
    }
}
