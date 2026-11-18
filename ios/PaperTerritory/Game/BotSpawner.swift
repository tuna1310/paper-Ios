import Foundation

/// Handles safe empty-area bot respawning outside alive entities' clearance zones.
enum BotSpawner {
    static func respawn(
        _ bot: Entity,
        allEntities: [Entity],
        grid: GridMap,
        rng: inout SeededRandomGenerator
    ) -> Direction {
        let margin = min(GameConfig.botSpawnBorderMarginCells, max(2, min(grid.width, grid.height) / 6))
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
        return initialDir
    }

    private static func isSafeSpawnPatch(
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
            let neutral = GameConfig.neutralOwnerId
            for sy in (gy - radius)...(gy + radius) {
                for sx in (gx - radius)...(gx + radius) where grid.owner(at: sx, gy: sy) != neutral {
                    return false
                }
            }
        }
        return true
    }
}
