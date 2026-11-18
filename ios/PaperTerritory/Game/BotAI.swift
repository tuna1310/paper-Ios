import Foundation

/// Zero-allocation AI brain driving 10–15 bots with short-arc expansion, trail hunting,
/// self-trail & dead-end avoidance, panic retreat home, and empty-area respawn.
final class BotAI {
    private enum Intent { case expand, retreatHome, huntTrail }

    private struct BrainState {
        var turnClockwise: Bool
        var maxArcCells: Int
        var legLengthTarget: Int
        var stepsOnCurrentLeg: Int
        var lastDecidedCell: GridPoint
    }

    private struct DifficultyTuning {
        let maxArcBase: Int
        let dangerSenseManhattan: Int
        let huntRadiusManhattan: Int
        let huntProbability: Double
    }

    private struct DecisionContext {
        let bot: Entity
        let origin: GridPoint
        let intent: Intent
        let target: GridPoint?
        let preferredSide: Direction
        let otherSide: Direction
        let stepsOnLeg: Int
        let legTarget: Int
        let grid: GridMap
        let allEntities: [Entity]
    }

    var difficulty: BotDifficulty
    private var rng: SeededRandomGenerator
    private var brains: [UInt8: BrainState] = [:]

    init(difficulty: BotDifficulty = .normal, seed: UInt64 = 0x5041_5045_5231) {
        self.difficulty = difficulty
        self.rng = SeededRandomGenerator(seed: seed)
    }

    func reset(bots: [Entity]) {
        brains.removeAll(keepingCapacity: true)
        for bot in bots {
            registerBot(bot)
        }
    }

    func registerBot(_ bot: Entity) {
        let tuning = tuningForDifficulty()
        let arcVariance = Int.random(in: -2...3, using: &rng)
        let legLen = Int.random(in: 3...6, using: &rng)
        brains[bot.id] = BrainState(
            turnClockwise: Bool.random(using: &rng),
            maxArcCells: max(5, tuning.maxArcBase + arcVariance),
            legLengthTarget: legLen,
            stepsOnCurrentLeg: 0,
            lastDecidedCell: GridPoint(gx: -1, gy: -1)
        )
    }

    func update(dt: Double, bots: [Entity], allEntities: [Entity], grid: GridMap) {
        let tuning = tuningForDifficulty()

        for bot in bots {
            if !bot.isAlive {
                bot.respawnTimer -= dt
                if bot.respawnTimer <= 0 {
                    respawnBot(bot, allEntities: allEntities, grid: grid)
                }
                continue
            }

            let decisionCell = upcomingDecisionCell(for: bot, grid: grid)
            guard var brain = brains[bot.id] else {
                registerBot(bot)
                continue
            }
            guard brain.lastDecidedCell != decisionCell else { continue }

            brain.lastDecidedCell = decisionCell
            brain.stepsOnCurrentLeg += 1

            let insideOwn = grid.owner(at: decisionCell.gx, gy: decisionCell.gy) == bot.id
            if insideOwn && bot.trail.isEmpty {
                brain.stepsOnCurrentLeg = min(brain.stepsOnCurrentLeg, brain.legLengthTarget)
            }

            let (intent, target) = resolveIntentAndTarget(
                bot: bot,
                cell: decisionCell,
                maxArcCells: brain.maxArcCells,
                tuning: tuning,
                grid: grid,
                allEntities: allEntities
            )

            let preferredSide = brain.turnClockwise
                ? bot.direction.rotatedClockwise
                : bot.direction.rotatedCounterClockwise
            let otherSide = brain.turnClockwise
                ? bot.direction.rotatedCounterClockwise
                : bot.direction.rotatedClockwise

            let context = DecisionContext(
                bot: bot,
                origin: decisionCell,
                intent: intent,
                target: target,
                preferredSide: preferredSide,
                otherSide: otherSide,
                stepsOnLeg: brain.stepsOnCurrentLeg,
                legTarget: brain.legLengthTarget,
                grid: grid,
                allEntities: allEntities
            )

            let chosen = pickBestDirection(context: context, brain: &brain)
            if chosen != bot.direction {
                bot.inputQueue.clear()
                bot.enqueueTurn(chosen)
                brain.stepsOnCurrentLeg = 0
                brain.legLengthTarget = Int.random(in: 3...6, using: &rng)
            }
            brains[bot.id] = brain
        }
    }

    // MARK: - Decision Cell & Intent

    private func upcomingDecisionCell(for entity: Entity, grid: GridMap) -> GridPoint {
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

    // swiftlint:disable:next function_parameter_count
    private func resolveIntentAndTarget(
        bot: Entity,
        cell: GridPoint,
        maxArcCells: Int,
        tuning: DifficultyTuning,
        grid: GridMap,
        allEntities: [Entity]
    ) -> (Intent, GridPoint?) {
        let insideOwn = grid.owner(at: cell.gx, gy: cell.gy) == bot.id
        if !insideOwn {
            let threatened = isThreatened(bot: bot, cell: cell, radius: tuning.dangerSenseManhattan, all: allEntities)
            if threatened || bot.trail.count >= maxArcCells {
                return (.retreatHome, findNearestOwnedCell(for: bot.id, from: cell, grid: grid))
            }
        }

        if bot.trail.count < maxArcCells / 2, Double.random(in: 0..<1, using: &rng) < tuning.huntProbability {
            if let prey = findNearestExposedTrail(
                for: bot,
                from: cell,
                maxManhattan: tuning.huntRadiusManhattan,
                allEntities: allEntities
            ) {
                return (.huntTrail, prey)
            }
        }

        return (.expand, nil)
    }

    private func isThreatened(bot: Entity, cell: GridPoint, radius: Int, all: [Entity]) -> Bool {
        for other in all where other.id != bot.id && other.isAlive {
            if abs(other.cellX - cell.gx) + abs(other.cellY - cell.gy) <= radius {
                return true
            }
            if !bot.trail.isEmpty && isTrailNearEnemy(bot.trail.points, enemy: other, sense: max(3, radius - 2)) {
                return true
            }
        }
        return false
    }

    private func isTrailNearEnemy(_ points: [GridPoint], enemy: Entity, sense: Int) -> Bool {
        for idx in stride(from: 0, to: points.count, by: 2) {
            let pt = points[idx]
            if abs(enemy.cellX - pt.gx) + abs(enemy.cellY - pt.gy) <= sense {
                return true
            }
        }
        return false
    }

    // MARK: - Direction Scoring & Dead-End Avoidance

    private func pickBestDirection(context: DecisionContext, brain: inout BrainState) -> Direction {
        let candidates = [context.bot.direction, context.preferredSide, context.otherSide]
        var bestDir = context.bot.direction
        var bestScore = -1_000_000

        for dir in candidates {
            let nx = context.origin.gx + dir.dx
            let ny = context.origin.gy + dir.dy
            guard context.grid.isInsideBounds(gx: nx, gy: ny), !context.bot.trail.contains(gx: nx, gy: ny) else {
                continue
            }

            let nextCell = GridPoint(gx: nx, gy: ny)
            let score = scoreSafety(dir: dir, nextCell: nextCell, context: context)
                + scoreCombat(nextCell: nextCell, context: context)
                + scoreSteering(dir: dir, nextCell: nextCell, context: context)

            if score > bestScore {
                bestScore = score
                bestDir = dir
            }
        }

        if bestScore == -1_000_000 {
            for dir in candidates {
                if context.grid.isInsideBounds(gx: context.origin.gx + dir.dx, gy: context.origin.gy + dir.dy) {
                    return dir
                }
            }
        }

        if bestDir == context.otherSide && context.stepsOnLeg >= context.legTarget {
            brain.turnClockwise.toggle()
        }
        return bestDir
    }

    private func scoreSafety(dir: Direction, nextCell: GridPoint, context: DecisionContext) -> Int {
        let nextIsOwn = context.grid.owner(at: nextCell.gx, gy: nextCell.gy) == context.bot.id
        var score = 0

        if nextIsOwn {
            score += (context.intent == .retreatHome) ? 1_500 : 0
        } else {
            let exits = countSafeExits(from: nextCell, heading: dir, bot: context.bot, grid: context.grid)
            if exits == 0 {
                score -= 20_000
            } else if exits == 1 {
                score -= 3_500
            }

            let pinchCount = countOtherTrailNeighbors(around: nextCell, excluding: context.origin, bot: context.bot)
            if pinchCount >= 2 {
                score -= 5_000
            } else if pinchCount == 1 {
                score -= 250
            }

            let depth = forwardCorridorDepth(
                from: nextCell,
                heading: dir,
                maxSteps: 5,
                bot: context.bot,
                grid: context.grid
            )
            score += depth * 40
        }

        if nextCell.gx <= 1 || nextCell.gx >= context.grid.width - 2 ||
            nextCell.gy <= 1 || nextCell.gy >= context.grid.height - 2 {
            score -= 120
        }
        return score
    }

    private func scoreCombat(nextCell: GridPoint, context: DecisionContext) -> Int {
        var score = 0
        let botCells = context.grid.countCells(for: context.bot.id)
        for other in context.allEntities where other.id != context.bot.id && other.isAlive {
            if other.trail.contains(gx: nextCell.gx, gy: nextCell.gy) {
                score += other.isBot ? 600 : 1_100
            }
            let headDist = abs(other.cellX - nextCell.gx) + abs(other.cellY - nextCell.gy)
            if headDist <= 1 && context.grid.countCells(for: other.id) >= botCells {
                score -= 900
            }
        }
        return score
    }

    private func scoreSteering(dir: Direction, nextCell: GridPoint, context: DecisionContext) -> Int {
        if let target = context.target {
            let curDist = abs(context.origin.gx - target.gx) + abs(context.origin.gy - target.gy)
            let nextDist = abs(nextCell.gx - target.gx) + abs(nextCell.gy - target.gy)
            return (curDist - nextDist) * 260
        }

        var score = 0
        if context.stepsOnLeg >= context.legTarget {
            if dir == context.preferredSide {
                score += 240
            } else if dir == context.otherSide {
                score += 140
            }
        } else if dir == context.bot.direction {
            score += 180
        }

        if context.grid.owner(at: nextCell.gx, gy: nextCell.gy) != context.bot.id {
            score += 80
        }
        return score
    }

    private func countOtherTrailNeighbors(around cell: GridPoint, excluding origin: GridPoint, bot: Entity) -> Int {
        var count = 0
        for dir in Direction.allCases {
            let nx = cell.gx + dir.dx
            let ny = cell.gy + dir.dy
            if nx == origin.gx && ny == origin.gy { continue }
            if bot.trail.contains(gx: nx, gy: ny) { count += 1 }
        }
        return count
    }

    private func countSafeExits(from point: GridPoint, heading: Direction, bot: Entity, grid: GridMap) -> Int {
        var exits = 0
        for dir in [heading, heading.rotatedClockwise, heading.rotatedCounterClockwise] {
            let cx = point.gx + dir.dx
            let cy = point.gy + dir.dy
            if grid.isInsideBounds(gx: cx, gy: cy) && !bot.trail.contains(gx: cx, gy: cy) { exits += 1 }
        }
        return exits
    }

    private func forwardCorridorDepth(
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
            guard grid.isInsideBounds(gx: cx, gy: cy), !bot.trail.contains(gx: cx, gy: cy) else { break }
            depth += 1
        }
        return depth
    }

    // MARK: - Spatial Queries & Respawn

    private func findNearestOwnedCell(for ownerId: UInt8, from origin: GridPoint, grid: GridMap) -> GridPoint? {
        let bounds = grid.bounds(for: ownerId)
        guard !bounds.isEmpty else { return nil }
        let minX = max(bounds.minX, origin.gx - 30)
        let maxX = min(bounds.maxX, origin.gx + 30)
        let minY = max(bounds.minY, origin.gy - 30)
        let maxY = min(bounds.maxY, origin.gy + 30)

        var bestPoint: GridPoint?
        var bestDist = Int.max
        if minX <= maxX && minY <= maxY {
            for gy in minY...maxY {
                for gx in minX...maxX where grid.owner(at: gx, gy: gy) == ownerId {
                    let dist = abs(gx - origin.gx) + abs(gy - origin.gy)
                    if dist < bestDist {
                        bestDist = dist
                        bestPoint = GridPoint(gx: gx, gy: gy)
                    }
                }
            }
        }
        return bestPoint ?? GridPoint(gx: (bounds.minX + bounds.maxX) / 2, gy: (bounds.minY + bounds.maxY) / 2)
    }

    private func findNearestExposedTrail(
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

    private func respawnBot(_ bot: Entity, allEntities: [Entity], grid: GridMap) {
        let margin = GameConfig.botSpawnBorderMarginCells
        let maxCoordX = max(margin + 1, grid.width - 1 - margin)
        let maxCoordY = max(margin + 1, grid.height - 1 - margin)

        var chosenPoint: GridPoint?
        for requireNeutral in [true, false] where chosenPoint == nil {
            let attempts = requireNeutral ? 40 : 25
            for _ in 0..<attempts {
                let gx = Int.random(in: margin...maxCoordX, using: &rng)
                let gy = Int.random(in: margin...maxCoordY, using: &rng)
                if isSafeSpawnPatch(
                    gx: gx,
                    gy: gy,
                    allEntities: allEntities,
                    grid: grid,
                    requireAllNeutral: requireNeutral
                ) {
                    chosenPoint = GridPoint(gx: gx, gy: gy)
                    break
                }
            }
        }

        let spawn = chosenPoint ?? GridPoint(gx: grid.width / 2, gy: grid.height / 2)
        let initialDir = Direction.allCases[Int.random(in: 0..<Direction.allCases.count, using: &rng)]
        grid.initStarterTerritory(ownerId: bot.id, centerX: spawn.gx, centerY: spawn.gy)
        bot.resetForRespawn(spawnCellX: spawn.gx, spawnCellY: spawn.gy, initialDirection: initialDir)
        registerBot(bot)
    }

    private func isSafeSpawnPatch(
        gx: Int,
        gy: Int,
        allEntities: [Entity],
        grid: GridMap,
        requireAllNeutral: Bool
    ) -> Bool {
        let radius = GameConfig.starterRadiusCells
        let minClear = GameConfig.botSpawnMinClearanceCells
        for other in allEntities where other.isAlive {
            if abs(other.cellX - gx) + abs(other.cellY - gy) < minClear { return false }
        }
        if requireAllNeutral {
            for sy in (gy - radius)...(gy + radius) {
                for sx in (gx - radius)...(gx + radius) {
                    if grid.owner(at: sx, gy: sy) != GameConfig.neutralOwnerId {
                        return false
                    }
                }
            }
        }
        return true
    }

    private func tuningForDifficulty() -> DifficultyTuning {
        switch difficulty {
        case .easy:
            return DifficultyTuning(
                maxArcBase: 7,
                dangerSenseManhattan: 4,
                huntRadiusManhattan: 6,
                huntProbability: 0.25
            )
        case .normal:
            return DifficultyTuning(
                maxArcBase: 10,
                dangerSenseManhattan: 7,
                huntRadiusManhattan: 11,
                huntProbability: 0.65
            )
        case .hard:
            return DifficultyTuning(
                maxArcBase: 13,
                dangerSenseManhattan: 11,
                huntRadiusManhattan: 17,
                huntProbability: 0.95
            )
        }
    }
}
