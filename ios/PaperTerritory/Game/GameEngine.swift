import Foundation

/// Fixed-timestep match orchestrator coordinating the 120x120 grid, human player,
/// 10–15 AI bots, collision rules, flood fill captures, 5 end states, and Top 5 leaderboard.
final class GameEngine {
    let grid: GridMap
    let floodFill: FloodFill
    let collisionDetector: CollisionDetector
    let botAI: BotAI

    private(set) var player: Entity
    private(set) var bots: [Entity] = []
    private(set) var entities: [Entity] = []
    private(set) var gameState: GameState = .ready
    private(set) var elapsedTime: Double = 0
    private(set) var peakTerritoryPercentage: Double = 0
    private(set) var recentEvents: [CollisionEvent] = []

    var settings: MatchSettings {
        didSet {
            botAI.difficulty = settings.botDifficulty
        }
    }

    private var rng: SeededRandomGenerator
    private var previousCellsBuffer: [GridPoint] = []
    private var stepOutcomesBuffer: [EntityStepOutcome] = []

    var isPlaying: Bool {
        gameState == .playing
    }

    var playerTerritoryPercentage: Double {
        grid.percentage(for: player.id)
    }

    init(
        gridWidth: Int = GameConfig.gridSize,
        gridHeight: Int = GameConfig.gridSize,
        settings: MatchSettings = .default,
        seed: UInt64 = 0x5041_5045_5232
    ) {
        self.grid = GridMap(width: gridWidth, height: gridHeight)
        self.floodFill = FloodFill(gridWidth: gridWidth, gridHeight: gridHeight)
        self.collisionDetector = CollisionDetector()
        self.settings = settings
        self.botAI = BotAI(difficulty: settings.botDifficulty, seed: seed ^ 0x1234_5678)
        self.rng = SeededRandomGenerator(seed: seed)

        self.player = Entity(
            id: GameConfig.humanPlayerId,
            name: L10n.playerDefaultName,
            isBot: false,
            palette: SkinPalette.playerDefault,
            spawn: GridPoint(gx: gridWidth / 2, gy: gridHeight / 2),
            initialDirection: .right,
            gridSize: gridWidth
        )
        resetMatch(autoStart: true)
    }

    /// Resets the entire arena, grid, bots, trails, and timers cleanly for a new match.
    func resetMatch(autoStart: Bool = true) {
        grid.reset()
        elapsedTime = 0
        recentEvents.removeAll(keepingCapacity: true)

        let centerX = grid.width / 2
        let centerY = grid.height / 2
        player.kills = 0
        player.resetForRespawn(spawnCellX: centerX, spawnCellY: centerY, initialDirection: .right)
        grid.initStarterTerritory(ownerId: player.id, centerX: centerX, centerY: centerY)

        bots.removeAll(keepingCapacity: true)
        let botCount = settings.clampedBotCount
        var availableNames = GameConfig.botNames.shuffled(using: &rng)
        if availableNames.count < botCount {
            availableNames = GameConfig.botNames
        }

        let spawnRingRadius = Double(min(grid.width, grid.height)) * 0.34
        let botPalettes = SkinPalette.distinctBotPalettes
        let margin = min(GameConfig.botSpawnBorderMarginCells, max(2, min(grid.width, grid.height) / 6))

        for index in 0..<botCount {
            let botId = UInt8(index + 2)
            let palette = botPalettes[index % botPalettes.count]
            let angle = (Double(index) / Double(botCount)) * (2.0 * .pi) + 0.35
            let rawX = Int((Double(centerX) + cos(angle) * spawnRingRadius).rounded())
            let rawY = Int((Double(centerY) + sin(angle) * spawnRingRadius).rounded())
            let spawnX = min(max(margin, rawX), grid.width - 1 - margin)
            let spawnY = min(max(margin, rawY), grid.height - 1 - margin)

            let initialDir = Direction.allCases[index % Direction.allCases.count]
            let bot = Entity(
                id: botId,
                name: availableNames[index % availableNames.count],
                isBot: true,
                palette: palette,
                spawn: GridPoint(gx: spawnX, gy: spawnY),
                initialDirection: initialDir,
                gridSize: grid.width
            )
            grid.initStarterTerritory(ownerId: bot.id, centerX: spawnX, centerY: spawnY)
            bots.append(bot)
        }

        entities = [player] + bots
        previousCellsBuffer = Array(repeating: GridPoint(gx: 0, gy: 0), count: entities.count)
        stepOutcomesBuffer = Array(repeating: EntityStepOutcome(), count: entities.count)

        botAI.difficulty = settings.botDifficulty
        botAI.reset(bots: bots)

        peakTerritoryPercentage = playerTerritoryPercentage
        gameState = autoStart ? .playing : .ready
    }

    func start() {
        if gameState == .ready || gameState == .paused {
            gameState = .playing
        }
    }

    func pause() {
        if gameState == .playing {
            gameState = .paused
        }
    }

    func resume() {
        if gameState == .paused {
            gameState = .playing
        }
    }

    @discardableResult
    func enqueuePlayerTurn(_ direction: Direction) -> Bool {
        guard gameState == .playing, player.isAlive else { return false }
        return player.enqueueTurn(direction)
    }

    func tick(dt: Double = GameConfig.fixedTimestepSeconds) {
        guard gameState == .playing else { return }
        guard player.isAlive else {
            gameState = .gameOver(.starvation)
            return
        }

        elapsedTime += dt
        recentEvents.removeAll(keepingCapacity: true)

        botAI.update(dt: dt, bots: bots, allEntities: entities, grid: grid)

        if previousCellsBuffer.count != entities.count {
            previousCellsBuffer = Array(repeating: GridPoint(gx: 0, gy: 0), count: entities.count)
            stepOutcomesBuffer = Array(repeating: EntityStepOutcome(), count: entities.count)
        }

        for idx in entities.indices {
            let entity = entities[idx]
            previousCellsBuffer[idx] = GridPoint(gx: entity.cellX, gy: entity.cellY)
            if entity.isAlive {
                let distance = entity.speedCellsPerSecond * dt
                stepOutcomesBuffer[idx] = entity.advance(
                    by: distance,
                    grid: grid,
                    edgeRule: settings.edgeRule
                ) { [floodFill, grid] closedEntity in
                    floodFill.closeLoopAndCapture(grid: grid, entity: closedEntity)
                }
            } else {
                stepOutcomesBuffer[idx] = EntityStepOutcome()
            }
        }

        let events = collisionDetector.checkCollisions(
            entities: entities,
            grid: grid,
            previousCells: previousCellsBuffer,
            stepOutcomes: stepOutcomesBuffer,
            headOnRule: settings.headOnRule
        )

        for event in events {
            recentEvents.append(event)
            applyElimination(event)
        }

        let currentPct = playerTerritoryPercentage
        if currentPct > peakTerritoryPercentage {
            peakTerritoryPercentage = currentPct
        }

        if gameState == .playing && grid.countCells(for: player.id) >= grid.totalPlayableCells {
            gameState = .victory
        }
    }

    func leaderboardSnapshot() -> LeaderboardSnapshot {
        Leaderboard.build(entities: entities, grid: grid)
    }

    private func applyElimination(_ event: CollisionEvent) {
        guard let victim = entities.first(where: { $0.id == event.victimId }), victim.isAlive else {
            return
        }

        victim.isAlive = false
        victim.trail.clear()
        grid.clearTerritory(for: victim.id)

        if event.reason != .headOnMutual,
           let killerId = event.killerId,
           killerId != victim.id,
           let killer = entities.first(where: { $0.id == killerId }),
           killer.isAlive {
            killer.kills += 1
        }

        if victim.isBot {
            victim.respawnTimer = Double.random(
                in: GameConfig.botRespawnDelayMinSeconds...GameConfig.botRespawnDelayMaxSeconds,
                using: &rng
            )
        } else {
            gameState = .gameOver(event.reason)
        }
    }
}
