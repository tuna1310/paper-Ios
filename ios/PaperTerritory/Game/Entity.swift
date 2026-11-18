import Foundation

/// Outcome produced while advancing an entity along grid cell centers during a simulation step.
struct EntityStepOutcome: Sendable {
    var hitBoundary: Bool = false
    var enteredSelfTrail: Bool = false
    var closedLoop: Bool = false
    var enteredNewCell: Bool = false
}

/// Playable or AI-controlled square block entity moving across the 120x120 grid.
final class Entity {
    let id: UInt8
    var name: String
    let isBot: Bool
    var colorHex: UInt32
    var darkColorHex: UInt32
    var trailColorHex: UInt32

    var posX: Double
    var posY: Double
    var direction: Direction
    var speedCellsPerSecond: Double
    var inputQueue = InputQueue()
    let trail: Trail

    var isAlive: Bool = true
    var kills: Int = 0
    var respawnTimer: Double = 0

    var cellX: Int { Int(floor(posX)) }
    var cellY: Int { Int(floor(posY)) }

    init(
        id: UInt8,
        name: String,
        isBot: Bool,
        colorHex: UInt32,
        darkColorHex: UInt32,
        trailColorHex: UInt32,
        spawnCellX: Int,
        spawnCellY: Int,
        initialDirection: Direction = .right,
        speedCellsPerSecond: Double = GameConfig.moveSpeedCellsPerSecond,
        gridWidth: Int = GameConfig.gridSize,
        gridHeight: Int = GameConfig.gridSize
    ) {
        self.id = id
        self.name = name
        self.isBot = isBot
        self.colorHex = colorHex
        self.darkColorHex = darkColorHex
        self.trailColorHex = trailColorHex
        self.posX = Double(spawnCellX) + 0.5
        self.posY = Double(spawnCellY) + 0.5
        self.direction = initialDirection
        self.speedCellsPerSecond = speedCellsPerSecond
        self.trail = Trail(gridWidth: gridWidth, gridHeight: gridHeight)
    }

    @discardableResult
    func enqueueTurn(_ newDirection: Direction) -> Bool {
        inputQueue.enqueue(newDirection, currentDirection: direction)
    }

    /// Advances continuous position across grid cell centers, applying buffered turns cleanly at cell centers.
    func advance(
        by distanceCells: Double,
        grid: GridMap,
        edgeRule: EdgeRule,
        onLoopClosure: ((Entity) -> Void)? = nil
    ) -> EntityStepOutcome {
        var outcome = EntityStepOutcome()
        guard isAlive, distanceCells > 0 else { return outcome }

        var remaining = distanceCells
        let epsilon = 1e-7
        var iterations = 0

        while remaining > 1e-9 && iterations < 256 {
            iterations += 1

            let activeCoord = direction.dx != 0 ? posX : posY
            let nearestCenter = (activeCoord - 0.5).rounded() + 0.5
            if abs(activeCoord - nearestCenter) <= epsilon {
                if let nextDir = inputQueue.popNextValid(currentDirection: direction) {
                    snapToNearestCellCenter(grid: grid)
                    direction = nextDir
                }
            }

            let coord = direction.dx != 0 ? posX : posY
            let sign = Double(direction.dx != 0 ? direction.dx : direction.dy)
            let maxBound = Double(direction.dx != 0 ? grid.width : grid.height)

            let currentCenter = (coord - 0.5).rounded() + 0.5
            let targetCenter: Double
            if sign > 0 {
                targetCenter = coord < currentCenter - epsilon ? currentCenter : currentCenter + 1.0
            } else {
                targetCenter = coord > currentCenter + epsilon ? currentCenter : currentCenter - 1.0
            }

            // Check arena wall boundary before moving past the outermost cell center
            if targetCenter < 0.5 - epsilon || targetCenter > maxBound - 0.5 + epsilon {
                if edgeRule == .block {
                    snapAxis(to: sign > 0 ? maxBound - 0.5 : 0.5)
                    if let nextDir = inputQueue.popNextValid(currentDirection: direction) {
                        direction = nextDir
                        continue
                    }
                    return outcome
                }
                let wallEdge = sign > 0 ? maxBound : 0.0
                let distToWall = max(0.0, abs(wallEdge - coord))
                if remaining >= distToWall - epsilon {
                    posX += Double(direction.dx) * distToWall
                    posY += Double(direction.dy) * distToWall
                    outcome.hitBoundary = true
                    return outcome
                }
                posX += Double(direction.dx) * remaining
                posY += Double(direction.dy) * remaining
                return outcome
            }

            let distToTarget = abs(targetCenter - coord)
            let step = min(remaining, distToTarget)
            posX += Double(direction.dx) * step
            posY += Double(direction.dy) * step
            remaining -= step

            if step >= distToTarget - epsilon {
                snapAxis(to: targetCenter)
                outcome.enteredNewCell = true

                let gx = min(max(0, Int((posX - 0.5).rounded())), grid.width - 1)
                let gy = min(max(0, Int((posY - 0.5).rounded())), grid.height - 1)

                if grid.owner(at: gx, gy: gy) == id {
                    if !trail.isEmpty {
                        outcome.closedLoop = true
                        onLoopClosure?(self)
                    }
                } else {
                    if trail.contains(gx: gx, gy: gy) {
                        outcome.enteredSelfTrail = true
                        return outcome
                    }
                    trail.append(gx: gx, gy: gy)
                }

                if let nextDir = inputQueue.popNextValid(currentDirection: direction) {
                    posX = Double(gx) + 0.5
                    posY = Double(gy) + 0.5
                    direction = nextDir
                }
            }
        }

        return outcome
    }

    func resetForRespawn(
        spawnCellX: Int,
        spawnCellY: Int,
        initialDirection: Direction
    ) {
        posX = Double(spawnCellX) + 0.5
        posY = Double(spawnCellY) + 0.5
        direction = initialDirection
        inputQueue.clear()
        trail.clear()
        isAlive = true
        respawnTimer = 0
    }

    private func snapToNearestCellCenter(grid: GridMap) {
        let gx = min(max(0, Int((posX - 0.5).rounded())), grid.width - 1)
        let gy = min(max(0, Int((posY - 0.5).rounded())), grid.height - 1)
        posX = Double(gx) + 0.5
        posY = Double(gy) + 0.5
    }

    private func snapAxis(to value: Double) {
        if direction.dx != 0 {
            posX = value
        } else {
            posY = value
        }
    }
}
