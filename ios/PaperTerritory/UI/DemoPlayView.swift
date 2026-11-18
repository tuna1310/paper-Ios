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

    func restartMatch() {
        scene.restartMatch()
    }
}

/// Playable Step 1 demo view embedding SpriteKit `ArenaScene` with a clean top territory bar.
struct DemoPlayView: View {
    @StateObject private var coordinator = ArenaCoordinator()

    var body: some View {
        ZStack {
            SpriteView(scene: coordinator.scene)
                .ignoresSafeArea()

            VStack {
                topBar
                    .padding(.horizontal, 16)
                    .padding(.top, 12)

                Spacer()

                if !coordinator.hudState.isPlaying {
                    endBanner
                        .padding(.bottom, 40)
                } else {
                    Text(L10n.demoControlsHint)
                        .font(.system(size: 13, weight: .bold, design: .rounded))
                        .foregroundColor(Color(red: 0.05, green: 0.14, blue: 0.45).opacity(0.65))
                        .padding(.bottom, 20)
                }
            }
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

    private var topBar: some View {
        HStack(spacing: 12) {
            GeometryReader { geo in
                let fraction = CGFloat(min(100.0, coordinator.hudState.percentage) / 100.0)
                let fillColors = [
                    Color(red: 0.22, green: 0.74, blue: 0.97),
                    Color(red: 0.13, green: 0.77, blue: 0.37)
                ]
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color(red: 0.11, green: 0.07, blue: 0.57))
                        .overlay(
                            Capsule()
                                .stroke(Color.white.opacity(0.85), lineWidth: 2)
                        )

                    Capsule()
                        .fill(
                            LinearGradient(
                                colors: fillColors,
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: max(28, geo.size.width * fraction))
                        .padding(2)

                    Text(L10n.percentageText(coordinator.hudState.percentage))
                        .font(.system(size: 14, weight: .black, design: .rounded))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                }
            }
            .frame(height: 30)

            Button {
                coordinator.restartMatch()
            } label: {
                Text(L10n.restartButton)
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 7)
                    .background(Capsule().fill(Color(red: 0.06, green: 0.17, blue: 0.62)))
                    .overlay(Capsule().stroke(Color.white.opacity(0.8), lineWidth: 1.5))
            }
        }
    }

    private var endBanner: some View {
        VStack(spacing: 14) {
            Text(L10n.gameOverTitle)
                .font(.system(size: 32, weight: .black, design: .rounded))
                .foregroundColor(.white)

            Button {
                coordinator.restartMatch()
            } label: {
                Text(L10n.playAgainButton)
                    .font(.system(size: 18, weight: .black, design: .rounded))
                    .foregroundColor(.white)
                    .padding(.horizontal, 28)
                    .padding(.vertical, 12)
                    .background(Capsule().fill(Color(red: 0.18, green: 0.78, blue: 0.28)))
                    .overlay(Capsule().stroke(Color.white, lineWidth: 2))
            }
        }
        .padding(24)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(Color(red: 0.03, green: 0.27, blue: 0.53).opacity(0.92))
        )
    }
}
