import SwiftUI

/// Clean in-match HUD overlay showing territory percentage bar, kill pill, Top 5 leaderboard,
/// pause button, and end-of-match Game Over / Victory card.
struct HudOverlayView: View {
    let hudState: ArenaHUDState
    var rewardSummary: MatchRewardBreakdown?
    let onTogglePause: () -> Void
    let onRestart: () -> Void
    var onExitHome: () -> Void = {}

    var body: some View {
        ZStack {
            VStack(spacing: 10) {
                topProgressBar

                HStack(alignment: .top) {
                    leftActionCluster
                    Spacer()
                    leaderboardStack
                }

                Spacer()

                if hudState.gameState == .playing {
                    Text(L10n.demoControlsHint)
                        .font(.system(size: 13, weight: .bold, design: .rounded))
                        .foregroundColor(Color(red: 0.05, green: 0.14, blue: 0.45).opacity(0.6))
                        .padding(.bottom, 16)
                }
            }
            .padding(.horizontal, 14)
            .padding(.top, 12)

            if hudState.gameState == .paused {
                pauseOverlay
            } else if case let .gameOver(reason) = hudState.gameState {
                MatchEndOverlayView(
                    title: L10n.gameOverTitle,
                    subtitle: reason.localizedDescription,
                    isVictory: false,
                    peakPercentage: hudState.peakPercentage,
                    kills: hudState.kills,
                    rewardSummary: rewardSummary,
                    onExitHome: onExitHome,
                    onRestart: onRestart
                )
            } else if hudState.gameState == .victory {
                MatchEndOverlayView(
                    title: L10n.victoryTitle,
                    subtitle: L10n.endVictorySubtitle,
                    isVictory: true,
                    peakPercentage: hudState.peakPercentage,
                    kills: hudState.kills,
                    rewardSummary: rewardSummary,
                    onExitHome: onExitHome,
                    onRestart: onRestart
                )
            }
        }
    }

    private var topProgressBar: some View {
        HStack(spacing: 8) {
            GeometryReader { geo in
                let target = max(1.0, hudState.targetPercentage)
                let fraction = CGFloat(min(1.0, max(0.0, hudState.percentage / target)))
                let barColors = [
                    Color(red: 0.22, green: 0.74, blue: 0.97),
                    Color(red: 0.13, green: 0.77, blue: 0.37)
                ]
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color(red: 0.11, green: 0.07, blue: 0.57))
                        .overlay(Capsule().stroke(Color.white.opacity(0.9), lineWidth: 2))

                    Capsule()
                        .fill(LinearGradient(colors: barColors, startPoint: .leading, endPoint: .trailing))
                        .frame(width: max(28, geo.size.width * fraction))
                        .padding(2)

                    Text(progressBarLabel(target: target))
                        .font(.system(size: 13, weight: .black, design: .rounded))
                        .foregroundColor(.white)
                        .lineLimit(1)
                        .frame(maxWidth: .infinity)
                }
            }
            .frame(height: 28)

            Image(systemName: "crown.fill")
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(Color(red: 1.0, green: 0.90, blue: 0.16))
                .padding(7)
                .background(Circle().fill(Color(red: 0.11, green: 0.07, blue: 0.57)))
                .overlay(Circle().stroke(Color.white, lineWidth: 2))
        }
    }

    private func progressBarLabel(target: Double) -> String {
        let pctText = L10n.percentageText(hudState.percentage)
        if let stage = hudState.stageTitle {
            return "\(stage) • \(pctText) / \(Int(target))%"
        }
        return pctText
    }

    private var leftActionCluster: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 6) {
                Image(systemName: "bolt.circle.fill")
                    .foregroundColor(Color(red: 0.11, green: 0.07, blue: 0.57))
                Text(L10n.killsText(hudState.kills))
                    .font(.system(size: 14, weight: .black, design: .rounded))
                    .foregroundColor(Color(red: 0.06, green: 0.14, blue: 0.45))
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(Capsule().fill(Color.white.opacity(0.94)))
            .overlay(Capsule().stroke(Color(red: 0.04, green: 0.10, blue: 0.46), lineWidth: 1.5))

            Button(action: onTogglePause) {
                Image(systemName: hudState.gameState == .paused ? "play.fill" : "pause.fill")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.white)
                    .padding(10)
                    .background(Circle().fill(Color(red: 0.06, green: 0.17, blue: 0.62)))
                    .overlay(Circle().stroke(Color.white, lineWidth: 1.5))
            }
        }
    }

    private var leaderboardStack: some View {
        VStack(alignment: .trailing, spacing: 4) {
            Text(L10n.leaderboardTitle)
                .font(.system(size: 10, weight: .black, design: .rounded))
                .foregroundColor(Color(red: 0.06, green: 0.14, blue: 0.45))
                .padding(.trailing, 4)

            ForEach(hudState.leaderboard.topFive) { entry in
                leaderboardRow(entry)
            }

            if let playerExtra = hudState.leaderboard.playerOutsideTopFive {
                Divider()
                    .frame(width: 96)
                    .padding(.vertical, 2)
                leaderboardRow(playerExtra)
            }
        }
    }

    private func leaderboardRow(_ entry: LeaderboardEntry) -> some View {
        HStack(spacing: 6) {
            Text("#\(entry.rank)")
                .font(.system(size: 11, weight: .black, design: .rounded))
                .foregroundColor(.white)
                .frame(width: 22, alignment: .leading)

            Circle()
                .fill(Color(hex: entry.colorHex))
                .frame(width: 10, height: 10)
                .overlay(Circle().stroke(Color.white, lineWidth: 1))

            Text(entry.name)
                .font(.system(size: 11, weight: entry.isPlayer ? .black : .bold, design: .rounded))
                .foregroundColor(.white)
                .lineLimit(1)
                .frame(width: 56, alignment: .leading)

            Text(L10n.percentageText(entry.percentage))
                .font(.system(size: 11, weight: .black, design: .rounded))
                .foregroundColor(.white)
                .frame(width: 44, alignment: .trailing)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(rowBackground(for: entry))
        .overlay(
            Capsule().stroke(
                entry.isPlayer ? Color.white : Color.white.opacity(0.45),
                lineWidth: entry.isPlayer ? 2 : 1
            )
        )
    }

    private func rowBackground(for entry: LeaderboardEntry) -> some View {
        let fill: Color
        switch entry.rank {
        case 1:
            fill = Color(red: 0.96, green: 0.67, blue: 0.10)
        case 2:
            fill = Color(red: 0.56, green: 0.64, blue: 0.80)
        case 3:
            fill = Color(red: 0.86, green: 0.37, blue: 0.14)
        default:
            fill = entry.isPlayer
                ? Color(red: 0.11, green: 0.56, blue: 0.98)
                : Color(red: 0.08, green: 0.22, blue: 0.62).opacity(0.85)
        }
        return Capsule().fill(fill)
    }

    private var pauseOverlay: some View {
        VStack(spacing: 16) {
            Text(L10n.pausedTitle)
                .font(.system(size: 28, weight: .black, design: .rounded))
                .foregroundColor(.white)

            HStack(spacing: 12) {
                Button(action: onTogglePause) {
                    Text(L10n.resumeButton)
                        .font(.system(size: 15, weight: .black, design: .rounded))
                        .foregroundColor(.white)
                        .padding(.horizontal, 18)
                        .padding(.vertical, 10)
                        .background(Capsule().fill(Color(red: 0.18, green: 0.78, blue: 0.28)))
                        .overlay(Capsule().stroke(Color.white, lineWidth: 2))
                }

                Button(action: onRestart) {
                    Text(L10n.restartButton)
                        .font(.system(size: 15, weight: .black, design: .rounded))
                        .foregroundColor(.white)
                        .padding(.horizontal, 18)
                        .padding(.vertical, 10)
                        .background(Capsule().fill(Color(red: 0.14, green: 0.52, blue: 0.96)))
                        .overlay(Capsule().stroke(Color.white, lineWidth: 2))
                }
            }

            Button(action: onExitHome) {
                Text("Home")
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundColor(.white.opacity(0.9))
                    .padding(.horizontal, 24)
                    .padding(.vertical, 8)
                    .background(Capsule().fill(Color.white.opacity(0.18)))
            }
        }
        .padding(24)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(Color(red: 0.03, green: 0.27, blue: 0.53).opacity(0.94))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 24)
                .stroke(Color.white.opacity(0.85), lineWidth: 2)
        )
    }
}
