import SwiftUI

/// Player Profile & Lifetime Statistics modal opened from the avatar or bottom-right badge on Home.
struct ProfileModalView: View {
    @EnvironmentObject var store: GameStore
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            Color.black.opacity(0.58).ignoresSafeArea()
                .onTapGesture { dismiss() }

            VStack(spacing: 16) {
                HStack {
                    Text("PLAYER PROFILE")
                        .font(.system(size: 21, weight: .black, design: .rounded))
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

                // Player header card
                HStack(spacing: 14) {
                    Skin2DThumbnailView(skin: store.equippedSkin, size: 64)
                        .padding(6)
                        .background(Color(hex: "E0F2FE"))
                        .cornerRadius(18)

                    VStack(alignment: .leading, spacing: 4) {
                        Text(store.state.playerName)
                            .font(.system(size: 20, weight: .black, design: .rounded))
                            .foregroundColor(Color(hex: "0F172A"))
                        HStack(spacing: 6) {
                            Image(systemName: "star.fill")
                                .foregroundColor(Color(hex: "F59E0B"))
                            Text("\(store.state.starScore) Rating")
                                .font(.system(size: 14, weight: .extrabold, design: .rounded))
                                .foregroundColor(Color(hex: "0284C7"))
                        }
                        Text("Skins Unlocked: \(store.state.unlockedSkinIds.count)/\(SkinCatalog.all.count)")
                            .font(.system(size: 12, weight: .bold, design: .rounded))
                            .foregroundColor(Color(hex: "475569"))
                    }
                    Spacer()
                }
                .padding(14)
                .background(Color.white)
                .cornerRadius(20)

                // Stats Grid
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                    statTile(title: "Best Territory", value: String(format: "%.1f%%", store.state.bestTerritoryPercent), icon: "crown.fill", color: "F59E0B")
                    statTile(title: "Total Rivals Cut", value: "\(store.state.totalKills)", icon: "bolt.slash.fill", color: "EF4444")
                    statTile(title: "Countries Won", value: "\(store.completedCountriesCount)/\(WorldMapCatalog.allCountries.count)", icon: "flag.fill", color: "22C55E")
                    statTile(title: "Matches Won", value: "\(store.state.matchesWon)/\(store.state.matchesPlayed)", icon: "trophy.fill", color: "8B5CF6")
                }

                // Quick shortcut to Daily Rewards
                Button {
                    dismiss()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        store.showDailyRewards = true
                    }
                } label: {
                    HStack {
                        Image(systemName: "gift.fill")
                        Text("View Daily Login Calendar")
                    }
                    .font(.system(size: 15, weight: .black, design: .rounded))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(Color(hex: "22C55E"))
                    .cornerRadius(16)
                }
                .buttonStyle(BouncyButtonStyle())
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
                    .overlay(RoundedRectangle(cornerRadius: 28).stroke(Color.white, lineWidth: 3))
            )
            .padding(.horizontal, 22)
        }
    }

    private func statTile(title: String, value: String, icon: String, color: String) -> some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(Color(hex: color))
            Text(value)
                .font(.system(size: 18, weight: .black, design: .rounded))
                .foregroundColor(Color(hex: "0F172A"))
            Text(title)
                .font(.system(size: 11, weight: .bold, design: .rounded))
                .foregroundColor(Color(hex: "64748B"))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(Color.white)
        .cornerRadius(16)
    }
}
