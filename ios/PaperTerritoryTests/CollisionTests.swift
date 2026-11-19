import XCTest
@testable import PaperTerritory

final class CollisionTests: XCTestCase {
    func testCrossingOwnTrailDoesNotKillPlayer() {
        let engine = GameEngine(
            gridWidth: 60,
            gridHeight: 60,
            settings: MatchSettings(
                botDifficulty: .normal,
                edgeRule: .die,
                headOnRule: .largerTerritoryWins,
                botCount: 10
            )
        )
        engine.player.posX = 30.5
        engine.player.posY = 35.5
        engine.player.direction = .right
        engine.player.trail.append(gx: 31, gy: 35)
        engine.grid.setOwner(GameConfig.neutralOwnerId, at: 31, gy: 35)

        for _ in 0..<10 {
            if !engine.isPlaying {
                break
            }
            engine.tick()
        }

        XCTAssertEqual(engine.gameState, .playing)
        XCTAssertTrue(engine.player.isAlive)
        XCTAssertGreaterThan(engine.grid.countCells(for: engine.player.id), 0)
    }

    func testHeadOnInsideOwnTerritoryProtectsDefenderAndEliminatesInvader() {
        let grid = GridMap()
        grid.initStarterTerritory(ownerId: 1, centerX: 50, centerY: 50)
        grid.initStarterTerritory(ownerId: 2, centerX: 80, centerY: 80, radius: 5)

        // Defender (id 1) has smaller total territory, but is standing inside own land (50, 50).
        let defender = Entity(
            id: 1,
            name: "You",
            isBot: false,
            palette: SkinPalette.playerDefault,
            spawn: GridPoint(gx: 50, gy: 50),
            initialDirection: .right
        )
        // Invader (id 2) has much larger territory, but is outside its own land at (50, 50).
        let invader = Entity(
            id: 2,
            name: "Nova",
            isBot: true,
            palette: SkinPalette.distinctBotPalettes[0],
            spawn: GridPoint(gx: 50, gy: 50),
            initialDirection: .left
        )

        let prev = [GridPoint(gx: 49, gy: 50), GridPoint(gx: 51, gy: 50)]
        let outcomes = [EntityStepOutcome(), EntityStepOutcome()]
        let detector = CollisionDetector()

        let events = detector.checkCollisions(
            entities: [defender, invader],
            grid: grid,
            previousCells: prev,
            stepOutcomes: outcomes,
            headOnRule: .largerTerritoryWins
        )
        XCTAssertEqual(events.count, 1)
        XCTAssertEqual(events[0].victimId, invader.id)
        XCTAssertEqual(events[0].killerId, defender.id)
    }

    func testCuttingBotTrailEliminatesBotAndClearsItsTerritoryToNeutral() {
        let engine = GameEngine()
        let victimBot = engine.bots[0]
        let botCellsBefore = engine.grid.countCells(for: victimBot.id)
        XCTAssertGreaterThan(botCellsBefore, 0)

        let targetCellX = engine.player.cellX + 1
        let targetCellY = engine.player.cellY
        victimBot.trail.append(gx: targetCellX, gy: targetCellY)
        engine.grid.setOwner(GameConfig.neutralOwnerId, at: targetCellX, gy: targetCellY)

        for _ in 0..<12 {
            engine.tick()
            if !victimBot.isAlive {
                break
            }
        }

        XCTAssertFalse(victimBot.isAlive)
        XCTAssertEqual(engine.grid.countCells(for: victimBot.id), 0)
        XCTAssertEqual(engine.player.kills, 1)
    }

    func testBotCuttingPlayerTrailEndsMatchWithEnemyTrailReason() {
        let engine = GameEngine()
        let attackerBot = engine.bots[0]

        engine.player.trail.append(gx: 30, gy: 30)
        attackerBot.posX = 30.5
        attackerBot.posY = 30.5
        attackerBot.direction = .right

        let detector = CollisionDetector()
        let outcomes = Array(repeating: EntityStepOutcome(), count: engine.entities.count)
        let prev = engine.entities.map { GridPoint(gx: $0.cellX, gy: $0.cellY) }
        let events = detector.checkCollisions(
            entities: engine.entities,
            grid: engine.grid,
            previousCells: prev,
            stepOutcomes: outcomes,
            headOnRule: .largerTerritoryWins
        )

        let playerDeath = events.first { $0.victimId == engine.player.id }
        XCTAssertEqual(playerDeath?.reason, .enemyTrail(killerName: attackerBot.name))
    }

    func testBoundaryCollisionTriggersGameOverWhenEdgeRuleIsDie() {
        var settings = MatchSettings.default
        settings.edgeRule = .die
        let engine = GameEngine(settings: settings)
        engine.player.posX = 119.5
        engine.player.posY = 60.5
        engine.player.direction = .right
        engine.player.inputQueue.clear()

        for _ in 0..<10 {
            engine.tick()
            if !engine.isPlaying {
                break
            }
        }

        XCTAssertEqual(engine.gameState, .gameOver(.boundary))
    }

    func testHeadOnLargerTerritoryWinsAndSwappedCellsDetectCollision() {
        let grid = GridMap()
        grid.initStarterTerritory(ownerId: 1, centerX: 20, centerY: 20)
        grid.initStarterTerritory(ownerId: 2, centerX: 80, centerY: 80)
        grid.setOwner(2, at: 83, gy: 80)

        let p1 = Entity(
            id: 1,
            name: "You",
            isBot: false,
            palette: SkinPalette.playerDefault,
            spawn: GridPoint(gx: 51, gy: 50),
            initialDirection: .right
        )
        let p2 = Entity(
            id: 2,
            name: "Nova",
            isBot: true,
            palette: SkinPalette.distinctBotPalettes[0],
            spawn: GridPoint(gx: 50, gy: 50),
            initialDirection: .left
        )

        let prev = [GridPoint(gx: 50, gy: 50), GridPoint(gx: 51, gy: 50)]
        let outcomes = [EntityStepOutcome(), EntityStepOutcome()]
        let detector = CollisionDetector()

        let largerWinsEvents = detector.checkCollisions(
            entities: [p1, p2],
            grid: grid,
            previousCells: prev,
            stepOutcomes: outcomes,
            headOnRule: .largerTerritoryWins
        )
        XCTAssertEqual(largerWinsEvents.count, 1)
        XCTAssertEqual(largerWinsEvents[0].victimId, p1.id)
        XCTAssertEqual(largerWinsEvents[0].reason, .headOnLoss(killerName: "Nova"))

        let bothDieEvents = detector.checkCollisions(
            entities: [p1, p2],
            grid: grid,
            previousCells: prev,
            stepOutcomes: outcomes,
            headOnRule: .bothDie
        )
        XCTAssertEqual(bothDieEvents.count, 2)
        XCTAssertTrue(bothDieEvents.allSatisfy { $0.reason == .headOnMutual })
    }

    func testVictoryTriggersAt100PercentTerritoryAndStarvationEliminatesZeroCellEntity() {
        let engine = GameEngine(gridWidth: 60, gridHeight: 60)
        let victimBot = engine.bots[0]
        engine.grid.clearTerritory(for: victimBot.id)
        engine.tick()
        XCTAssertFalse(victimBot.isAlive)

        for gy in 0..<engine.grid.height {
            for gx in 0..<engine.grid.width {
                engine.grid.setOwner(engine.player.id, at: gx, gy: gy)
            }
        }
        engine.tick()
        XCTAssertEqual(engine.gameState, .victory)
    }
}
