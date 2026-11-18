import Foundation

/// Preallocated active trail for a single entity with O(1) cell membership queries via generation stamps.
final class Trail {
    private(set) var points: [GridPoint] = []
    private(set) var bounds: GridRect = .empty

    private let gridWidth: Int
    private let gridHeight: Int
    private var stampGenerations: [UInt32]
    private var currentGeneration: UInt32 = 1

    var isEmpty: Bool {
        points.isEmpty
    }

    var count: Int {
        points.count
    }

    init(gridWidth: Int = GameConfig.gridSize, gridHeight: Int = GameConfig.gridSize) {
        self.gridWidth = gridWidth
        self.gridHeight = gridHeight
        self.stampGenerations = [UInt32](repeating: 0, count: gridWidth * gridHeight)
        self.points.reserveCapacity(512)
    }

    func contains(gx: Int, gy: Int) -> Bool {
        guard gx >= 0, gx < gridWidth, gy >= 0, gy < gridHeight else {
            return false
        }
        return stampGenerations[gy * gridWidth + gx] == currentGeneration
    }

    @discardableResult
    func append(gx: Int, gy: Int) -> Bool {
        guard gx >= 0, gx < gridWidth, gy >= 0, gy < gridHeight else {
            return false
        }
        let idx = gy * gridWidth + gx
        guard stampGenerations[idx] != currentGeneration else {
            return false
        }
        stampGenerations[idx] = currentGeneration
        points.append(GridPoint(gx: gx, gy: gy))
        bounds.include(gx: gx, gy: gy)
        return true
    }

    func clear() {
        points.removeAll(keepingCapacity: true)
        bounds = .empty
        if currentGeneration == UInt32.max {
            stampGenerations.withUnsafeMutableBufferPointer { buffer in
                buffer.initialize(repeating: 0)
            }
            currentGeneration = 1
        } else {
            currentGeneration &+= 1
        }
    }
}
