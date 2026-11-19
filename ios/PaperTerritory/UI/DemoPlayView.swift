import SpriteKit
import SwiftUI
import UIKit

/// Coordinator holding the single `GameEngine` and `ArenaScene` across SwiftUI redraws.
@MainActor
final class ArenaCoordinator: ObservableObject {
    let engine: GameEngine
    let scene: ArenaScene
    @Published var hudState = ArenaHUDState()
    @Published var matchRewards: MatchRewardBreakdown?

    private weak var profileStore: PlayerProfileStore?

    init(profileStore: PlayerProfileStore? = nil, countryStage: CountryStage? = nil) {
        self.profileStore = profileStore

        let baseSettings = profileStore?.profile.settings ?? .default
        var matchSettings = baseSettings
        if let stage = countryStage {
            matchSettings.botDifficulty = stage.difficulty
        }

        let palette = profileStore?.equippedSkin.palette ?? SkinPalette.playerDefault
        let gridSize = countryStage != nil ? GameConfig.worldStageArenaSize : GameConfig.gridSize
        let targetPct = countryStage?.targetPercentage ?? GameConfig.victoryPercentage
        let modeConfig = MatchModeConfig(
            playerPalette: palette,
            victoryPercentage: targetPct,
            countryStageId: countryStage?.id
        )

        let seed = UInt64(Date().timeIntervalSince1970 * 1_000) ^ 0x5041_5045_5232
        let engine = GameEngine(
            gridWidth: gridSize,
            gridHeight: gridSize,
            settings: matchSettings,
            seed: seed,
            modeConfig: modeConfig
        )
        let scene = ArenaScene(engine: engine, stageTitle: countryStage?.name)
        self.engine = engine
        self.scene = scene

        scene.onHUDUpdate = { [weak self] nextState in
            Task { @MainActor in
                self?.hudState = nextState
            }
        }
        scene.onMatchEnded = { [weak self] outcome in
            Task { @MainActor in
                guard let self else { return }
                self.matchRewards = self.profileStore?.recordMatchOutcome(outcome)
            }
        }
    }

    func togglePause() {
        scene.togglePause()
    }

    func restartMatch() {
        matchRewards = nil
        scene.restartMatch()
    }
}

/// Playable arena view embedding SpriteKit `ArenaScene` and SwiftUI `HudOverlayView`.
struct DemoPlayView: View {
    @StateObject private var coordinator: ArenaCoordinator
    let onExitHome: () -> Void

    @MainActor
    init(
        profileStore: PlayerProfileStore? = nil,
        countryStage: CountryStage? = nil,
        onExitHome: @escaping () -> Void = {}
    ) {
        _coordinator = StateObject(
            wrappedValue: ArenaCoordinator(profileStore: profileStore, countryStage: countryStage)
        )
        self.onExitHome = onExitHome
    }

    var body: some View {
        ZStack {
            SpriteView(scene: coordinator.scene)
                .ignoresSafeArea()

            HudOverlayView(
                hudState: coordinator.hudState,
                rewardSummary: coordinator.matchRewards,
                onTogglePause: { coordinator.togglePause() },
                onRestart: { coordinator.restartMatch() },
                onExitHome: onExitHome
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
