import Foundation

/// Deterministic grid-cell collision resolver covering boundary hits, self-trail hits,
/// enemy trail cuts, head-on collisions, and zero-territory starvation.
final class CollisionDetector {
    private var eliminatedIds = Set<UInt8>()
    private var eventsBuffer: [CollisionEvent] = []

    init() {
        eliminatedIds.reserveCapacity(16)
        eventsBuffer.reserveCapacity(16)
    }

    /// Evaluates collisions across all alive entities for the current tick.
    func checkCollisions(
        entities: [Entity],
        grid: GridMap,
        previousCells: [GridPoint],
        stepOutcomes: [EntityStepOutcome],
        headOnRule: HeadOnRule
    ) -> [CollisionEvent] {
        eliminatedIds.removeAll(keepingCapacity: true)
        eventsBuffer.removeAll(keepingCapacity: true)

        checkStepOutcomes(entities: entities, stepOutcomes: stepOutcomes)
        checkEnemyTrailCuts(entities: entities)
        checkHeadOnCollisions(entities: entities, grid: grid, previousCells: previousCells, headOnRule: headOnRule)
        checkStarvation(entities: entities, grid: grid)

        return eventsBuffer
    }

    private func checkStepOutcomes(entities: [Entity], stepOutcomes: [EntityStepOutcome]) {
        for idx in entities.indices {
            let entity = entities[idx]
            guard entity.isAlive else { continue }
            let outcome = stepOutcomes[idx]

            if outcome.hitBoundary {
                eliminatedIds.insert(entity.id)
                eventsBuffer.append(CollisionEvent(victimId: entity.id, killerId: nil, reason: .boundary))
            }
        }
    }

    private func checkEnemyTrailCuts(entities: [Entity]) {
        for attacker in entities where attacker.isAlive && !eliminatedIds.contains(attacker.id) {
            let ax = attacker.cellX
            let ay = attacker.cellY

            for victim in entities where victim.id != attacker.id && victim.isAlive {
                guard !eliminatedIds.contains(victim.id) else { continue }
                if victim.trail.contains(gx: ax, gy: ay) {
                    eliminatedIds.insert(victim.id)
                    eventsBuffer.append(
                        CollisionEvent(
                            victimId: victim.id,
                            killerId: attacker.id,
                            reason: .enemyTrail(killerName: attacker.name)
                        )
                    )
                }
            }
        }
    }

    private func checkHeadOnCollisions(
        entities: [Entity],
        grid: GridMap,
        previousCells: [GridPoint],
        headOnRule: HeadOnRule
    ) {
        for i in entities.indices {
            let first = entities[i]
            guard first.isAlive, !eliminatedIds.contains(first.id) else { continue }
            let firstCurr = GridPoint(gx: first.cellX, gy: first.cellY)
            let firstPrev = previousCells[i]

            for j in (i + 1)..<entities.count {
                let second = entities[j]
                guard second.isAlive, !eliminatedIds.contains(second.id) else { continue }
                let secondCurr = GridPoint(gx: second.cellX, gy: second.cellY)
                let secondPrev = previousCells[j]

                let sameCell = (firstCurr == secondCurr)
                let crossedPaths = (firstCurr == secondPrev && secondCurr == firstPrev && firstCurr != firstPrev)
                if sameCell || crossedPaths {
                    resolveHeadOn(first: first, second: second, grid: grid, rule: headOnRule)
                }
            }
        }
    }

    private func checkStarvation(entities: [Entity], grid: GridMap) {
        for entity in entities where entity.isAlive && !eliminatedIds.contains(entity.id) {
            guard grid.countCells(for: entity.id) <= 0 else { continue }
            eliminatedIds.insert(entity.id)
            eventsBuffer.append(CollisionEvent(victimId: entity.id, killerId: nil, reason: .starvation))
        }
    }

    private func resolveHeadOn(first: Entity, second: Entity, grid: GridMap, rule: HeadOnRule) {
        let firstInOwn = grid.owner(at: first.cellX, gy: first.cellY) == first.id
        let secondInOwn = grid.owner(at: second.cellX, gy: second.cellY) == second.id
        if firstInOwn && secondInOwn {
            return
        }
        if firstInOwn {
            recordHeadOnLoss(victim: second, killer: first)
            return
        }
        if secondInOwn {
            recordHeadOnLoss(victim: first, killer: second)
            return
        }

        if rule == .bothDie {
            recordHeadOnMutual(first: first, second: second)
            return
        }

        let firstCount = grid.countCells(for: first.id)
        let secondCount = grid.countCells(for: second.id)
        if firstCount > secondCount {
            recordHeadOnLoss(victim: second, killer: first)
        } else if secondCount > firstCount {
            recordHeadOnLoss(victim: first, killer: second)
        } else {
            recordHeadOnMutual(first: first, second: second)
        }
    }

    private func recordHeadOnLoss(victim: Entity, killer: Entity) {
        eliminatedIds.insert(victim.id)
        eventsBuffer.append(
            CollisionEvent(victimId: victim.id, killerId: killer.id, reason: .headOnLoss(killerName: killer.name))
        )
    }

    private func recordHeadOnMutual(first: Entity, second: Entity) {
        eliminatedIds.insert(first.id)
        eliminatedIds.insert(second.id)
        eventsBuffer.append(CollisionEvent(victimId: first.id, killerId: second.id, reason: .headOnMutual))
        eventsBuffer.append(CollisionEvent(victimId: second.id, killerId: first.id, reason: .headOnMutual))
    }
}
