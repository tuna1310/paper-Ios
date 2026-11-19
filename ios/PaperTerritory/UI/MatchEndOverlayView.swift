import SwiftUI

/// End-of-match Victory / Game Over card displaying peak territory, kills, earned Gold/Diamonds/RP,
/// rank-up alert, and World Conquest continent unlock callouts.
struct MatchEndOverlayView: View {
    let title: String
    let subtitle: String
    let isVictory: Bool
    let peakPercentage: Double
    let kills: Int
    let rewardSummary: MatchRewardBreakdown?
    let onExitHome: () -> Void
    let onRestart: () -> Void

    var body: some View {
        VStack(spacing: 12) {
            Text(title)
                .font(.system(size: 30, weight: .black, design: .rounded))
                .foregroundColor(isVictory ? Color(red: 1.0, green: 0.91, blue: 0.22) : .white)

            Text(subtitle)
                .font(.system(size: 14, weight: .bold, design: .rounded))
                .foregroundColor(Color.white.opacity(0.92))
                .multilineTextAlignment(.center)

            HStack(spacing: 16) {
                statBadge(label: L10n.bestLabel, value: L10n.percentageText(peakPercentage))
                statBadge(label: L10n.killsLabel, value: L10n.killsText(kills))
            }

            if let rewards = rewardSummary {
                matchRewardsBlock(rewards)
            }

            HStack(spacing: 12) {
                Button(action: onExitHome) {
                    Text("Home")
                        .font(.system(size: 16, weight: .black, design: .rounded))
                        .foregroundColor(.white)
                        .padding(.horizontal, 22)
                        .padding(.vertical, 12)
                        .background(Capsule().fill(Color.white.opacity(0.22)))
                        .overlay(Capsule().stroke(Color.white.opacity(0.75), lineWidth: 1.5))
                }

                Button(action: onRestart) {
                    Text(L10n.playAgainButton)
                        .font(.system(size: 16, weight: .black, design: .rounded))
                        .foregroundColor(.white)
                        .padding(.horizontal, 26)
                        .padding(.vertical, 12)
                        .background(Capsule().fill(Color(red: 0.18, green: 0.78, blue: 0.28)))
                        .overlay(Capsule().stroke(Color.white, lineWidth: 2))
                }
            }
            .padding(.top, 4)
        }
        .padding(24)
        .background(
            RoundedRectangle(cornerRadius: 26)
                .fill(Color(red: 0.01, green: 0.27, blue: 0.62).opacity(0.95))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 26)
                .stroke(Color.white.opacity(0.85), lineWidth: 2.5)
        )
        .padding(.horizontal, 24)
    }

    private func matchRewardsBlock(_ rewards: MatchRewardBreakdown) -> some View {
        VStack(spacing: 8) {
            HStack(spacing: 10) {
                rewardChip(icon: "circle.fill", hex: 0xFA_CC_15, text: "+\(rewards.goldEarned)")
                rewardChip(icon: "diamond.fill", hex: 0x38_BD_F8, text: "+\(rewards.diamondsEarned)")
                rewardChip(icon: "star.fill", hex: 0xA8_55_F7, text: "+\(rewards.rankPointsDelta) RP")
            }
            if rewards.didRankUp {
                Text("RANK UP: \(rewards.newTier.displayName)!")
                    .font(.system(size: 13, weight: .black, design: .rounded))
                    .foregroundColor(Color(hex: 0xFA_CC_15))
            }
            if let country = rewards.countryConqueredName {
                Text("CONQUERED \(country.uppercased())!")
                    .font(.system(size: 13, weight: .black, design: .rounded))
                    .foregroundColor(Color(hex: 0x6E_E7_B7))
            }
            if let continent = rewards.continentUnlockedName {
                Text("NEW CONTINENT UNLOCKED: \(continent.uppercased())!")
                    .font(.system(size: 12, weight: .black, design: .rounded))
                    .foregroundColor(Color(hex: 0x38_BD_F8))
            }
        }
        .padding(10)
        .background(RoundedRectangle(cornerRadius: 14).fill(Color.white.opacity(0.12)))
    }

    private func rewardChip(icon: String, hex: UInt32, text: String) -> some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(Color(hex: hex))
            Text(text)
                .font(.system(size: 13, weight: .black, design: .rounded))
                .foregroundColor(.white)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 5)
        .background(Capsule().fill(Color.black.opacity(0.25)))
    }

    private func statBadge(label: String, value: String) -> some View {
        VStack(spacing: 2) {
            Text(label)
                .font(.system(size: 12, weight: .bold, design: .rounded))
                .foregroundColor(Color.white.opacity(0.75))
            Text(value)
                .font(.system(size: 18, weight: .black, design: .rounded))
                .foregroundColor(.white)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(RoundedRectangle(cornerRadius: 12).fill(Color.white.opacity(0.14)))
    }
}
