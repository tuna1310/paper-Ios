import Foundation

/// Fixed-timestep match orchestrator for Paper Territory.
/// Step 1 implements single-player movement, trail drawing, and flood-fill territory capture;
/// Step 2 extends this orchestrator with bots, collisions, end states, and Top 5 leaderboard.
final class GameEngine {
    let grid: GridMap
    let floodFill: FloodFill
    private(set) var player: Entity
    private(set) var entities: [Entity] = []
    private(set) var elapsedTime: Double = 0
    private(set) var isPlaying: Bool = false

    var edgeRule: EdgeRule

    init(
        gridWidth: Int = GameConfig.gridSize,
        gridHeight: Int = GameConfig.gridSize,
        edgeRule: EdgeRule = .die
    ) {
        self.grid = GridMap(width: gridWidth, height: gridHeight)
        self.floodFill = FloodFill(gridWidth: gridWidth, gridHeight: gridHeight)
        self.edgeRule = edgeRule

        let center = gridWidth / 2
        let palette = SkinPalette.playerDefault
        self.player = Entity(
            id: GameConfig.humanPlayerId,
            name: L10n.playerDefaultName,
            isBot: false,
            colorHex: palette.baseHex,
            darkColorHex: palette.darkHex,
            trailColorHex: palette.trailHex,
            spawnCellX: center,
            spawnCellY: gridHeight / 2,
            initialDirection: .right,
            gridWidth: gridWidth,
            gridHeight: gridHeight
        )
        resetMatch()
    }

    func resetMatch() {
        grid.reset()
        elapsedTime = 0
        let centerX = grid.width / 2
        let centerY = grid.height / 2

        player.kills = 0
        player.resetForRespawn(spawnCellX: centerX, spawnCellY: centerY, initialDirection: .right)
        grid.initStarterTerritory(ownerId: player.id, centerX: centerX, centerY: centerY)
        entities = [player]
        isPlaying = true
    }

    @discardableResult
    func enqueuePlayerTurn(_ direction: Direction) -> Bool {
        guard isPlaying, player.isAlive else { return false }
        return player.enqueueTurn(direction)
    }

    func tick(dt: Double = GameConfig.fixedTimestepSeconds) {
        guard isPlaying, player.isAlive else { return }
        elapsedTime += dt

        let distance = player.speedCellsPerSecond * dt
        let outcome = player.advance(by: distance, grid: grid, edgeRule: edgeRule) { [floodFill, grid] entity in
            floodFill.closeLoopAndCapture(grid: grid, entity: entity)
        }

        if outcome.hitBoundary || outcome.enteredSelfTrail {
            player.isAlive = false
            player.trail.clear()
            grid.clearTerritory(for: player.id)
            isPlaying = false
        }
    }

    var playerTerritoryPercentage: Double {
        grid.percentage(for: player.id)
    }
}
