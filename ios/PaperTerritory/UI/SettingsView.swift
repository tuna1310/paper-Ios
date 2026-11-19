import SwiftUI

/// Native Settings sheet for match difficulty, rules, bot count, and StoreKit restore.
struct SettingsView: View {
    @ObservedObject var store: PlayerProfileStore
    @ObservedObject var storeKit: StoreKitManager
    @Environment(\.dismiss) private var dismiss

    @State private var draft = MatchSettings.default

    var body: some View {
        NavigationStack {
            Form {
                Section("Gameplay Rules") {
                    Picker("Bot Difficulty", selection: $draft.botDifficulty) {
                        Text("Easy").tag(BotDifficulty.easy)
                        Text("Normal").tag(BotDifficulty.normal)
                        Text("Hard").tag(BotDifficulty.hard)
                    }

                    Picker("Arena Border", selection: $draft.edgeRule) {
                        Text("Eliminate").tag(EdgeRule.die)
                        Text("Block").tag(EdgeRule.block)
                    }

                    Picker("Head-On Clash", selection: $draft.headOnRule) {
                        Text("Larger Territory Wins").tag(HeadOnRule.largerTerritoryWins)
                        Text("Both Eliminated").tag(HeadOnRule.bothDie)
                    }

                    Stepper("Bots: \(draft.botCount)", value: $draft.botCount, in: 10...15)
                }

                Section("Purchases") {
                    Button("Restore StoreKit Purchases") {
                        Task {
                            await storeKit.restorePurchases()
                        }
                    }
                    if let status = storeKit.statusMessage {
                        Text(status)
                            .font(.footnote)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        store.updateSettings(draft)
                        dismiss()
                    }
                }
            }
            .onAppear {
                draft = store.profile.settings
            }
        }
    }
}
