import SwiftUI

/// World Conquest screen showing all 6 continents (8 representative countries each).
/// Completing all 8 countries in a continent unlocks the next continent automatically.
struct WorldMapView: View {
    @ObservedObject var store: PlayerProfileStore
    let onPlayCountry: (CountryStage) -> Void

    @State private var selectedContinentId: String = WorldMapCatalog.continents[0].id
    private let columns = [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)]

    private var selectedContinent: Continent {
        WorldMapCatalog.continent(withId: selectedContinentId) ?? WorldMapCatalog.continents[0]
    }

    var body: some View {
        VStack(spacing: 12) {
            continentStrip
            continentHeaderCard

            ScrollView {
                let unlocked = WorldMapCatalog.isContinentUnlocked(
                    selectedContinent.id,
                    completedCountryIds: store.profile.completedCountryIds
                )
                if unlocked {
                    LazyVGrid(columns: columns, spacing: 12) {
                        ForEach(selectedContinent.countries) { country in
                            countryCard(country)
                        }
                    }
                    .padding(.bottom, 24)
                } else {
                    lockedContinentBanner
                }
            }
        }
        .padding(.horizontal, 14)
    }

    private var continentStrip: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(WorldMapCatalog.continents) { continent in
                    let unlocked = WorldMapCatalog.isContinentUnlocked(
                        continent.id,
                        completedCountryIds: store.profile.completedCountryIds
                    )
                    let done = WorldMapCatalog.completedCount(
                        in: continent,
                        completedCountryIds: store.profile.completedCountryIds
                    )
                    let selected = continent.id == selectedContinent.id

                    Button {
                        selectedContinentId = continent.id
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: unlocked ? "globe.americas.fill" : "lock.fill")
                                .font(.system(size: 12, weight: .bold))
                            Text(continent.name)
                                .font(.system(size: 13, weight: .black, design: .rounded))
                            Text("\(done)/\(continent.countries.count)")
                                .font(.system(size: 11, weight: .bold, design: .rounded))
                                .opacity(0.85)
                        }
                        .foregroundColor(selected ? Color(hex: 0x0F_17_2A) : .white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(
                            Capsule().fill(selected ? Color(hex: 0xFA_CC_15) : Color.white.opacity(0.15))
                        )
                    }
                }
            }
        }
    }

    private var continentHeaderCard: some View {
        let done = WorldMapCatalog.completedCount(
            in: selectedContinent,
            completedCountryIds: store.profile.completedCountryIds
        )
        let total = selectedContinent.countries.count
        return HStack {
            VStack(alignment: .leading, spacing: 3) {
                Text(selectedContinent.name)
                    .font(.system(size: 20, weight: .black, design: .rounded))
                    .foregroundColor(.white)
                Text("Conquer all \(total) countries to unlock the next continent")
                    .font(.system(size: 12, weight: .semibold, design: .rounded))
                    .foregroundColor(.white.opacity(0.82))
            }
            Spacer()
            Text("\(done)/\(total)")
                .font(.system(size: 18, weight: .black, design: .rounded))
                .foregroundColor(Color(hex: 0xFA_CC_15))
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(
                    LinearGradient(
                        colors: [Color(hex: selectedContinent.themeHex).opacity(0.8), Color(hex: 0x0F_17_2A)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
        )
        .overlay(RoundedRectangle(cornerRadius: 18).stroke(Color.white.opacity(0.35), lineWidth: 1.5))
    }

    private func countryCard(_ country: CountryStage) -> some View {
        let completed = store.profile.completedCountryIds.contains(country.id)
        return VStack(spacing: 8) {
            HStack {
                CountryFlagBadgeView(style: country.flag)
                Spacer()
                if completed {
                    Image(systemName: "checkmark.seal.fill")
                        .font(.system(size: 20))
                        .foregroundColor(Color(hex: 0x22_C5_5E))
                }
            }

            Text(country.name)
                .font(.system(size: 15, weight: .black, design: .rounded))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity, alignment: .leading)
                .lineLimit(1)

            HStack {
                Text("Goal: \(Int(country.targetPercentage))%")
                    .font(.system(size: 11, weight: .bold, design: .rounded))
                    .foregroundColor(Color(hex: 0xFA_CC_15))
                Spacer()
                Text("+\(country.rewardGold)G / +\(country.rewardDiamonds)D")
                    .font(.system(size: 10, weight: .bold, design: .rounded))
                    .foregroundColor(.white.opacity(0.8))
            }

            Button {
                onPlayCountry(country)
            } label: {
                Text(completed ? "Replay" : "Conquer")
                    .font(.system(size: 13, weight: .black, design: .rounded))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                    .background(Capsule().fill(completed ? Color(hex: 0x25_63_EB) : Color(hex: 0x22_C5_5E)))
            }
        }
        .padding(12)
        .background(RoundedRectangle(cornerRadius: 18).fill(Color.white.opacity(0.12)))
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .stroke(completed ? Color(hex: 0x22_C5_5E) : Color.white.opacity(0.25), lineWidth: 1.5)
        )
    }

    private var lockedContinentBanner: some View {
        let prevName = WorldMapCatalog.previousContinentName(for: selectedContinent) ?? "the previous continent"
        return VStack(spacing: 12) {
            Image(systemName: "lock.circle.fill")
                .font(.system(size: 52))
                .foregroundColor(Color(hex: 0xFA_CC_15))
            Text("\(selectedContinent.name) is Locked")
                .font(.system(size: 20, weight: .black, design: .rounded))
                .foregroundColor(.white)
            Text("Complete all 8 representative countries in \(prevName) to unlock \(selectedContinent.name).")
                .font(.system(size: 14, weight: .semibold, design: .rounded))
                .foregroundColor(.white.opacity(0.8))
                .multilineTextAlignment(.center)
        }
        .padding(28)
        .frame(maxWidth: .infinity)
        .background(RoundedRectangle(cornerRadius: 22).fill(Color.white.opacity(0.1)))
        .overlay(RoundedRectangle(cornerRadius: 22).stroke(Color.white.opacity(0.25), lineWidth: 1.5))
        .padding(.top, 18)
    }
}
