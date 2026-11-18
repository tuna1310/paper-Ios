import SpriteKit
import SwiftUI

/// Coordinator holding the single `GameEngine` and `ArenaScene` across SwiftUI redraws.
@MainActor
final class ArenaCoordinator: ObservableObject {
    let engine: GameEngine
    let scene: ArenaScene
    @Published var hudState = ArenaHUDState()

    init() {
        let engine = GameEngine()
        let scene = ArenaScene(engine: engine)
        self.engine = engine
        self.scene = scene

        scene.onHUDUpdate = { [weak self] nextState in
            Task { @MainActor in
                self?.hudState = nextState
            }
        }
    }

    func togglePause() {
        scene.togglePause()
    }

    func restartMatch() {
        scene.restartMatch()
    }
}

/// Playable arena view embedding SpriteKit `ArenaScene` and clean SwiftUI `HudOverlayView`.
struct DemoPlayView: View {
    @StateObject private var coordinator = ArenaCoordinator()

    var body: some View {
        ZStack {
            SpriteView(scene: coordinator.scene)
                .ignoresSafeArea()

            HudOverlayView(
                hudState: coordinator.hudState,
                onTogglePause: { coordinator.togglePause() },
                onRestart: { coordinator.restartMatch() }
            )
        }
        .statusBarHidden(true)
        .persistentSystemOverlays(.hidden)
        .onAppear {
            UIApplication.shared.isIdleTimerDisabled = true
        }
        .onDisappear {
            UIApplication.shared.isIdleTimerDisabled = false
        }
    }
}
