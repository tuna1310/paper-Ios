import SwiftUI

/// Animated celebration modal displayed when opening a Hero Chest or claiming a bundle.
struct ChestOpeningModalView: View {
    let rarity: ChestRarity
    let rewards: [ChestRevealReward]
    let onClose: () -> Void

    @State private var opened: Bool = false

    var body: some View {
        ZStack {
            Color.black.opacity(0.72).ignoresSafeArea()
                .onTapGesture {
                    if opened { onClose() }
                }

            VStack(spacing: 20) {
                Text("\(rarity.title.uppercased()) CHEST")
                    .font(.system(size: 26, weight: .black, design: .rounded))
                    .foregroundColor(.white)
                    .shadow(color: Color.black.opacity(0.4), radius: 4, y: 2)

                ZStack {
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [Color.white.opacity(0.65), Color.clear],
                                center: .center,
                                startRadius: 10,
                                endRadius: 120
                            )
                        )
                        .frame(width: 220, height: 220)
                        .scaleEffect(opened ? 1.15 : 0.85)
                        .animation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true), value: opened)

                    ChestArtworkView(rarity: rarity, size: 112, isOpen: opened)
                        .scaleEffect(opened ? 1.05 : 0.92)
                        .rotationEffect(.degrees(opened ? 0 : -4))
                        .animation(.spring(response: 0.42, dampingFraction: 0.55), value: opened)
                }

                if opened {
                    VStack(spacing: 10) {
                        ForEach(rewards) { item in
                            HStack(spacing: 12) {
                                if let skinId = item.unlockedSkinId ?? item.heroId {
                                    Skin2DThumbnailView(skin: SkinCatalog.skin(id: skinId), size: 46)
                                } else if item.gems > 0 {
                                    PinkGemIcon(size: 40)
                                } else {
                                    GoldCoinIcon(size: 40)
                                }

                                VStack(alignment: .leading, spacing: 2) {
                                    Text(item.title)
                                        .font(.system(size: 16, weight: .black, design: .rounded))
                                        .foregroundColor(Color(hex: "0F172A"))
                                    Text(item.subtitle)
                                        .font(.system(size: 13, weight: .bold, design: .rounded))
                                        .foregroundColor(Color(hex: "0284C7"))
                                }
                                Spacer()
                            }
                            .padding(12)
                            .background(Color.white)
                            .cornerRadius(16)
                            .shadow(color: Color.black.opacity(0.16), radius: 5, y: 2)
                        }
                    }
                    .transition(.scale.combined(with: .opacity))
                }

                Button {
                    if opened {
                        SoundHapticsManager.shared.playTap()
                        onClose()
                    } else {
                        SoundHapticsManager.shared.playReward()
                        withAnimation(.spring(response: 0.45, dampingFraction: 0.65)) {
                            opened = true
                        }
                    }
                } label: {
                    Text(opened ? "COLLECT" : "OPEN CHEST!")
                        .font(.system(size: 18, weight: .black, design: .rounded))
                        .foregroundColor(.white)
                        .frame(width: 220, height: 52)
                        .background(
                            LinearGradient(
                                colors: opened ? [Color(hex: "22C55E"), Color(hex: "16A34A")] : rarity.cardColors,
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .clipShape(Capsule())
                        .overlay(Capsule().stroke(Color.white, lineWidth: 3))
                        .shadow(color: Color.black.opacity(0.28), radius: 6, y: 4)
                }
                .buttonStyle(BouncyButtonStyle())
            }
            .padding(.horizontal, 24)
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
                if !opened {
                    SoundHapticsManager.shared.playReward()
                    withAnimation(.spring(response: 0.45, dampingFraction: 0.65)) {
                        opened = true
                    }
                }
            }
        }
    }
}

/// Reusable glossy cartoon chest artwork used across Shop & Chest Opening modal.
struct ChestArtworkView: View {
    let rarity: ChestRarity
    var size: CGFloat = 78
    var isOpen: Bool = false

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: size * 0.22, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: rarity.cardColors,
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: size, height: size * 0.78)
                .overlay(
                    RoundedRectangle(cornerRadius: size * 0.22, style: .continuous)
                        .stroke(Color.white, lineWidth: max(2, size * 0.04))
                )
                .shadow(color: Color.black.opacity(0.26), radius: 6, y: 4)

            // Horizontal chest seam
            Rectangle()
                .fill(Color(hex: "0F172A").opacity(0.32))
                .frame(width: size * 0.94, height: size * 0.08)
                .offset(y: isOpen ? -size * 0.14 : -size * 0.04)

            // Center clasp lock
            RoundedRectangle(cornerRadius: 4)
                .fill(Color(hex: "FACC15"))
                .frame(width: size * 0.24, height: size * 0.26)
                .overlay(RoundedRectangle(cornerRadius: 4).stroke(Color(hex: "92400E"), lineWidth: 1.5))
                .overlay(
                    HStack(spacing: 3) {
                        Circle().fill(Color(hex: "1E293B")).frame(width: size * 0.06)
                        Circle().fill(Color(hex: "1E293B")).frame(width: size * 0.06)
                    }
                )
                .offset(y: isOpen ? -size * 0.10 : 0)
        }
    }
}
