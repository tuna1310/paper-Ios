@testable import PaperTerritory
import XCTest

final class GridMapTests: XCTestCase {
    func testInitializes120By120NeutralGrid() {
        let grid = GridMap()
        XCTAssertEqual(grid.width, 120)
        XCTAssertEqual(grid.height, 120)
        XCTAssertEqual(grid.totalPlayableCells, 14_400)
        XCTAssertTrue(grid.isInsideBounds(gx: 0, gy: 0))
        XCTAssertTrue(grid.isInsideBounds(gx: 119, gy: 119))
        XCTAssertFalse(grid.isInsideBounds(gx: -1, gy: 0))
        XCTAssertFalse(grid.isInsideBounds(gx: 120, gy: 120))
        XCTAssertEqual(grid.owner(at: 60, gy: 60), GameConfig.neutralOwnerId)
    }

    func testStarterTerritoryClaims5By5Patch() {
        let grid = GridMap()
        let claimed = grid.initStarterTerritory(ownerId: 1, centerX: 60, centerY: 60)
        XCTAssertEqual(claimed, 25)
        XCTAssertEqual(grid.countCells(for: 1), 25)
        XCTAssertEqual(grid.owner(at: 58, gy: 58), 1)
        XCTAssertEqual(grid.owner(at: 62, gy: 62), 1)
        XCTAssertEqual(grid.owner(at: 57, gy: 60), GameConfig.neutralOwnerId)
        XCTAssertEqual(grid.percentage(for: 1), (25.0 / 14_400.0) * 100.0, accuracy: 0.0001)
    }

    func testDirtyRectTracksAndClearsChanges() {
        let grid = GridMap()
        _ = grid.consumeDirtyRect()

        XCTAssertTrue(grid.setOwner(1, at: 10, gy: 12))
        XCTAssertTrue(grid.setOwner(1, at: 15, gy: 20))
        let dirty = grid.consumeDirtyRect()
        XCTAssertEqual(dirty, GridRect(minX: 10, minY: 12, maxX: 15, maxY: 20))
        XCTAssertTrue(grid.consumeDirtyRect().isEmpty)
    }

    func testClearTerritoryResetsOwnerToNeutral() {
        let grid = GridMap()
        grid.initStarterTerritory(ownerId: 2, centerX: 40, centerY: 40)
        XCTAssertEqual(grid.countCells(for: 2), 25)

        let cleared = grid.clearTerritory(for: 2)
        XCTAssertEqual(cleared, 25)
        XCTAssertEqual(grid.countCells(for: 2), 0)
        XCTAssertEqual(grid.owner(at: 40, gy: 40), GameConfig.neutralOwnerId)
    }

    func testTerritoryTextureRendererUpdatesOnDirtyGrid() {
        let grid = GridMap()
        grid.initStarterTerritory(ownerId: 1, centerX: 60, centerY: 60)
        let renderer = TerritoryTextureRenderer()
        renderer.registerPalette(ownerId: 1, baseHex: 0xFF_2A_6D, darkHex: 0xC8_13_4E)

        XCTAssertTrue(renderer.syncIfDirty(grid: grid))
        XCTAssertFalse(renderer.syncIfDirty(grid: grid))
    }
}
