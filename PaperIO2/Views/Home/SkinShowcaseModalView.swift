import SwiftUI

/// Fullscreen 3D Skin Showcase Pedestal Modal (matching video 00:52 - 01:04).
struct SkinShowcaseModalView: View {
    @EnvironmentObject var store: GameStore

    @State private var currentIndex: Int = 0

    private var browsableSkins: [SkinDefinition] {
        // Put unlocked skins first, followed by purchasable/milestone skins in catalog order
        let unlocked = SkinCatalog.all.filter { store.isSkinUnlocked($0.id) }
        let locked = SkinCatalog.all.filter { !store.isSkinUnlocked($0.id) }
        return unlocked + locked
    }

    private var currentSkin: SkinDefinition {
        let list = browsableSkins
        guard !list.isEmpty else { return store.equippedSkin }
        let safeIdx = ((currentIndex % list.count) + list.count) % list.count
        return list[safeIdx]
    }

    var body: some View {
        ZStack {
            PaperBackgroundView(
                topColor: Color(hex: "89D9FF"),
                bottomColor: Color(hex: "2BA4F8"),
                showPerspectiveFloor: true
            )

            VStack(spacing: 12) {
                // Top Header with green checkmark when equipped + Skin Name banner
                HStack {
                    if store.state.equippedSkinId == currentSkin.id {
                        ZStack {
                            Circle()
                                .fill(Color(hex: "22C55E"))
                                .frame(width: 44, height: 44)
                                .overlay(Circle().stroke(Color.white, lineWidth: 3))
                                .shadow(color: Color.black.opacity(0.22), radius: 4, y: 2)
                            Image(systemName: "checkmark")
                                .font(.system(size: 22, weight: .black))
                                .foregroundColor(.white)
                        }
                    } else {
                        Color.clear.frame(width: 44, height: 44)
                    }

                    Spacer()

                    // Skin Title Pill matching video 00:52
                    HStack(spacing: 0) {
                        Text(currentSkin.name)
                            .font(.system(size: 20, weight: .black, design: .rounded))
                            .foregroundColor(.white)
                            .padding(.horizontal, 22)
                            .padding(.vertical, 9)
                    }
                    .background(
                        Capsule()
                            .fill(
                                LinearGradient(
                                    colors: currentSkin.category.badgeColors,
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .overlay(Capsule().stroke(Color.white, lineWidth: 3))
                            .shadow(color: Color.black.opacity(0.22), radius: 5, y: 3)
                    )

                    Spacer()
                    Color.clear.frame(width: 44, height: 44)
                }
                .padding(.horizontal, 18)
                .padding(.top, 18)

                // Category & Trail pill
                HStack(spacing: 8) {
                    Text(currentSkin.category.title.uppercased())
                        .font(.system(size: 11, weight: .black, design: .rounded))
                        .foregroundColor(.white)
                    Text("•")
                        .foregroundColor(.white.opacity(0.7))
                    Text("\(currentSkin.trailEffect.rawValue.capitalized) Trail")
                        .font(.system(size: 11, weight: .bold, design: .rounded))
                        .foregroundColor(.white.opacity(0.95))
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 4)
                .background(Color(hex: "0A2454").opacity(0.45))
                .clipShape(Capsule())

                Spacer()

                // 3D Pedestal + Left/Right Chevron Arrows
                ZStack {
                    Skin3DPreviewView(
                        skin: currentSkin,
                        showTerritoryIsland: false,
                        interactiveRotate: true
                    )
                    .frame(height: 330)

                    HStack {
                        arrowButton(systemName: "chevron.left") {
                            SoundHapticsManager.shared.playSwipeCard()
                            withAnimation(.spring(response: 0.25, dampingFraction: 0.8)) {
                                currentIndex -= 1
                            }
                        }

                        Spacer()

                        arrowButton(systemName: "chevron.right") {
                            SoundHapticsManager.shared.playSwipeCard()
                            withAnimation(.spring(response: 0.25, dampingFraction: 0.8)) {
                                currentIndex += 1
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                }

                Spacer()

                // Action Button: EQUIPPED / EQUIP / BUY / PROGRESS
                actionButton
                    .padding(.bottom, 6)

                // Circular Close 'X' button
                Button {
                    SoundHapticsManager.shared.playTap()
                    store.showSkinShowcase = false
                } label: {
                    ZStack {
                        Circle()
                            .fill(Color(hex: "0E5DB8"))
                            .frame(width: 48, height: 48)
                            .overlay(Circle().stroke(Color.white, lineWidth: 3))
                            .shadow(color: Color.black.opacity(0.25), radius: 5, y: 3)
                        Image(systemName: "xmark")
                            .font(.system(size: 20, weight: .black))
                            .foregroundColor(.white)
                    }
                }
                .buttonStyle(BouncyButtonStyle())
                .padding(.bottom, 26)
            }
        }
        .onAppear {
            if let idx = browsableSkins.firstIndex(where: { $0.id == store.showcaseSkinId }) {
                currentIndex = idx
            }
        }
    }

    private func arrowButton(systemName: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            ZStack {
                Circle()
                    .fill(Color.white.opacity(0.92))
                    .frame(width: 46, height: 46)
                    .shadow(color: Color.black.opacity(0.2), radius: 4, y: 2)
                Image(systemName: systemName)
                    .font(.system(size: 20, weight: .black))
                    .foregroundColor(Color(hex: "0F5EB8"))
            }
        }
        .buttonStyle(BouncyButtonStyle())
    }

    @ViewBuilder
    private var actionButton: some View {
        let isUnlocked = store.isSkinUnlocked(currentSkin.id)
        let isEquipped = store.state.equippedSkinId == currentSkin.id

        if isEquipped {
            Text("EQUIPPED")
                .font(.system(size: 20, weight: .black, design: .rounded))
                .foregroundColor(.white)
                .frame(width: 210, height: 54)
                .background(Color(hex: "60A5FA").opacity(0.85))
                .clipShape(Capsule())
                .overlay(Capsule().stroke(Color.white, lineWidth: 3))
        } else if isUnlocked {
            Button {
                store.equipSkin(currentSkin.id)
            } label: {
                Text("EQUIP")
                    .font(.system(size: 22, weight: .black, design: .rounded))
                    .foregroundColor(.white)
                    .frame(width: 210, height: 56)
                    .background(
                        LinearGradient(
                            colors: [Color(hex: "2CD4FF"), Color(hex: "0284C7")],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .clipShape(Capsule())
                    .overlay(Capsule().stroke(Color.white, lineWidth: 3.5))
                    .shadow(color: Color.black.opacity(0.25), radius: 6, y: 4)
            }
            .buttonStyle(BouncyButtonStyle())
        } else {
            switch currentSkin.unlockRule {
            case .coins(let price):
                Button {
                    _ = store.purchaseSkinWithCoins(currentSkin, cost: price)
                } label: {
                    HStack(spacing: 8) {
                        GoldCoinIcon(size: 26)
                        Text(price.compactFormatted)
                            .font(.system(size: 20, weight: .black, design: .rounded))
                            .foregroundColor(.white)
                    }
                    .frame(width: 210, height: 56)
                    .background(Color(hex: "22C55E"))
                    .clipShape(Capsule())
                    .overlay(Capsule().stroke(Color.white, lineWidth: 3))
                    .shadow(color: Color.black.opacity(0.25), radius: 6, y: 4)
                }
                .buttonStyle(BouncyButtonStyle())

            case .gems(let price):
                Button {
                    _ = store.purchaseSkinWithGems(currentSkin, cost: price)
                } label: {
                    HStack(spacing: 8) {
                        PinkGemIcon(size: 26)
                        Text("\(price)")
                            .font(.system(size: 20, weight: .black, design: .rounded))
                            .foregroundColor(.white)
                    }
                    .frame(width: 210, height: 56)
                    .background(Color(hex: "D946EF"))
                    .clipShape(Capsule())
                    .overlay(Capsule().stroke(Color.white, lineWidth: 3))
                    .shadow(color: Color.black.opacity(0.25), radius: 6, y: 4)
                }
                .buttonStyle(BouncyButtonStyle())

            default:
                let reqText = currentSkin.unlockRule.shortRequirementText ?? "Open Hero Chests to Unlock"
                Text(reqText)
                    .font(.system(size: 15, weight: .black, design: .rounded))
                    .foregroundColor(.white)
                    .padding(.horizontal, 24)
                    .frame(height: 50)
                    .background(Color(hex: "0C234B").opacity(0.75))
                    .clipShape(Capsule())
                    .overlay(Capsule().stroke(Color.white.opacity(0.65), lineWidth: 2))
            }
        }
    }
}
