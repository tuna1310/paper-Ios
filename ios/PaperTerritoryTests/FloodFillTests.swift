@testable import PaperTerritory
import XCTest

final class FloodFillTests: XCTestCase {
    private var grid = GridMap()
    private var floodFill = FloodFill()
    private var player = Entity(
        id: 1,
        name: "You",
        isBot: false,
        colorHex: SkinPalette.playerDefault.baseHex,
        darkColorHex: SkinPalette.playerDefault.darkHex,
        trailColorHex: SkinPalette.playerDefault.trailHex,
        spawnCellX: 60,
        spawnCellY: 60
    )

    override func setUp() {
        super.setUp()
        grid = GridMap()
        floodFill = FloodFill()
        player = Entity(
            id: 1,
            name: "You",
            isBot: false,
            colorHex: SkinPalette.playerDefault.baseHex,
            darkColorHex: SkinPalette.playerDefault.darkHex,
            trailColorHex: SkinPalette.playerDefault.trailHex,
            spawnCellX: 60,
            spawnCellY: 60
        )
        grid.initStarterTerritory(ownerId: 1, centerX: 60, centerY: 60)
    }

    func testCapturesEnclosedNeutralTerritory() {
        // Starter base covers (58...62, 58...62). Draw rectangular loop out to (66, 60)->(66, 66)->(60, 66)->(60, 63)
        for gx in 63...66 { player.trail.append(gx: gx, gy: 60) }
        for gy in 61...66 { player.trail.append(gx: 66, gy: gy) }
        for gx in stride(from: 65, through: 60, by: -1) { player.trail.append(gx: gx, gy: 66) }
        for gy in stride(from: 65, through: 63, by: -1) { player.trail.append(gx: 60, gy: gy) }

        let result = floodFill.closeLoopAndCapture(grid: grid, entity: player)

        XCTAssertGreaterThan(result.capturedCellCount, 15)
        XCTAssertEqual(grid.owner(at: 64, gy: 64), 1)
        XCTAssertEqual(grid.owner(at: 61, gy: 64), 1)
        XCTAssertTrue(player.trail.isEmpty)
    }

    func testClaimsEnclosedRivalTerritoryInsideLoop() {
        grid.setOwner(2, at: 63, gy: 63)
        grid.setOwner(2, at: 64, gy: 64)
        XCTAssertEqual(grid.countCells(for: 2), 2)

        for gx in 63...66 { player.trail.append(gx: gx, gy: 60) }
        for gy in 61...66 { player.trail.append(gx: 66, gy: gy) }
        for gx in stride(from: 65, through: 60, by: -1) { player.trail.append(gx: gx, gy: 66) }
        for gy in stride(from: 65, through: 63, by: -1) { player.trail.append(gx: 60, gy: gy) }

        floodFill.closeLoopAndCapture(grid: grid, entity: player)

        XCTAssertEqual(grid.owner(at: 63, gy: 63), 1)
        XCTAssertEqual(grid.owner(at: 64, gy: 64), 1)
        XCTAssertEqual(grid.countCells(for: 2), 0)
    }

    func testOpenLoopDoesNotOverflowIntoExterior() {
        // Leave a 1-cell gap at (60, 63) so the loop is NOT sealed against starter base
        for gx in 63...66 { player.trail.append(gx: gx, gy: 60) }
        for gy in 61...66 { player.trail.append(gx: 66, gy: gy) }
        for gx in stride(from: 65, through: 60, by: -1) { player.trail.append(gx: gx, gy: 66) }
        player.trail.append(gx: 60, gy: 65)
        player.trail.append(gx: 60, gy: 64)

        let countBefore = grid.countCells(for: 1)
        let trailLength = player.trail.count
        let result = floodFill.closeLoopAndCapture(grid: grid, entity: player)

        // Only trail cells themselves should be stamped; interior cell (64, 64) must remain neutral
        XCTAssertEqual(result.capturedCellCount, trailLength)
        XCTAssertEqual(grid.countCells(for: 1), countBefore + trailLength)
        XCTAssertEqual(grid.owner(at: 64, gy: 64), GameConfig.neutralOwnerId)
    }

    func testCapturesConcaveTerritoryPocketOutsideTrailBounds() {
        for gx in 50...62 {
            grid.setOwner(1, at: gx, gy: 50)
            grid.setOwner(1, at: gx, gy: 70)
        }
        for gy in 50...70 {
            grid.setOwner(1, at: 50, gy: gy)
        }

        for gy in 51...69 {
            player.trail.append(gx: 62, gy: gy)
        }

        floodFill.closeLoopAndCapture(grid: grid, entity: player)

        XCTAssertEqual(grid.owner(at: 55, gy: 60), 1)
        XCTAssertEqual(grid.owner(at: 48, gy: 60), GameConfig.neutralOwnerId)
        XCTAssertEqual(grid.owner(at: 64, gy: 60), GameConfig.neutralOwnerId)
    }
}
