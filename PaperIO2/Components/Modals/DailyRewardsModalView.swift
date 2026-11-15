import SwiftUI

/// 7-day Daily Login Rewards calendar modal.
struct DailyRewardsModalView: View {
    @EnvironmentObject var store: GameStore
    @Environment(\.dismiss) private var dismiss

    private let columns = [
        GridItem(.flexible(), spacing: 10),
        GridItem(.flexible(), spacing: 10),
        GridItem(.flexible(), spacing: 10)
    ]

    var body: some View {
        ZStack {
            Color.black.opacity(0.6).ignoresSafeArea()
                .onTapGesture { dismiss() }

            VStack(spacing: 16) {
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("DAILY REWARDS")
                            .font(.system(size: 21, weight: .black, design: .rounded))
                            .foregroundColor(.white)
                        Text("Current Streak: \(store.state.loginStreak) Day\(store.state.loginStreak == 1 ? "" : "s")")
                            .font(.system(size: 13, weight: .bold, design: .rounded))
                            .foregroundColor(Color(hex: "BAE6FD"))
                    }
                    Spacer()
                    Button {
                        SoundHapticsManager.shared.playTap()
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 28))
                            .foregroundColor(.white)
                    }
                }

                LazyVGrid(columns: columns, spacing: 10) {
                    ForEach(ShopCatalog.dailyLoginRewards.prefix(6)) { reward in
                        dayCard(reward)
                    }
                }

                if let day7 = ShopCatalog.dailyLoginRewards.last {
                    daySevenCard(day7)
                }
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 28, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [Color(hex: "36B9FF"), Color(hex: "0C74DA")],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 28, style: .continuous)
                            .stroke(Color.white, lineWidth: 3)
                    )
            )
            .padding(.horizontal, 20)
        }
    }

    private func dayCard(_ reward: DailyLoginReward) -> some View {
        let isClaimed = store.state.claimedDailyRewardDays.contains(reward.dayNumber)
        let isUnlocked = reward.dayNumber <= store.state.loginStreak
        let canClaim = isUnlocked && !isClaimed

        return Button {
            if canClaim {
                store.claimDailyLoginReward(reward)
            }
        } label: {
            VStack(spacing: 6) {
                Text("DAY \(reward.dayNumber)")
                    .font(.system(size: 12, weight: .black, design: .rounded))
                    .foregroundColor(.white)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 3)
                    .background(canClaim ? Color(hex: "22C55E") : Color(hex: "1E3A8A").opacity(0.65))
                    .clipShape(Capsule())

                if let skinId = reward.specialSkinId {
                    Skin2DThumbnailView(skin: SkinCatalog.skin(id: skinId), size: 38)
                } else if reward.gems > 0 {
                    PinkGemIcon(size: 34)
                } else {
                    GoldCoinIcon(size: 34)
                }

                Text(reward.title)
                    .font(.system(size: 12, weight: .heavy, design: .rounded))
                    .foregroundColor(Color(hex: "0F172A"))
                    .lineLimit(1)

                Text(isClaimed ? "CLAIMED" : (canClaim ? "CLAIM" : "LOCKED"))
                    .font(.system(size: 10, weight: .black, design: .rounded))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 4)
                    .background(isClaimed ? Color(hex: "94A3B8") : (canClaim ? Color(hex: "22C55E") : Color(hex: "64748B")))
                    .cornerRadius(8)
            }
            .padding(10)
            .background(Color.white)
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(canClaim ? Color(hex: "FACC15") : Color.white, lineWidth: canClaim ? 3 : 1.5)
            )
        }
        .buttonStyle(BouncyButtonStyle())
    }

    private func daySevenCard(_ reward: DailyLoginReward) -> some View {
        let isClaimed = store.state.claimedDailyRewardDays.contains(7)
        let canClaim = store.state.loginStreak >= 7 && !isClaimed

        return Button {
            if canClaim {
                store.claimDailyLoginReward(reward)
            }
        } label: {
            HStack(spacing: 14) {
                Skin2DThumbnailView(skin: SkinCatalog.skin(id: "streak7"), size: 54)
                VStack(alignment: .leading, spacing: 3) {
                    Text("DAY 7 GRAND PRIZE")
                        .font(.system(size: 12, weight: .black, design: .rounded))
                        .foregroundColor(Color(hex: "B45309"))
                    Text("Golden Lion + 2,500 Coins + 35 Gems")
                        .font(.system(size: 14, weight: .heavy, design: .rounded))
                        .foregroundColor(Color(hex: "0F172A"))
                }
                Spacer()
                Text(isClaimed ? "CLAIMED" : (canClaim ? "CLAIM" : "DAY 7"))
                    .font(.system(size: 12, weight: .black, design: .rounded))
                    .foregroundColor(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(canClaim ? Color(hex: "22C55E") : Color(hex: "64748B"))
                    .clipShape(Capsule())
            }
            .padding(14)
            .background(
                LinearGradient(
                    colors: [Color(hex: "FEF08A"), Color(hex: "FDE047")],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .cornerRadius(18)
            .overlay(RoundedRectangle(cornerRadius: 18).stroke(Color.white, lineWidth: 2.5))
        }
        .buttonStyle(BouncyButtonStyle())
    }
}
