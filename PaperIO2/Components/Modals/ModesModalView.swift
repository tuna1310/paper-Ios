import SwiftUI

/// Game Modes & Seasonal Events selector modal opened from the bottom-left button on Home.
struct ModesModalView: View {
    @EnvironmentObject var store: GameStore
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            Color.black.opacity(0.58).ignoresSafeArea()
                .onTapGesture { dismiss() }

            VStack(spacing: 14) {
                HStack {
                    Text("GAME MODES & EVENTS")
                        .font(.system(size: 20, weight: .black, design: .rounded))
                        .foregroundColor(.white)
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

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 11) {
                        ForEach(GameModeType.allCases) { mode in
                            modeCard(mode)
                        }

                        // Coming Soon League teaser matching video's "Coming Soon" slot
                        HStack(spacing: 12) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 14)
                                    .fill(Color(hex: "334155"))
                                    .frame(width: 52, height: 52)
                                Image(systemName: "lock.fill")
                                    .font(.system(size: 22, weight: .bold))
                                    .foregroundColor(.white.opacity(0.85))
                            }
                            VStack(alignment: .leading, spacing: 3) {
                                Text("Ranked Championship")
                                    .font(.system(size: 16, weight: .black, design: .rounded))
                                    .foregroundColor(.white)
                                Text("COMING SOON • Season Rewards")
                                    .font(.system(size: 12, weight: .bold, design: .rounded))
                                    .foregroundColor(.white.opacity(0.75))
                            }
                            Spacer()
                        }
                        .padding(12)
                        .background(Color(hex: "1E293B").opacity(0.78))
                        .cornerRadius(18)
                        .overlay(
                            RoundedRectangle(cornerRadius: 18)
                                .stroke(Color.white.opacity(0.28), lineWidth: 1.5)
                        )
                    }
                }
                .frame(maxHeight: 430)
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

    private func modeCard(_ mode: GameModeType) -> some View {
        let isSelected = store.state.activeMode == mode
        return Button {
            SoundHapticsManager.shared.playTap()
            store.state.activeMode = mode
            dismiss()
        } label: {
            HStack(spacing: 12) {
                ZStack {
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: mode.accentColors,
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 54, height: 54)
                        .overlay(
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .stroke(Color.white, lineWidth: 2)
                        )

                    Image(systemName: mode.iconName)
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.white)
                }

                VStack(alignment: .leading, spacing: 3) {
                    HStack(spacing: 6) {
                        Text(mode.title)
                            .font(.system(size: 17, weight: .black, design: .rounded))
                            .foregroundColor(Color(hex: "0F172A"))
                        if mode.isSeasonal {
                            Text("EVENT")
                                .font(.system(size: 10, weight: .black, design: .rounded))
                                .foregroundColor(.white)
                                .padding(.horizontal, 7)
                                .padding(.vertical, 2)
                                .background(Color(hex: "EF4444"))
                                .clipShape(Capsule())
                        }
                    }

                    Text(mode.subtitle)
                        .font(.system(size: 13, weight: .semibold, design: .rounded))
                        .foregroundColor(Color(hex: "475569"))
                        .multilineTextAlignment(.leading)
                }

                Spacer()

                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 26))
                        .foregroundColor(Color(hex: "22C55E"))
                } else {
                    Text("SELECT")
                        .font(.system(size: 12, weight: .black, design: .rounded))
                        .foregroundColor(.white)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 7)
                        .background(Color(hex: "1C88EB"))
                        .clipShape(Capsule())
                }
            }
            .padding(12)
            .background(Color.white)
            .cornerRadius(18)
            .overlay(
                RoundedRectangle(cornerRadius: 18)
                    .stroke(isSelected ? Color(hex: "22C55E") : Color.white, lineWidth: isSelected ? 3 : 1)
            )
            .shadow(color: Color.black.opacity(0.15), radius: 4, y: 2)
        }
        .buttonStyle(BouncyButtonStyle())
    }
}
