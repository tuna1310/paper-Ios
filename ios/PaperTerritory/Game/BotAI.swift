import Foundation

/// Zero-allocation AI brain driving 10–15 bots with short-arc expansion, trail hunting,
/// self-trail & dead-end avoidance, panic retreat home, and empty-area respawn.
final class BotAI {
    private struct BrainState {
        var turnClockwise: Bool
        var maxArcCells: Int
        var legLengthTarget: Int
        var stepsOnCurrentLeg: Int
        var lastDecidedCell: GridPoint
    }

    private struct DecisionContext {
        let bot: Entity
        let origin: GridPoint
        let intent: BotIntent
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
    private let reachability = BotReachabilityAnalyzer()

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
        let tuning = BotDifficultyTuning.forDifficulty(difficulty)
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
        let tuning = BotDifficultyTuning.forDifficulty(difficulty)

        for bot in bots {
            if !bot.isAlive {
                bot.respawnTimer -= dt
                if bot.respawnTimer <= 0 {
                    _ = BotSpawner.respawn(bot, allEntities: allEntities, grid: grid, rng: &rng)
                    registerBot(bot)
                }
                continue
            }

            let decisionCell = BotNavigation.upcomingDecisionCell(for: bot, grid: grid)
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

    // swiftlint:disable:next function_parameter_count
    private func resolveIntentAndTarget(
        bot: Entity,
        cell: GridPoint,
        maxArcCells: Int,
        tuning: BotDifficultyTuning,
        grid: GridMap,
        allEntities: [Entity]
    ) -> (BotIntent, GridPoint?) {
        let insideOwn = grid.owner(at: cell.gx, gy: cell.gy) == bot.id
        if !insideOwn {
            let threatened = isThreatened(bot: bot, cell: cell, radius: tuning.dangerSenseManhattan, all: allEntities)
            if threatened || bot.trail.count >= maxArcCells {
                return (.retreatHome, BotNavigation.findNearestOwnedCell(for: bot.id, from: cell, grid: grid))
            }
        }

        if bot.trail.count < maxArcCells / 2, Double.random(in: 0..<1, using: &rng) < tuning.huntProbability {
            if let prey = BotNavigation.findNearestExposedTrail(
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

    private func pickBestDirection(context: DecisionContext, brain: inout BrainState) -> Direction {
        let candidates = [context.bot.direction, context.preferredSide, context.otherSide]
        var bestDir = context.bot.direction
        var bestScore = -1_000_000_000

        for dir in candidates {
            let nx = context.origin.gx + dir.dx
            let ny = context.origin.gy + dir.dy
            guard context.grid.isInsideBounds(gx: nx, gy: ny), !context.bot.trail.contains(gx: nx, gy: ny) else {
                continue
            }

            let nextCell = GridPoint(gx: nx, gy: ny)
            let reach = reachability.evaluate(
                from: nextCell,
                blockedOrigin: context.origin,
                bot: context.bot,
                grid: context.grid
            )
            let score = scoreSafety(dir: dir, nextCell: nextCell, reach: reach, context: context)
                + scoreCombat(nextCell: nextCell, context: context)
                + scoreSteering(dir: dir, nextCell: nextCell, reach: reach, context: context)

            if score > bestScore {
                bestScore = score
                bestDir = dir
            }
        }

        if bestScore == -1_000_000_000 {
            let origin = context.origin
            for dir in candidates where context.grid.isInsideBounds(gx: origin.gx + dir.dx, gy: origin.gy + dir.dy) {
                return dir
            }
        }

        if bestDir == context.otherSide && context.stepsOnLeg >= context.legTarget {
            brain.turnClockwise.toggle()
        }
        return bestDir
    }

    private func scoreSafety(
        dir: Direction,
        nextCell: GridPoint,
        reach: BotReachabilityResult,
        context: DecisionContext
    ) -> Int {
        let nextIsOwn = context.grid.owner(at: nextCell.gx, gy: nextCell.gy) == context.bot.id
        var score = nextIsOwn
            ? ((context.intent == .retreatHome) ? 1_500 : 0)
            : scoreCorridorRisk(dir: dir, nextCell: nextCell, reach: reach, context: context)

        if nextCell.gx <= 1 || nextCell.gx >= context.grid.width - 2 ||
            nextCell.gy <= 1 || nextCell.gy >= context.grid.height - 2
        {
            score -= 120
        }
        return score
    }

    private func scoreCorridorRisk(
        dir: Direction,
        nextCell: GridPoint,
        reach: BotReachabilityResult,
        context: DecisionContext
    ) -> Int {
        var score = 0
        if !reach.reachedHome && reach.openCells < BotReachabilityAnalyzer.defaultMaxNodes {
            // Reject moves leading into sealed pockets bounded by the bot's own trail/walls.
            score -= 100_000 - (reach.openCells * 100)
        } else if !reach.reachedHome && context.intent == .retreatHome {
            score -= 8_000
        }

        let exits = BotNavigation.countSafeExits(from: nextCell, heading: dir, bot: context.bot, grid: context.grid)
        if exits == 0 {
            score -= 20_000
        } else if exits == 1 {
            score -= 3_500
        }

        let pinchCount = BotNavigation.countOtherTrailNeighbors(
            around: nextCell,
            excluding: context.origin,
            bot: context.bot
        )
        if pinchCount >= 2 {
            score -= 5_000
        } else if pinchCount == 1 {
            score -= 250
        }

        let depth = BotNavigation.forwardCorridorDepth(
            from: nextCell,
            heading: dir,
            maxSteps: 5,
            bot: context.bot,
            grid: context.grid
        )
        return score + depth * 40
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

    private func scoreSteering(
        dir: Direction,
        nextCell: GridPoint,
        reach: BotReachabilityResult,
        context: DecisionContext
    ) -> Int {
        if context.intent == .retreatHome, reach.reachedHome, let steps = reach.stepsToHome {
            return max(0, 48 - steps) * 260
        }

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
}
