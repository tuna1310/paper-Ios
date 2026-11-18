import XCTest
@testable import PaperTerritory

final class LeaderboardTests: XCTestCase {
    func testLeaderboardSortsDescendingAndCapsTop5WithPlayerFallback() {
        let engine = GameEngine()
        // Give bots 0...4 larger territories than human player so player drops outside Top 5
        for index in 0..<6 {
            let bot = engine.bots[index]
            let extraRadius = 5 + (6 - index)
            engine.grid.initStarterTerritory(
                ownerId: bot.id,
                centerX: 25 + index * 15,
                centerY: 25,
                radius: extraRadius
            )
        }

        let snapshot = engine.leaderboardSnapshot()
        XCTAssertEqual(snapshot.topFive.count, 5)

        for idx in 0..<(snapshot.topFive.count - 1) {
            XCTAssertGreaterThanOrEqual(snapshot.topFive[idx].percentage, snapshot.topFive[idx + 1].percentage)
            XCTAssertEqual(snapshot.topFive[idx].rank, idx + 1)
        }

        XCTAssertNotNil(snapshot.playerOutsideTopFive)
        XCTAssertEqual(snapshot.playerOutsideTopFive?.isPlayer, true)
        XCTAssertGreaterThan(snapshot.playerOutsideTopFive?.rank ?? 0, 5)
    }

    func testPlayerInsideTop5ClearsOutsideFallback() {
        let engine = GameEngine()
        engine.grid.initStarterTerritory(ownerId: engine.player.id, centerX: 60, centerY: 60, radius: 10)

        let snapshot = engine.leaderboardSnapshot()
        XCTAssertEqual(snapshot.topFive.first?.isPlayer, true)
        XCTAssertEqual(snapshot.topFive.first?.rank, 1)
        XCTAssertNil(snapshot.playerOutsideTopFive)
    }
}
