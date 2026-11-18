import XCTest
@testable import PaperTerritory

final class BotAITests: XCTestCase {
    func testSpawns12BotsWithDistinctColorsAndEnglishNames() {
        let engine = GameEngine()
        XCTAssertEqual(engine.bots.count, 12)
        XCTAssertTrue((10...15).contains(engine.bots.count))

        let uniqueColors = Set(engine.bots.map(\.colorHex))
        XCTAssertEqual(uniqueColors.count, engine.bots.count)
        XCTAssertFalse(uniqueColors.contains(engine.player.colorHex))

        let uniqueNames = Set(engine.bots.map(\.name))
        XCTAssertEqual(uniqueNames.count, engine.bots.count)
    }

    func testBotsSimulate10SecondsWithoutSelfSuicides() {
        for difficulty in BotDifficulty.allCases {
            let settings = MatchSettings(
                botDifficulty: difficulty,
                edgeRule: .die,
                headOnRule: .largerTerritoryWins,
                botCount: 12
            )
            let engine = GameEngine(settings: settings, seed: 0xDEAD_BEEF)

            // Keep human player safe inside a slightly expanded base while bots battle for 10 seconds
            engine.grid.initStarterTerritory(ownerId: engine.player.id, centerX: 60, centerY: 60, radius: 6)

            var selfTrailSuicides = 0
            for tickIndex in 0..<600 {
                // Keep human player circling safely inside own 13x13 home so match runs full 10s
                if tickIndex % 15 == 0 {
                    engine.enqueuePlayerTurn(Direction.allCases[(tickIndex / 15) % 4])
                }
                engine.tick(dt: GameConfig.fixedTimestepSeconds)

                for event in engine.recentEvents where event.reason == .selfTrail {
                    selfTrailSuicides += 1
                }
            }

            XCTAssertEqual(
                selfTrailSuicides,
                0,
                "Bots committed self-trail suicide on difficulty \(difficulty)"
            )
        }
    }

    func testDeadBotRespawnsAfterDelayInEmptyArea() {
        let engine = GameEngine()
        let bot = engine.bots[0]
        bot.isAlive = false
        bot.trail.clear()
        engine.grid.clearTerritory(for: bot.id)
        bot.respawnTimer = 2.5

        // Advance 3.0 seconds
        for _ in 0..<180 {
            engine.tick(dt: GameConfig.fixedTimestepSeconds)
        }

        XCTAssertTrue(bot.isAlive)
        XCTAssertEqual(engine.grid.countCells(for: bot.id), 25)
    }
}
