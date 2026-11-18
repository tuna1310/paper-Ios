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
}
