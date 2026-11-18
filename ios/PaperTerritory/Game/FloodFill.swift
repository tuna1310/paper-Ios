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

        // 1. Stamp trail cells onto grid
        for point in entity.trail.points where grid.isInsideBounds(gx: point.gx, gy: point.gy) {
            if grid.setOwner(ownerId, at: point.gx, gy: point.gy) {
                capturedCount += 1
                capturedBounds.include(gx: point.gx, gy: point.gy)
            }
        }

        let unionBox = grid.bounds(for: ownerId).union(entity.trail.bounds)
        entity.trail.clear()

        guard !unionBox.isEmpty else {
            return .empty(ownerId: ownerId)
        }

        // 2. Expand box by 1 virtual exterior cell (`-1...grid.width`, `-1...grid.height`)
        let minBx = max(-1, unionBox.minX - 1)
        let maxBx = min(grid.width, unionBox.maxX + 1)
        let minBy = max(-1, unionBox.minY - 1)
        let maxBy = min(grid.height, unionBox.maxY + 1)

        advanceVisitToken()
        let token = visitToken

        var qHead = 0
        var qTail = 0

        @inline(__always)
        func localIndex(gx: Int, gy: Int) -> Int {
            (gy + 1) * paddedStride + (gx + 1)
        }

        @inline(__always)
        func isPassableExterior(gx: Int, gy: Int) -> Bool {
            if !grid.isInsideBounds(gx: gx, gy: gy) {
                return true
            }
            return grid.owner(at: gx, gy: gy) != ownerId
        }

        @inline(__always)
        func tryEnqueue(gx: Int, gy: Int) {
            let idx = localIndex(gx: gx, gy: gy)
            if visited[idx] != token && isPassableExterior(gx: gx, gy: gy) {
                visited[idx] = token
                queue[qTail] = Int32(((gy + 1) << 16) | ((gx + 1) & 0xFFFF))
                qTail += 1
            }
        }

        // 3. Seed perimeter of the expanded box
        for gx in minBx...maxBx {
            tryEnqueue(gx: gx, gy: minBy)
            tryEnqueue(gx: gx, gy: maxBy)
        }
        if minBy + 1 <= maxBy - 1 {
            for gy in (minBy + 1)...(maxBy - 1) {
                tryEnqueue(gx: minBx, gy: gy)
                tryEnqueue(gx: maxBx, gy: gy)
            }
        }

        // 4. Exterior BFS
        while qHead < qTail {
            let packed = Int(queue[qHead])
            qHead += 1
            let gy = (packed >> 16) - 1
            let gx = (packed & 0xFFFF) - 1

            if gx + 1 <= maxBx { tryEnqueue(gx: gx + 1, gy: gy) }
            if gx - 1 >= minBx { tryEnqueue(gx: gx - 1, gy: gy) }
            if gy + 1 <= maxBy { tryEnqueue(gx: gx, gy: gy + 1) }
            if gy - 1 >= minBy { tryEnqueue(gx: gx, gy: gy - 1) }
        }

        // 5. Claim any grid cell inside the box that exterior BFS could not reach
        let innerMinX = max(0, minBx)
        let innerMaxX = min(grid.width - 1, maxBx)
        let innerMinY = max(0, minBy)
        let innerMaxY = min(grid.height - 1, maxBy)

        if innerMinX <= innerMaxX && innerMinY <= innerMaxY {
            for gy in innerMinY...innerMaxY {
                for gx in innerMinX...innerMaxX {
                    let idx = localIndex(gx: gx, gy: gy)
                    if visited[idx] != token && grid.owner(at: gx, gy: gy) != ownerId {
                        if grid.setOwner(ownerId, at: gx, gy: gy) {
                            capturedCount += 1
                            capturedBounds.include(gx: gx, gy: gy)
                        }
                    }
                }
            }
        }

        return CaptureResult(
            ownerId: ownerId,
            capturedCellCount: capturedCount,
            capturedBounds: capturedBounds
        )
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
