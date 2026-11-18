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
                botCount: 10
            )
            let engine = GameEngine(gridWidth: 72, gridHeight: 72, settings: settings, seed: 0xDEAD_BEEF)

            // Keep human player safe inside an expanded base while bots battle in a denser arena.
            engine.grid.initStarterTerritory(ownerId: engine.player.id, centerX: 36, centerY: 36, radius: 5)

            var selfTrailSuicides = 0
            for tickIndex in 0..<300 {
                if tickIndex % 12 == 0 {
                    engine.enqueuePlayerTurn(Direction.allCases[(tickIndex / 12) % 4])
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

    func testHardBotEscapesOwnTrailPocketWithoutSelfSuicide() {
        let settings = MatchSettings(
            botDifficulty: .hard,
            edgeRule: .die,
            headOnRule: .largerTerritoryWins,
            botCount: 10
        )
        let engine = GameEngine(gridWidth: 48, gridHeight: 48, settings: settings, seed: 0x5EED_CAFE)
        engine.grid.initStarterTerritory(ownerId: engine.player.id, centerX: 40, centerY: 40, radius: 5)
        engine.player.resetForRespawn(spawnCellX: 40, spawnCellY: 40, initialDirection: .right)

        for other in engine.bots.dropFirst() {
            other.isAlive = false
            other.trail.clear()
            other.respawnTimer = 60.0
            engine.grid.clearTerritory(for: other.id)
        }

        let bot = engine.bots[0]
        engine.grid.clearTerritory(for: bot.id)
        engine.grid.initStarterTerritory(ownerId: bot.id, centerX: 13, centerY: 7, radius: 1)
        engine.grid.initStarterTerritory(ownerId: bot.id, centerX: 20, centerY: 10, radius: 1)
        engine.grid.initStarterTerritory(ownerId: bot.id, centerX: 20, centerY: 11, radius: 1)

        bot.resetForRespawn(spawnCellX: 15, spawnCellY: 11, initialDirection: .down)
        bot.posX = 15.5
        bot.posY = 11.2
        let trapTrail: [GridPoint] = [
            GridPoint(gx: 18, gy: 11),
            GridPoint(gx: 17, gy: 11),
            GridPoint(gx: 17, gy: 10),
            GridPoint(gx: 17, gy: 9),
            GridPoint(gx: 16, gy: 9),
            GridPoint(gx: 15, gy: 9),
            GridPoint(gx: 14, gy: 9),
            GridPoint(gx: 13, gy: 9),
            GridPoint(gx: 13, gy: 10),
            GridPoint(gx: 13, gy: 11),
            GridPoint(gx: 13, gy: 12),
            GridPoint(gx: 13, gy: 13),
            GridPoint(gx: 14, gy: 13),
            GridPoint(gx: 15, gy: 13),
            GridPoint(gx: 15, gy: 12),
            GridPoint(gx: 15, gy: 11)
        ]
        for pt in trapTrail {
            bot.trail.append(gx: pt.gx, gy: pt.gy)
        }

        var selfTrailSuicides = 0
        var closedEscapeLoop = false
        for tickIndex in 0..<180 {
            if tickIndex % 12 == 0 {
                engine.enqueuePlayerTurn(Direction.allCases[(tickIndex / 12) % 4])
            }
            engine.tick(dt: GameConfig.fixedTimestepSeconds)
            if bot.isAlive && bot.trail.isEmpty {
                closedEscapeLoop = true
            }
            for event in engine.recentEvents where event.reason == .selfTrail {
                selfTrailSuicides += 1
            }
        }

        XCTAssertEqual(selfTrailSuicides, 0)
        XCTAssertTrue(bot.isAlive)
        XCTAssertTrue(closedEscapeLoop)
        XCTAssertGreaterThan(engine.grid.countCells(for: bot.id), 25)
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
        XCTAssertGreaterThanOrEqual(engine.grid.countCells(for: bot.id), 25)
    }
}
