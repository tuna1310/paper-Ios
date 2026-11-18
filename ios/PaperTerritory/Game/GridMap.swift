import Foundation

/// Contiguous 120x120 territory ownership map (`0` = neutral, `1...254` = entity IDs).
/// Tracks cell counts, owner bounding boxes, and dirty rects in O(1) without heap allocations.
final class GridMap {
    let width: Int
    let height: Int
    let totalPlayableCells: Int

    private var cells: [UInt8]
    private var cellCounts: [Int]
    private var ownerBounds: [GridRect]
    private(set) var dirtyRect: GridRect = .empty

    init(width: Int = GameConfig.gridSize, height: Int = GameConfig.gridSize) {
        self.width = width
        self.height = height
        self.totalPlayableCells = width * height
        self.cells = [UInt8](repeating: GameConfig.neutralOwnerId, count: width * height)
        self.cellCounts = [Int](repeating: 0, count: 256)
        self.ownerBounds = [GridRect](repeating: .empty, count: 256)
    }

    func isInsideBounds(gx: Int, gy: Int) -> Bool {
        gx >= 0 && gx < width && gy >= 0 && gy < height
    }

    func owner(at gx: Int, gy: Int) -> UInt8 {
        guard isInsideBounds(gx: gx, gy: gy) else {
            return GameConfig.neutralOwnerId
        }
        return cells[gy * width + gx]
    }

    func ownerOrNil(at gx: Int, gy: Int) -> UInt8? {
        guard isInsideBounds(gx: gx, gy: gy) else { return nil }
        return cells[gy * width + gx]
    }

    @discardableResult
    func setOwner(_ ownerId: UInt8, at gx: Int, gy: Int) -> Bool {
        guard isInsideBounds(gx: gx, gy: gy) else { return false }
        let idx = gy * width + gx
        let oldOwner = cells[idx]
        guard oldOwner != ownerId else { return false }

        if oldOwner != GameConfig.neutralOwnerId {
            let oldIdx = Int(oldOwner)
            if cellCounts[oldIdx] > 0 {
                cellCounts[oldIdx] -= 1
                if cellCounts[oldIdx] == 0 {
                    ownerBounds[oldIdx] = .empty
                }
            }
        }

        cells[idx] = ownerId

        if ownerId != GameConfig.neutralOwnerId {
            let newIdx = Int(ownerId)
            cellCounts[newIdx] += 1
            ownerBounds[newIdx].include(gx: gx, gy: gy)
        }

        dirtyRect.include(gx: gx, gy: gy)
        return true
    }

    /// Initializes a `(2 * radius + 1) x (2 * radius + 1)` starter territory (5x5 for `radius = 2`).
    @discardableResult
    func initStarterTerritory(
        ownerId: UInt8,
        centerX: Int,
        centerY: Int,
        radius: Int = GameConfig.starterRadiusCells
    ) -> Int {
        var claimed = 0
        for gy in (centerY - radius)...(centerY + radius) {
            for gx in (centerX - radius)...(centerX + radius) where isInsideBounds(gx: gx, gy: gy) {
                if setOwner(ownerId, at: gx, gy: gy) {
                    claimed += 1
                }
            }
        }
        return claimed
    }

    func countCells(for ownerId: UInt8) -> Int {
        cellCounts[Int(ownerId)]
    }

    func percentage(for ownerId: UInt8) -> Double {
        guard totalPlayableCells > 0 else { return 0 }
        return (Double(cellCounts[Int(ownerId)]) / Double(totalPlayableCells)) * 100.0
    }

    func bounds(for ownerId: UInt8) -> GridRect {
        ownerBounds[Int(ownerId)]
    }

    /// Resets all territory owned by `ownerId` back to neutral (`0`).
    @discardableResult
    func clearTerritory(for ownerId: UInt8) -> Int {
        guard ownerId != GameConfig.neutralOwnerId else { return 0 }
        let ownerIndex = Int(ownerId)
        guard cellCounts[ownerIndex] > 0 else { return 0 }

        let bounds = ownerBounds[ownerIndex]
        var cleared = 0
        if !bounds.isEmpty {
            let minX = max(0, bounds.minX)
            let maxX = min(width - 1, bounds.maxX)
            let minY = max(0, bounds.minY)
            let maxY = min(height - 1, bounds.maxY)

            for gy in minY...maxY {
                let rowOffset = gy * width
                for gx in minX...maxX where cells[rowOffset + gx] == ownerId {
                    cells[rowOffset + gx] = GameConfig.neutralOwnerId
                    dirtyRect.include(gx: gx, gy: gy)
                    cleared += 1
                }
            }
        }

        cellCounts[ownerIndex] = 0
        ownerBounds[ownerIndex] = .empty
        return cleared
    }

    /// Clears all grid cells, counts, and bounds for a fresh match.
    func reset() {
        cells.withUnsafeMutableBufferPointer { buffer in
            buffer.initialize(repeating: GameConfig.neutralOwnerId)
        }
        cellCounts.withUnsafeMutableBufferPointer { buffer in
            buffer.initialize(repeating: 0)
        }
        ownerBounds.withUnsafeMutableBufferPointer { buffer in
            buffer.initialize(repeating: .empty)
        }
        dirtyRect = GridRect(minX: 0, minY: 0, maxX: width - 1, maxY: height - 1)
    }

    func consumeDirtyRect() -> GridRect {
        let rect = dirtyRect
        dirtyRect = .empty
        return rect
    }

    func markAllDirty() {
        dirtyRect = GridRect(minX: 0, minY: 0, maxX: width - 1, maxY: height - 1)
    }
}
