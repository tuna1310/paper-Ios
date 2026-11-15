import SwiftUI

/// Settings modal triggered by the top-right gear icon on Home.
struct SettingsModalView: View {
    @EnvironmentObject var store: GameStore
    @Environment(\.dismiss) private var dismiss

    @State private var nameInput: String = ""
    @State private var showResetConfirm: Bool = false

    var body: some View {
        ZStack {
            Color.black.opacity(0.55).ignoresSafeArea()
                .onTapGesture { dismiss() }

            VStack(spacing: 16) {
                // Header
                HStack {
                    Text("SETTINGS")
                        .font(.system(size: 22, weight: .black, design: .rounded))
                        .foregroundColor(.white)
                    Spacer()
                    Button {
                        SoundHapticsManager.shared.playTap()
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 28))
                            .foregroundColor(.white.opacity(0.9))
                    }
                }

                VStack(spacing: 14) {
                    // Player Name
                    HStack {
                        Label("Nickname", systemImage: "person.fill")
                            .font(.system(size: 15, weight: .bold, design: .rounded))
                            .foregroundColor(Color(hex: "0F172A"))
                        Spacer()
                        TextField("PLAYER", text: $nameInput)
                            .multilineTextAlignment(.trailing)
                            .font(.system(size: 15, weight: .heavy, design: .rounded))
                            .foregroundColor(Color(hex: "0284C7"))
                            .frame(width: 140)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .background(Color(hex: "F1F5F9"))
                            .cornerRadius(10)
                    }

                    Divider()

                    // Sound toggle
                    Toggle(isOn: Binding(
                        get: { store.state.soundEnabled },
                        set: { store.updateSettings(sound: $0) }
                    )) {
                        Label("Sound Effects", systemImage: "speaker.wave.2.fill")
                            .font(.system(size: 15, weight: .bold, design: .rounded))
                            .foregroundColor(Color(hex: "0F172A"))
                    }
                    .tint(Color(hex: "22C55E"))

                    // Haptics toggle
                    Toggle(isOn: Binding(
                        get: { store.state.hapticsEnabled },
                        set: { store.updateSettings(haptics: $0) }
                    )) {
                        Label("Haptic Feedback", systemImage: "iphone.radiowaves.left.and.right")
                            .font(.system(size: 15, weight: .bold, design: .rounded))
                            .foregroundColor(Color(hex: "0F172A"))
                    }
                    .tint(Color(hex: "22C55E"))

                    Divider()

                    // Sensitivity slider
                    VStack(alignment: .leading, spacing: 6) {
                        HStack {
                            Label("Swipe Sensitivity", systemImage: "hand.draw.fill")
                                .font(.system(size: 15, weight: .bold, design: .rounded))
                                .foregroundColor(Color(hex: "0F172A"))
                            Spacer()
                            Text(String(format: "%.1fx", store.state.controlSensitivity))
                                .font(.system(size: 14, weight: .heavy, design: .rounded))
                                .foregroundColor(Color(hex: "0284C7"))
                        }
                        Slider(
                            value: Binding(
                                get: { store.state.controlSensitivity },
                                set: { store.updateSettings(sensitivity: $0) }
                            ),
                            in: 0.6...1.6,
                            step: 0.1
                        )
                        .tint(Color(hex: "1C88EB"))
                    }
                }
                .padding(16)
                .background(Color.white)
                .cornerRadius(20)

                // Save & Reset row
                HStack(spacing: 12) {
                    Button {
                        showResetConfirm = true
                    } label: {
                        Text("Reset Data")
                            .font(.system(size: 15, weight: .heavy, design: .rounded))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(Color(hex: "EF4444"))
                            .cornerRadius(14)
                    }

                    Button {
                        store.updateSettings(playerName: nameInput)
                        SoundHapticsManager.shared.playReward()
                        dismiss()
                    } label: {
                        Text("Save")
                            .font(.system(size: 16, weight: .black, design: .rounded))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(Color(hex: "22C55E"))
                            .cornerRadius(14)
                    }
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
            .padding(.horizontal, 24)
        }
        .onAppear {
            nameInput = store.state.playerName
        }
        .alert("Reset all progress?", isPresented: $showResetConfirm) {
            Button("Cancel", role: .cancel) {}
            Button("Reset", role: .destructive) {
                store.resetAllProgress()
                nameInput = store.state.playerName
                dismiss()
            }
        } message: {
            Text("Coins, gems, unlocked skins, and conquered countries will return to starter defaults.")
        }
    }
}
