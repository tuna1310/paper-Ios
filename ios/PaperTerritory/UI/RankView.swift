import SwiftUI

/// Ten-tier competitive Rank Ladder screen (Bronze through Legend).
struct RankView: View {
    @ObservedObject var store: PlayerProfileStore

    var body: some View {
        ScrollView {
            VStack(spacing: 14) {
                currentRankHero
                VStack(spacing: 10) {
                    ForEach(RankTier.allCases) { tier in
                        tierRow(tier)
                    }
                }
            }
            .padding(.horizontal, 14)
            .padding(.bottom, 24)
        }
    }

    private var currentRankHero: some View {
        let tier = store.currentRankTier
        let rp = store.profile.rankPoints
        let progress = RankTier.progressToNext(points: rp)
        let multiplierPct = Int(((tier.rewardMultiplier - 1.0) * 100.0).rounded())

        return VStack(spacing: 12) {
            RankBadgeView(tier: tier, compact: false)

            Text("\(rp) RP")
                .font(.system(size: 28, weight: .black, design: .rounded))
                .foregroundColor(.white)

            if let next = tier.nextTier {
                VStack(spacing: 6) {
                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            Capsule().fill(Color.white.opacity(0.2))
                            Capsule()
                                .fill(Color(hex: 0xFA_CC_15))
                                .frame(width: max(10, geo.size.width * CGFloat(progress)))
                        }
                    }
                    .frame(height: 10)
                    Text("Next: \(next.displayName) at \(next.minPoints) RP")
                        .font(.system(size: 12, weight: .bold, design: .rounded))
                        .foregroundColor(.white.opacity(0.85))
                }
            } else {
                Text("Maximum Rank Achieved!")
                    .font(.system(size: 13, weight: .black, design: .rounded))
                    .foregroundColor(Color(hex: 0xFA_CC_15))
            }

            Text("Active Match Reward Bonus: +\(multiplierPct)% Gold & Diamonds")
                .font(.system(size: 12, weight: .semibold, design: .rounded))
                .foregroundColor(Color(hex: 0x6E_E7_B7))
        }
        .padding(18)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 22)
                .fill(
                    LinearGradient(
                        colors: [Color(hex: tier.primaryHex).opacity(0.85), Color(hex: 0x0F_17_2A)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
        )
        .overlay(RoundedRectangle(cornerRadius: 22).stroke(Color.white.opacity(0.45), lineWidth: 1.5))
    }

    private func tierRow(_ tier: RankTier) -> some View {
        let reached = store.profile.rankPoints >= tier.minPoints
        let isCurrent = store.currentRankTier == tier
        let bonusPct = Int(((tier.rewardMultiplier - 1.0) * 100.0).rounded())

        return HStack(spacing: 12) {
            Image(systemName: tier.symbolName)
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(Color(hex: tier.primaryHex))
                .frame(width: 34)

            VStack(alignment: .leading, spacing: 2) {
                Text(tier.displayName)
                    .font(.system(size: 15, weight: .black, design: .rounded))
                    .foregroundColor(.white)
                Text("\(tier.minPoints) RP  •  +\(bonusPct)% Rewards")
                    .font(.system(size: 12, weight: .semibold, design: .rounded))
                    .foregroundColor(.white.opacity(0.72))
            }

            Spacer()

            if isCurrent {
                Text("CURRENT")
                    .font(.system(size: 10, weight: .black, design: .rounded))
                    .foregroundColor(Color(hex: 0x0F_17_2A))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Capsule().fill(Color(hex: 0xFA_CC_15)))
            } else if reached {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(Color(hex: 0x22_C5_5E))
            } else {
                Image(systemName: "lock.fill")
                    .foregroundColor(.white.opacity(0.35))
            }
        }
        .padding(12)
        .background(RoundedRectangle(cornerRadius: 16).fill(Color.white.opacity(isCurrent ? 0.18 : 0.09)))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(isCurrent ? Color(hex: 0xFA_CC_15) : Color.white.opacity(0.18), lineWidth: isCurrent ? 2 : 1)
        )
    }
}
