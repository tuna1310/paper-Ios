import Foundation

enum BotIntent {
    case expand
    case retreatHome
    case huntTrail
}

struct BotDifficultyTuning {
    let maxArcBase: Int
    let dangerSenseManhattan: Int
    let huntRadiusManhattan: Int
    let huntProbability: Double

    static func forDifficulty(_ difficulty: BotDifficulty) -> BotDifficultyTuning {
        switch difficulty {
        case .easy:
            return BotDifficultyTuning(
                maxArcBase: 7,
                dangerSenseManhattan: 4,
                huntRadiusManhattan: 6,
                huntProbability: 0.25
            )
        case .normal:
            return BotDifficultyTuning(
                maxArcBase: 10,
                dangerSenseManhattan: 7,
                huntRadiusManhattan: 11,
                huntProbability: 0.65
            )
        case .hard:
            return BotDifficultyTuning(
                maxArcBase: 13,
                dangerSenseManhattan: 11,
                huntRadiusManhattan: 17,
                huntProbability: 0.95
            )
        }
    }
}

struct BotReachabilityResult {
    let openCells: Int
    let reachedHome: Bool
    let stepsToHome: Int?
}

/// Zero-allocation bounded BFS analyzer detecting sealed self-trail pockets and true safe home paths.
final class BotReachabilityAnalyzer {
    static let defaultMaxNodes = 128
    private static let queueCapacity = 512

    private var gridWidth: Int = 0
    private var gridHeight: Int = 0
    private var visitedTokens: [UInt32] = []
    private var currentToken: UInt32 = 1
    private var queueX: [Int32] = Array(repeating: 0, count: queueCapacity)
    private var queueY: [Int32] = Array(repeating: 0, count: queueCapacity)
    private var queueDist: [Int32] = Array(repeating: 0, count: queueCapacity)

    func evaluate(
        from start: GridPoint,
        blockedOrigin: GridPoint,
        bot: Entity,
        grid: GridMap,
        maxNodes: Int = BotReachabilityAnalyzer.defaultMaxNodes
    ) -> BotReachabilityResult {
        guard grid.isInsideBounds(gx: start.gx, gy: start.gy), !bot.trail.contains(gx: start.gx, gy: start.gy) else {
            return BotReachabilityResult(openCells: 0, reachedHome: false, stepsToHome: nil)
        }
        if grid.owner(at: start.gx, gy: start.gy) == bot.id {
            return BotReachabilityResult(openCells: maxNodes, reachedHome: true, stepsToHome: 1)
        }
        if bot.trail.isEmpty {
            return BotReachabilityResult(openCells: maxNodes, reachedHome: false, stepsToHome: nil)
        }

        ensureCapacity(width: grid.width, height: grid.height)
        let token = nextToken()
        let originBlocked = grid.owner(at: blockedOrigin.gx, gy: blockedOrigin.gy) != bot.id
        var qHead = 0
        visitedTokens[start.gy * gridWidth + start.gx] = token
        queueX[0] = Int32(start.gx)
        queueY[0] = Int32(start.gy)
        queueDist[0] = 1
        var state = BfsState(qTail: 1, reachedHome: false, stepsToHome: nil)
        var openCells = 0

        while qHead < state.qTail && openCells < maxNodes {
            let cx = Int(queueX[qHead])
            let cy = Int(queueY[qHead])
            let cd = Int(queueDist[qHead])
            qHead += 1
            openCells += 1

            let overflowed = expandNeighbors(
                from: GridPoint(gx: cx, gy: cy),
                nextDist: cd + 1,
                context: BfsContext(
                    blockedOrigin: originBlocked ? blockedOrigin : nil,
                    bot: bot,
                    grid: grid,
                    token: token
                ),
                state: &state
            )
            if overflowed {
                return BotReachabilityResult(
                    openCells: maxNodes,
                    reachedHome: state.reachedHome,
                    stepsToHome: state.stepsToHome
                )
            }
        }

        return BotReachabilityResult(
            openCells: openCells,
            reachedHome: state.reachedHome,
            stepsToHome: state.stepsToHome
        )
    }

    private struct BfsContext {
        let blockedOrigin: GridPoint?
        let bot: Entity
        let grid: GridMap
        let token: UInt32
    }

    private struct BfsState {
        var qTail: Int
        var reachedHome: Bool
        var stepsToHome: Int?
    }

    private func expandNeighbors(
        from cell: GridPoint,
        nextDist: Int,
        context: BfsContext,
        state: inout BfsState
    ) -> Bool {
        for dir in Direction.allCases {
            let nx = cell.gx + dir.dx
            let ny = cell.gy + dir.dy
            guard context.grid.isInsideBounds(gx: nx, gy: ny) else { continue }
            if let blocked = context.blockedOrigin, nx == blocked.gx && ny == blocked.gy {
                continue
            }
            if context.bot.trail.contains(gx: nx, gy: ny) {
                continue
            }

            if context.grid.owner(at: nx, gy: ny) == context.bot.id {
                state.reachedHome = true
                if state.stepsToHome == nil {
                    state.stepsToHome = nextDist
                }
                continue
            }

            let idx = ny * gridWidth + nx
            guard visitedTokens[idx] != context.token else { continue }
            if state.qTail >= Self.queueCapacity {
                return true
            }
            visitedTokens[idx] = context.token
            queueX[state.qTail] = Int32(nx)
            queueY[state.qTail] = Int32(ny)
            queueDist[state.qTail] = Int32(nextDist)
            state.qTail += 1
        }
        return false
    }

    private func ensureCapacity(width: Int, height: Int) {
        if gridWidth == width && gridHeight == height {
            return
        }
        gridWidth = width
        gridHeight = height
        visitedTokens = [UInt32](repeating: 0, count: width * height)
        currentToken = 1
    }

    private func nextToken() -> UInt32 {
        if currentToken == UInt32.max {
            visitedTokens.withUnsafeMutableBufferPointer { $0.initialize(repeating: 0) }
            currentToken = 1
        } else {
            currentToken &+= 1
        }
        return currentToken
    }
}

/// Grid navigation and trail-targeting queries used by `BotAI`.
enum BotNavigation {
    static func upcomingDecisionCell(for entity: Entity, grid: GridMap) -> GridPoint {
        let epsilon = 1e-6
        let activeCoord = entity.direction.dx != 0 ? entity.posX : entity.posY
        let nearestCenter = (activeCoord - 0.5).rounded() + 0.5

        var gx = min(max(0, Int((entity.posX - 0.5).rounded())), grid.width - 1)
        var gy = min(max(0, Int((entity.posY - 0.5).rounded())), grid.height - 1)

        if abs(activeCoord - nearestCenter) > epsilon {
            let sign = Double(entity.direction.dx != 0 ? entity.direction.dx : entity.direction.dy)
            if sign > 0 && activeCoord > nearestCenter + epsilon {
                gx = min(grid.width - 1, gx + entity.direction.dx)
                gy = min(grid.height - 1, gy + entity.direction.dy)
            } else if sign < 0 && activeCoord < nearestCenter - epsilon {
                gx = max(0, gx + entity.direction.dx)
                gy = max(0, gy + entity.direction.dy)
            }
        }
        return GridPoint(gx: gx, gy: gy)
    }

    static func findNearestOwnedCell(for ownerId: UInt8, from origin: GridPoint, grid: GridMap) -> GridPoint? {
        let bounds = grid.bounds(for: ownerId)
        guard !bounds.isEmpty else { return nil }
        if grid.owner(at: origin.gx, gy: origin.gy) == ownerId {
            return origin
        }

        for radius in 1...30 {
            if let hit = ownedCellAtManhattanRadius(
                radius,
                ownerId: ownerId,
                origin: origin,
                bounds: bounds,
                grid: grid
            ) {
                return hit
            }
        }

        return GridPoint(gx: (bounds.minX + bounds.maxX) / 2, gy: (bounds.minY + bounds.maxY) / 2)
    }

    private static func ownedCellAtManhattanRadius(
        _ radius: Int,
        ownerId: UInt8,
        origin: GridPoint,
        bounds: GridRect,
        grid: GridMap
    ) -> GridPoint? {
        for dx in (-radius)...radius {
            let rem = radius - abs(dx)
            let gx = origin.gx + dx
            guard gx >= bounds.minX && gx <= bounds.maxX else { continue }

            let upperY = origin.gy + rem
            if upperY >= bounds.minY && upperY <= bounds.maxY, grid.owner(at: gx, gy: upperY) == ownerId {
                return GridPoint(gx: gx, gy: upperY)
            }
            if rem > 0 {
                let lowerY = origin.gy - rem
                if lowerY >= bounds.minY && lowerY <= bounds.maxY, grid.owner(at: gx, gy: lowerY) == ownerId {
                    return GridPoint(gx: gx, gy: lowerY)
                }
            }
        }
        return nil
    }

    static func findNearestExposedTrail(
        for bot: Entity,
        from origin: GridPoint,
        maxManhattan: Int,
        allEntities: [Entity]
    ) -> GridPoint? {
        var bestPoint: GridPoint?
        var bestScore = Double.greatestFiniteMagnitude
        for other in allEntities where other.id != bot.id && other.isAlive && !other.trail.isEmpty {
            let points = other.trail.points
            let playerBias = other.isBot ? 1.0 : 0.7
            for idx in stride(from: 0, to: points.count, by: 2) {
                let pt = points[idx]
                let dist = abs(pt.gx - origin.gx) + abs(pt.gy - origin.gy)
                if dist <= maxManhattan && Double(dist) * playerBias < bestScore {
                    bestScore = Double(dist) * playerBias
                    bestPoint = pt
                }
            }
        }
        return bestPoint
    }

    static func countOtherTrailNeighbors(around cell: GridPoint, excluding origin: GridPoint, bot: Entity) -> Int {
        var count = 0
        for dir in Direction.allCases {
            let nx = cell.gx + dir.dx
            let ny = cell.gy + dir.dy
            if nx == origin.gx && ny == origin.gy {
                continue
            }
            if bot.trail.contains(gx: nx, gy: ny) {
                count += 1
            }
        }
        return count
    }

    static func countSafeExits(from point: GridPoint, heading: Direction, bot: Entity, grid: GridMap) -> Int {
        var exits = 0
        let cw = heading.rotatedClockwise
        let ccw = heading.rotatedCounterClockwise
        if isCellPassable(gx: point.gx + heading.dx, gy: point.gy + heading.dy, bot: bot, grid: grid) {
            exits += 1
        }
        if isCellPassable(gx: point.gx + cw.dx, gy: point.gy + cw.dy, bot: bot, grid: grid) {
            exits += 1
        }
        if isCellPassable(gx: point.gx + ccw.dx, gy: point.gy + ccw.dy, bot: bot, grid: grid) {
            exits += 1
        }
        return exits
    }

    static func forwardCorridorDepth(
        from point: GridPoint,
        heading: Direction,
        maxSteps: Int,
        bot: Entity,
        grid: GridMap
    ) -> Int {
        var depth = 0
        var cx = point.gx
        var cy = point.gy
        for _ in 0..<maxSteps {
            cx += heading.dx
            cy += heading.dy
            guard isCellPassable(gx: cx, gy: cy, bot: bot, grid: grid) else {
                break
            }
            depth += 1
        }
        return depth
    }

    private static func isCellPassable(gx: Int, gy: Int, bot: Entity, grid: GridMap) -> Bool {
        grid.isInsideBounds(gx: gx, gy: gy) && !bot.trail.contains(gx: gx, gy: gy)
    }
}
