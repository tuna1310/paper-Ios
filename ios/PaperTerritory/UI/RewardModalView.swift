import SwiftUI

/// Modal card celebrating rewards dropped from Daily Mission Chest or Shop Hero Chests.
struct RewardModalView: View {
    let reward: ChestReward
    let onDismiss: () -> Void

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "shippingbox.fill")
                .font(.system(size: 46))
                .foregroundColor(Color(hex: 0xFA_CC_15))

            Text(reward.sourceName)
                .font(.system(size: 22, weight: .black, design: .rounded))
                .foregroundColor(.white)

            if let skinId = reward.unlockedSkinId {
                let skin = SkinCatalog.skin(withId: skinId)
                VStack(spacing: 8) {
                    Text("NEW SKIN UNLOCKED!")
                        .font(.system(size: 13, weight: .black, design: .rounded))
                        .foregroundColor(Color(hex: 0xFA_CC_15))
                    SkinAvatarView(skin: skin, size: 72)
                    Text(skin.name)
                        .font(.system(size: 18, weight: .black, design: .rounded))
                        .foregroundColor(.white)
                }
                .padding(.vertical, 4)
            }

            HStack(spacing: 16) {
                if reward.gold > 0 {
                    rewardPill(icon: "circle.fill", hex: 0xFA_CC_15, text: "+\(reward.gold) Gold")
                }
                if reward.diamonds > 0 {
                    rewardPill(icon: "diamond.fill", hex: 0x38_BD_F8, text: "+\(reward.diamonds) Diamonds")
                }
            }

            Button(action: onDismiss) {
                Text("Awesome!")
                    .font(.system(size: 17, weight: .black, design: .rounded))
                    .foregroundColor(.white)
                    .padding(.horizontal, 34)
                    .padding(.vertical, 12)
                    .background(Capsule().fill(Color(hex: 0x22_C5_5E)))
                    .overlay(Capsule().stroke(Color.white, lineWidth: 2))
            }
            .padding(.top, 4)
        }
        .padding(26)
        .frame(maxWidth: 330)
        .background(
            RoundedRectangle(cornerRadius: 26)
                .fill(
                    LinearGradient(
                        colors: [Color(hex: 0x1E_3A_8A), Color(hex: 0x0F_17_2A)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
        )
        .overlay(RoundedRectangle(cornerRadius: 26).stroke(Color.white.opacity(0.75), lineWidth: 2))
    }

    private func rewardPill(icon: String, hex: UInt32, text: String) -> some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .foregroundColor(Color(hex: hex))
            Text(text)
                .font(.system(size: 15, weight: .black, design: .rounded))
                .foregroundColor(.white)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 8)
        .background(Capsule().fill(Color.white.opacity(0.14)))
    }
}
