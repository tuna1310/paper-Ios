import SwiftUI

/// Persistent top HUD displaying Coins, Gems, and optional Home Avatar / Settings buttons.
struct TopResourceBar: View {
    @EnvironmentObject var store: GameStore
    var showHomeControls: Bool = false

    var body: some View {
        HStack(spacing: 10) {
            if showHomeControls {
                Button {
                    SoundHapticsManager.shared.playTap()
                    store.showProfileModal = true
                } label: {
                    AvatarBadgeIcon()
                }
                .buttonStyle(BouncyButtonStyle())
            } else {
                Spacer(minLength: 0)
            }

            // Coins Pill
            CurrencyPillButton(
                amountText: store.state.coins.compactFormatted,
                kind: .coins
            ) {
                SoundHapticsManager.shared.playTap()
                store.selectedTab = .shop
            }

            // Gems Pill
            CurrencyPillButton(
                amountText: store.state.gems.compactFormatted,
                kind: .gems
            ) {
                SoundHapticsManager.shared.playTap()
                store.selectedTab = .shop
            }

            if showHomeControls {
                Button {
                    SoundHapticsManager.shared.playTap()
                    store.showSettings = true
                } label: {
                    ZStack {
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .fill(
                                LinearGradient(
                                    colors: [Color(hex: "36B9FF"), Color(hex: "117EE8")],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                            .frame(width: 44, height: 44)
                            .overlay(
                                RoundedRectangle(cornerRadius: 14, style: .continuous)
                                    .stroke(Color.white, lineWidth: 2.5)
                            )
                            .shadow(color: Color.black.opacity(0.22), radius: 4, y: 3)

                        Image(systemName: "gearshape.fill")
                            .font(.system(size: 21, weight: .bold))
                            .foregroundColor(.white)
                    }
                }
                .buttonStyle(BouncyButtonStyle())
            } else {
                Spacer(minLength: 0)
            }
        }
        .padding(.horizontal, 14)
        .padding(.top, 6)
    }
}

enum CurrencyVisualKind {
    case coins
    case gems
}

struct CurrencyPillButton: View {
    let amountText: String
    let kind: CurrencyVisualKind
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            ZStack(alignment: .leading) {
                // Dark translucent pill body
                HStack(spacing: 4) {
                    Spacer().frame(width: 30)
                    Text(amountText)
                        .font(.system(size: 16, weight: .heavy, design: .rounded))
                        .foregroundColor(.white)
                        .monospacedDigit()
                        .lineLimit(1)
                    Spacer(minLength: 20)
                }
                .frame(minWidth: 102, maxWidth: 122, height: 34)
                .background(
                    Capsule()
                        .fill(Color(hex: "0A2454").opacity(0.62))
                        .overlay(
                            Capsule()
                                .stroke(Color.white.opacity(0.32), lineWidth: 1.5)
                        )
                )

                // Left protruding Coin or Gem icon
                Group {
                    if kind == .coins {
                        GoldCoinIcon(size: 36)
                    } else {
                        PinkGemIcon(size: 36)
                    }
                }
                .offset(x: -4)

                // Green + badge on right edge
                Circle()
                    .fill(Color(hex: "22C55E"))
                    .frame(width: 20, height: 20)
                    .overlay(
                        Circle().stroke(Color.white, lineWidth: 1.8)
                    )
                    .overlay(
                        Image(systemName: "plus")
                            .font(.system(size: 11, weight: .black))
                            .foregroundColor(.white)
                    )
                    .frame(maxWidth: .infinity, alignment: .trailing)
                    .offset(x: 4, y: 8)
            }
            .frame(width: 114, height: 38)
        }
        .buttonStyle(BouncyButtonStyle())
    }
}

struct GoldCoinIcon: View {
    var size: CGFloat = 28

    var body: some View {
        ZStack {
            Circle()
                .fill(
                    LinearGradient(
                        colors: [Color(hex: "FFE854"), Color(hex: "F59E0B")],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: size, height: size)
                .overlay(Circle().stroke(Color(hex: "B45309"), lineWidth: max(1.5, size * 0.08)))
                .shadow(color: Color.black.opacity(0.25), radius: 2, y: 2)

            Circle()
                .fill(Color(hex: "FBBF24"))
                .frame(width: size * 0.64, height: size * 0.64)
                .overlay(
                    Circle().stroke(Color(hex: "FEF08A"), lineWidth: max(1, size * 0.05))
                )

            RoundedRectangle(cornerRadius: 2)
                .fill(Color(hex: "FEF08A"))
                .frame(width: size * 0.14, height: size * 0.36)
        }
    }
}

struct PinkGemIcon: View {
    var size: CGFloat = 28

    var body: some View {
        ZStack {
            DiamondGemShape()
                .fill(
                    LinearGradient(
                        colors: [Color(hex: "FF7EE2"), Color(hex: "D91B9B")],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(width: size, height: size * 0.92)
                .overlay(
                    DiamondGemShape()
                        .stroke(Color(hex: "86198F"), lineWidth: max(1.5, size * 0.07))
                )
                .shadow(color: Color.black.opacity(0.25), radius: 2, y: 2)

            DiamondGemShape()
                .fill(Color.white.opacity(0.35))
                .frame(width: size * 0.48, height: size * 0.44)
                .offset(y: -size * 0.12)
        }
    }
}

private struct DiamondGemShape: Shape {
    func path(in rect: CGRect) -> Path {
        var p = Path()
        let w = rect.width
        let h = rect.height
        p.move(to: CGPoint(x: w * 0.22, y: 0))
        p.addLine(to: CGPoint(x: w * 0.78, y: 0))
        p.addLine(to: CGPoint(x: w, y: h * 0.36))
        p.addLine(to: CGPoint(x: w * 0.5, y: h))
        p.addLine(to: CGPoint(x: 0, y: h * 0.36))
        p.closeSubpath()
        return p
    }
}

struct AvatarBadgeIcon: View {
    var body: some View {
        ZStack {
            Circle()
                .fill(
                    LinearGradient(
                        colors: [Color(hex: "43C4FF"), Color(hex: "1482EB")],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(width: 44, height: 44)
                .overlay(Circle().stroke(Color.white, lineWidth: 2.5))
                .shadow(color: Color.black.opacity(0.22), radius: 4, y: 3)

            // Cute Paper.io cube face inside circle
            RoundedRectangle(cornerRadius: 7, style: .continuous)
                .fill(Color.white)
                .frame(width: 24, height: 22)
                .overlay(
                    HStack(spacing: 5) {
                        Circle().fill(Color(hex: "1E3A8A")).frame(width: 4.5, height: 4.5)
                        Circle().fill(Color(hex: "1E3A8A")).frame(width: 4.5, height: 4.5)
                    }
                )
        }
    }
}

/// Tactile Paper.io-style press bounce for buttons.
struct BouncyButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.93 : 1.0)
            .animation(.spring(response: 0.22, dampingFraction: 0.65), value: configuration.isPressed)
    }
}
