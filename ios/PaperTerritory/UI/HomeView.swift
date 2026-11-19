import SwiftUI

/// Main Paper.io 2-style Play lobby showcasing equipped skin, stats, Classic play, and World shortcut.
struct HomeView: View {
    @ObservedObject var store: PlayerProfileStore
    let onPlayClassic: () -> Void
    let onOpenWorld: () -> Void
    let onOpenShop: () -> Void

    var body: some View {
        ScrollView {
            VStack(spacing: 18) {
                titleBanner
                avatarShowcaseCard
                actionButtons
                quickStatsGrid
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 24)
        }
    }

    private var titleBanner: some View {
        VStack(spacing: 4) {
            Text(L10n.appTitle.uppercased())
                .font(.system(size: 32, weight: .black, design: .rounded))
                .foregroundColor(.white)
                .shadow(color: Color.black.opacity(0.35), radius: 4, y: 2)
            Text("Conquer territory. Cut enemy trails. Rule the world.")
                .font(.system(size: 13, weight: .bold, design: .rounded))
                .foregroundColor(.white.opacity(0.85))
        }
        .padding(.top, 8)
    }

    private var avatarShowcaseCard: some View {
        let skin = store.equippedSkin
        let tier = store.currentRankTier
        let rpProgress = RankTier.progressToNext(points: store.profile.rankPoints)

        return VStack(spacing: 12) {
            SkinAvatarView(skin: skin, size: 88)

            Text(skin.name)
                .font(.system(size: 20, weight: .black, design: .rounded))
                .foregroundColor(.white)

            HStack(spacing: 8) {
                RankBadgeView(tier: tier, compact: true)
                Text("\(store.profile.rankPoints) RP")
                    .font(.system(size: 13, weight: .black, design: .rounded))
                    .foregroundColor(.white.opacity(0.9))
            }

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule().fill(Color.white.opacity(0.18))
                    Capsule()
                        .fill(Color(hex: 0xFA_CC_15))
                        .frame(width: max(12, geo.size.width * CGFloat(rpProgress)))
                }
            }
            .frame(height: 8)
            .padding(.horizontal, 18)

            Button(action: onOpenShop) {
                Label("Change Skin", systemImage: "paintpalette.fill")
                    .font(.system(size: 13, weight: .black, design: .rounded))
                    .foregroundColor(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 7)
                    .background(Capsule().fill(Color.white.opacity(0.16)))
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity)
        .background(RoundedRectangle(cornerRadius: 24).fill(Color.white.opacity(0.12)))
        .overlay(RoundedRectangle(cornerRadius: 24).stroke(Color.white.opacity(0.32), lineWidth: 1.5))
    }

    private var actionButtons: some View {
        VStack(spacing: 12) {
            Button(action: onPlayClassic) {
                HStack(spacing: 10) {
                    Image(systemName: "play.fill")
                        .font(.system(size: 22, weight: .black))
                    Text("PLAY CLASSIC")
                        .font(.system(size: 22, weight: .black, design: .rounded))
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(
                    Capsule().fill(
                        LinearGradient(
                            colors: [Color(hex: 0x22_C5_5E), Color(hex: 0x15_80_3D)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                )
                .overlay(Capsule().stroke(Color.white, lineWidth: 2.5))
                .shadow(color: Color.black.opacity(0.3), radius: 8, y: 4)
            }

            Button(action: onOpenWorld) {
                let cleared = store.profile.completedCountryIds.count
                let total = WorldMapCatalog.allCountries.count
                HStack(spacing: 8) {
                    Image(systemName: "globe.americas.fill")
                        .font(.system(size: 18, weight: .bold))
                    Text("WORLD CONQUEST (\(cleared)/\(total))")
                        .font(.system(size: 16, weight: .black, design: .rounded))
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 13)
                .background(
                    Capsule().fill(
                        LinearGradient(
                            colors: [Color(hex: 0x25_63_EB), Color(hex: 0x1D_4E_D8)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                )
                .overlay(Capsule().stroke(Color.white.opacity(0.8), lineWidth: 2))
            }
        }
    }

    private var quickStatsGrid: some View {
        HStack(spacing: 10) {
            statTile(title: "Best Area", value: L10n.percentageText(store.profile.bestPercentage))
            statTile(title: "Total Kills", value: "\(store.profile.totalKills)")
            statTile(title: "Matches", value: "\(store.profile.matchesPlayed)")
        }
    }

    private func statTile(title: String, value: String) -> some View {
        VStack(spacing: 4) {
            Text(title)
                .font(.system(size: 11, weight: .bold, design: .rounded))
                .foregroundColor(.white.opacity(0.72))
            Text(value)
                .font(.system(size: 16, weight: .black, design: .rounded))
                .foregroundColor(.white)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(RoundedRectangle(cornerRadius: 16).fill(Color.white.opacity(0.1)))
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.white.opacity(0.2), lineWidth: 1))
    }
}
