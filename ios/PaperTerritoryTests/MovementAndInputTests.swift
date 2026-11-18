@testable import PaperTerritory
import XCTest

final class MovementAndInputTests: XCTestCase {
    func testInputQueueRejects180DegreeReversalAndCapsAtTwoCommands() {
        var queue = InputQueue()
        XCTAssertFalse(queue.enqueue(.left, currentDirection: .right))
        XCTAssertFalse(queue.enqueue(.right, currentDirection: .right))

        XCTAssertTrue(queue.enqueue(.up, currentDirection: .right))
        XCTAssertTrue(queue.enqueue(.left, currentDirection: .right))
        XCTAssertEqual(queue.count, 2)

        XCTAssertFalse(queue.enqueue(.down, currentDirection: .right))
        XCTAssertEqual(queue.count, 2)

        XCTAssertEqual(queue.popNextValid(currentDirection: .right), .up)
        XCTAssertEqual(queue.popNextValid(currentDirection: .up), .left)
        XCTAssertNil(queue.popNextValid(currentDirection: .left))
    }

    func testEntityExecutesBufferedTwoStepCornerAtCellCenters() {
        let grid = GridMap()
        grid.initStarterTerritory(ownerId: 1, centerX: 60, centerY: 60)
        let palette = SkinPalette.playerDefault
        let entity = Entity(
            id: 1,
            name: "You",
            isBot: false,
            colorHex: palette.baseHex,
            darkColorHex: palette.darkHex,
            trailColorHex: palette.trailHex,
            spawnCellX: 60,
            spawnCellY: 60,
            initialDirection: .right
        )

        _ = entity.advance(by: 0.25, grid: grid, edgeRule: .die)
        XCTAssertEqual(entity.posX, 60.75, accuracy: 1e-6)

        XCTAssertTrue(entity.enqueueTurn(.up))
        XCTAssertTrue(entity.enqueueTurn(.left))

        // Reach (61.5, 60.5) -> turn up -> reach (61.5, 61.5) -> turn left
        _ = entity.advance(by: 1.75, grid: grid, edgeRule: .die)
        XCTAssertEqual(entity.direction, .left)
        XCTAssertEqual(entity.posX, 61.5, accuracy: 1e-5)
        XCTAssertEqual(entity.posY, 61.5, accuracy: 1e-5)
    }

    func testEntityRecordsTrailOutsideOwnTerritoryAndClosesLoop() {
        let engine = GameEngine()
        // Base is (58...62, 58...62). Player starts at (60.5, 60.5) heading right.
        for _ in 0..<25 { engine.tick() }
        XCTAssertFalse(engine.player.trail.isEmpty)

        // Turn up for 10 ticks (to y ~ 62.0), then left back into base at x=62, y=62
        engine.enqueuePlayerTurn(.up)
        for _ in 0..<10 { engine.tick() }
        engine.enqueuePlayerTurn(.left)
        for _ in 0..<25 { engine.tick() }

        XCTAssertTrue(engine.isPlaying)
        XCTAssertTrue(engine.player.trail.isEmpty)
        XCTAssertGreaterThan(engine.grid.countCells(for: engine.player.id), 25)
    }

    func testEdgeRuleBlockStopsEntityWithoutKilling() {
        let grid = GridMap()
        grid.initStarterTerritory(ownerId: 1, centerX: 117, centerY: 60)
        let palette = SkinPalette.playerDefault
        let entity = Entity(
            id: 1,
            name: "You",
            isBot: false,
            colorHex: palette.baseHex,
            darkColorHex: palette.darkHex,
            trailColorHex: palette.trailHex,
            spawnCellX: 118,
            spawnCellY: 60,
            initialDirection: .right
        )

        let outcome = entity.advance(by: 5.0, grid: grid, edgeRule: .block)
        XCTAssertFalse(outcome.hitBoundary)
        XCTAssertEqual(entity.posX, 119.5, accuracy: 1e-6)
    }

    func testEdgeRuleDieFlagsBoundaryCollision() {
        let grid = GridMap()
        grid.initStarterTerritory(ownerId: 1, centerX: 117, centerY: 60)
        let palette = SkinPalette.playerDefault
        let entity = Entity(
            id: 1,
            name: "You",
            isBot: false,
            colorHex: palette.baseHex,
            darkColorHex: palette.darkHex,
            trailColorHex: palette.trailHex,
            spawnCellX: 118,
            spawnCellY: 60,
            initialDirection: .right
        )

        let outcome = entity.advance(by: 5.0, grid: grid, edgeRule: .die)
        XCTAssertTrue(outcome.hitBoundary)
    }
}
