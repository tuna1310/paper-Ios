import XCTest
@testable import PaperTerritory

final class GameEngineTests: XCTestCase {
    func testGameStatesReadyPlayingPausedAndCleanReset() {
        let engine = GameEngine()
        engine.resetMatch(autoStart: false)
        XCTAssertEqual(engine.gameState, .ready)

        engine.start()
        XCTAssertEqual(engine.gameState, .playing)

        let posBeforePause = engine.player.posX
        engine.pause()
        XCTAssertEqual(engine.gameState, .paused)
        engine.tick()
        XCTAssertEqual(engine.player.posX, posBeforePause, accuracy: 1e-9)

        engine.resume()
        XCTAssertEqual(engine.gameState, .playing)
        engine.tick()
        XCTAssertGreaterThan(engine.player.posX, posBeforePause)

        // Mutate kills and territory, then reset cleanly
        engine.player.kills = 5
        engine.grid.initStarterTerritory(ownerId: engine.player.id, centerX: 60, centerY: 60, radius: 6)
        engine.resetMatch(autoStart: true)

        XCTAssertEqual(engine.gameState, .playing)
        XCTAssertEqual(engine.player.kills, 0)
        XCTAssertEqual(engine.grid.countCells(for: engine.player.id), 25)
        XCTAssertEqual(engine.elapsedTime, 0, accuracy: 1e-9)
    }
}
