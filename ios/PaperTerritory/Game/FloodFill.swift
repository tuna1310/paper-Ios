import Foundation

/// Zero-allocation exterior BFS flood fill for capturing enclosed neutral and rival territory.
/// Uses a virtual 1-cell exterior halo around `(territoryBounds union trailBounds)` so open loops never overflow.
final class FloodFill {
    private let paddedStride: Int
    private var visited: [UInt8]
    private var queue: [Int32]
    private var visitToken: UInt8 = 1

    init(gridWidth: Int = GameConfig.gridSize, gridHeight: Int = GameConfig.gridSize) {
        let paddedWidth = gridWidth + 2
        let paddedHeight = gridHeight + 2
        let capacity = paddedWidth * paddedHeight
        self.paddedStride = paddedWidth
        self.visited = [UInt8](repeating: 0, count: capacity)
        self.queue = [Int32](repeating: 0, count: capacity)
    }

    /// Stamps `entity`'s active trail onto `grid`, fills all enclosed interior cells, and clears the trail.
    @discardableResult
    func closeLoopAndCapture(grid: GridMap, entity: Entity) -> CaptureResult {
        guard !entity.trail.isEmpty else {
            return .empty(ownerId: entity.id)
        }

        let ownerId = entity.id
        var capturedCount = 0
        var capturedBounds = GridRect.empty

        stampTrail(entity.trail, ownerId: ownerId, grid: grid, count: &capturedCount, bounds: &capturedBounds)
        let unionBox = grid.bounds(for: ownerId).union(entity.trail.bounds)
        entity.trail.clear()

        guard !unionBox.isEmpty else {
            return .empty(ownerId: ownerId)
        }

        let searchBox = GridRect(
            minX: max(-1, unionBox.minX - 1),
            minY: max(-1, unionBox.minY - 1),
            maxX: min(grid.width, unionBox.maxX + 1),
            maxY: min(grid.height, unionBox.maxY + 1)
        )

        advanceVisitToken()
        runExteriorBFS(searchBox: searchBox, ownerId: ownerId, grid: grid)
        claimUnvisitedCells(
            searchBox: searchBox,
            ownerId: ownerId,
            grid: grid,
            count: &capturedCount,
            bounds: &capturedBounds
        )

        return CaptureResult(ownerId: ownerId, capturedCellCount: capturedCount, capturedBounds: capturedBounds)
    }

    private func stampTrail(
        _ trail: Trail,
        ownerId: UInt8,
        grid: GridMap,
        count: inout Int,
        bounds: inout GridRect
    ) {
        for point in trail.points where grid.isInsideBounds(gx: point.gx, gy: point.gy) {
            if grid.setOwner(ownerId, at: point.gx, gy: point.gy) {
                count += 1
                bounds.include(gx: point.gx, gy: point.gy)
            }
        }
    }

    private func runExteriorBFS(searchBox: GridRect, ownerId: UInt8, grid: GridMap) {
        let token = visitToken
        var qHead = 0
        var qTail = 0

        @inline(__always)
        func tryEnqueue(_ gx: Int, _ gy: Int) {
            let idx = (gy + 1) * paddedStride + (gx + 1)
            let passable = !grid.isInsideBounds(gx: gx, gy: gy) || grid.owner(at: gx, gy: gy) != ownerId
            if visited[idx] != token && passable {
                visited[idx] = token
                queue[qTail] = Int32(((gy + 1) << 16) | ((gx + 1) & 0xFFFF))
                qTail += 1
            }
        }

        for gx in searchBox.minX...searchBox.maxX {
            tryEnqueue(gx, searchBox.minY)
            tryEnqueue(gx, searchBox.maxY)
        }
        if searchBox.minY + 1 <= searchBox.maxY - 1 {
            for gy in (searchBox.minY + 1)...(searchBox.maxY - 1) {
                tryEnqueue(searchBox.minX, gy)
                tryEnqueue(searchBox.maxX, gy)
            }
        }

        while qHead < qTail {
            let packed = Int(queue[qHead])
            qHead += 1
            let gy = (packed >> 16) - 1
            let gx = (packed & 0xFFFF) - 1

            if gx + 1 <= searchBox.maxX { tryEnqueue(gx + 1, gy) }
            if gx - 1 >= searchBox.minX { tryEnqueue(gx - 1, gy) }
            if gy + 1 <= searchBox.maxY { tryEnqueue(gx, gy + 1) }
            if gy - 1 >= searchBox.minY { tryEnqueue(gx, gy - 1) }
        }
    }

    private func claimUnvisitedCells(
        searchBox: GridRect,
        ownerId: UInt8,
        grid: GridMap,
        count: inout Int,
        bounds: inout GridRect
    ) {
        let minX = max(0, searchBox.minX)
        let maxX = min(grid.width - 1, searchBox.maxX)
        let minY = max(0, searchBox.minY)
        let maxY = min(grid.height - 1, searchBox.maxY)
        guard minX <= maxX, minY <= maxY else { return }

        let token = visitToken
        for gy in minY...maxY {
            let rowOffset = (gy + 1) * paddedStride
            for gx in minX...maxX {
                guard visited[rowOffset + gx + 1] != token, grid.owner(at: gx, gy: gy) != ownerId else {
                    continue
                }
                if grid.setOwner(ownerId, at: gx, gy: gy) {
                    count += 1
                    bounds.include(gx: gx, gy: gy)
                }
            }
        }
    }

    private func advanceVisitToken() {
        if visitToken == UInt8.max {
            visited.withUnsafeMutableBufferPointer { buffer in
                buffer.initialize(repeating: 0)
            }
            visitToken = 1
        } else {
            visitToken &+= 1
        }
    }
}
