@testable import PaperTerritory
import XCTest

final class LocalizationTests: XCTestCase {
    func testAllGameStringsAreEnglishAndNonEmpty() {
        let strings = [
            L10n.appTitle,
            L10n.demoControlsHint,
            L10n.leaderboardTitle,
            L10n.playerDefaultName,
            L10n.restartButton,
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

        let forbiddenChars = CharacterSet(
            charactersIn: "ăâđêôơưĂÂĐÊÔƠƯáàảãạấầẩẫậắằẳẵặéèẻẽẹếềểễệíìỉĩịóòỏõọốồổỗộớờởỡợúùủũụứừửữựýỳỷỹỵ"
        )

        for value in strings {
            XCTAssertFalse(value.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            XCTAssertNil(
                value.rangeOfCharacter(from: forbiddenChars),
                "Found non-English Vietnamese character in localized string: \(value)"
            )
        }
        XCTAssertEqual(L10n.appTitle, "Paper Territory")
    }
}
