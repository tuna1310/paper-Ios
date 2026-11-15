import SwiftUI

/// 5-tab bottom navigation bar faithfully matching the video layout.
struct BottomTabBar: View {
    @EnvironmentObject var store: GameStore

    var body: some View {
        ZStack(alignment: .bottom) {
            // Crisp white curved bottom dock
            RoundedCornerShape(radius: 26, corners: [.topLeft, .topRight])
                .fill(Color.white)
                .frame(height: 76)
                .shadow(color: Color.black.opacity(0.16), radius: 10, y: -3)
                .overlay(
                    Rectangle()
                        .fill(Color(hex: "E2E8F0"))
                        .frame(height: 1.5),
                    alignment: .top
                )
                .ignoresSafeArea(edges: .bottom)

            HStack(alignment: .bottom, spacing: 0) {
                ForEach(MainTab.allCases) { tab in
                    tabButton(for: tab)
                        .frame(maxWidth: .infinity)
                }
            }
            .padding(.horizontal, 8)
            .padding(.bottom, 6)
        }
        .frame(height: 92)
    }

    @ViewBuilder
    private func tabButton(for tab: MainTab) -> some View {
        let isSelected = store.selectedTab == tab

        Button {
            SoundHapticsManager.shared.playTap()
            withAnimation(.spring(response: 0.28, dampingFraction: 0.72)) {
                store.selectedTab = tab
            }
        } label: {
            if tab == .home {
                // Prominent central yellow circular Home button
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [Color(hex: "FFE44A"), Color(hex: "F59E0B")],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .frame(width: isSelected ? 72 : 64, height: isSelected ? 72 : 64)
                        .overlay(
                            Circle()
                                .stroke(Color.white, lineWidth: 4.5)
                        )
                        .shadow(color: Color.black.opacity(0.24), radius: 6, y: 4)

                    Image(systemName: "house.fill")
                        .font(.system(size: isSelected ? 30 : 26, weight: .bold))
                        .foregroundColor(.white)
                        .shadow(color: Color(hex: "B45309").opacity(0.45), radius: 1, y: 2)
                }
                .offset(y: isSelected ? -14 : -10)
            } else {
                VStack(spacing: 3) {
                    ZStack {
                        if isSelected {
                            Circle()
                                .fill(Color.white)
                                .frame(width: 58, height: 58)
                                .shadow(color: Color.black.opacity(0.12), radius: 5, y: -1)
                        }

                        tabIcon(for: tab, isSelected: isSelected)
                            .scaleEffect(isSelected ? 1.15 : 0.94)
                            .overlay(alignment: .topTrailing) {
                                badgeView(for: tab)
                                    .offset(x: 6, y: -4)
                            }
                    }
                    .frame(height: 50)
                    .offset(y: isSelected ? -10 : 0)

                    if isSelected {
                        Text(tab.title)
                            .font(.system(size: 12, weight: .heavy, design: .rounded))
                            .foregroundColor(Color(hex: "0B3C7A"))
                            .lineLimit(1)
                            .offset(y: -6)
                    }
                }
                .frame(height: 76)
            }
        }
        .buttonStyle(BouncyButtonStyle())
    }

    @ViewBuilder
    private func badgeView(for tab: MainTab) -> some View {
        switch tab {
        case .shop where store.uncollectedShopBadgeCount > 0:
            Circle()
                .fill(Color(hex: "EF4444"))
                .frame(width: 19, height: 19)
                .overlay(Circle().stroke(Color.white, lineWidth: 1.5))
                .overlay(
                    Text("\(store.uncollectedShopBadgeCount)")
                        .font(.system(size: 11, weight: .black, design: .rounded))
                        .foregroundColor(.white)
                )
        case .heroes:
            let hasUpgrade = SkinCatalog.all.contains { skin in
                skin.category.isHeroTier && store.heroCardsCount(for: skin.id) >= store.heroCardsTarget(for: skin)
            }
            if hasUpgrade || !store.state.freeCardsClaimedToday {
                Circle()
                    .fill(Color(hex: "EF4444"))
                    .frame(width: 13, height: 13)
                    .overlay(Circle().stroke(Color.white, lineWidth: 1.5))
            }
        case .missions:
            let readyClaim = store.state.dailyMissions.contains { $0.isCompleted && !$0.isClaimed }
            if readyClaim {
                Circle()
                    .fill(Color(hex: "22C55E"))
                    .frame(width: 13, height: 13)
                    .overlay(Circle().stroke(Color.white, lineWidth: 1.5))
            }
        default:
            EmptyView()
        }
    }

    @ViewBuilder
    private func tabIcon(for tab: MainTab, isSelected: Bool) -> some View {
        switch tab {
        case .shop:
            ShopAwningIcon()
        case .heroes:
            HeroMascotTabIcon()
        case .home:
            EmptyView()
        case .missions:
            MissionsClipboardTabIcon()
        case .world:
            WorldGlobeTabIcon()
        }
    }
}

// MARK: - Stylized Cartoon Tab Icons (matching video)

private struct ShopAwningIcon: View {
    var body: some View {
        VStack(spacing: 0) {
            // Red & white striped awning roof
            HStack(spacing: 0) {
                ForEach(0..<5, id: \.self) { idx in
                    Rectangle()
                        .fill(idx.isMultiple(of: 2) ? Color(hex: "EF4444") : Color.white)
                }
            }
            .frame(width: 34, height: 11)
            .clipShape(RoundedCornerShape(radius: 4, corners: [.topLeft, .topRight]))
            .overlay(
                RoundedCornerShape(radius: 4, corners: [.topLeft, .topRight])
                    .stroke(Color(hex: "1E293B"), lineWidth: 1.5)
            )

            // Storefront lower box
            ZStack {
                RoundedCornerShape(radius: 4, corners: [.bottomLeft, .bottomRight])
                    .fill(Color(hex: "E2E8F0"))
                    .frame(width: 30, height: 17)
                    .overlay(
                        RoundedCornerShape(radius: 4, corners: [.bottomLeft, .bottomRight])
                            .stroke(Color(hex: "1E293B"), lineWidth: 1.5)
                    )
                RoundedRectangle(cornerRadius: 2)
                    .fill(Color(hex: "38BDF8"))
                    .frame(width: 16, height: 9)
            }
        }
    }
}

private struct HeroMascotTabIcon: View {
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [Color(hex: "FFE44D"), Color(hex: "F59E0B")],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(width: 32, height: 28)
                .overlay(
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .stroke(Color(hex: "92400E"), lineWidth: 1.6)
                )

            HStack(spacing: 4) {
                Circle()
                    .fill(Color.white)
                    .frame(width: 9, height: 9)
                    .overlay(Circle().fill(Color(hex: "1D4ED8")).frame(width: 5, height: 5))
                Circle()
                    .fill(Color.white)
                    .frame(width: 9, height: 9)
                    .overlay(Circle().fill(Color(hex: "1D4ED8")).frame(width: 5, height: 5))
            }
            .offset(y: -1)
        }
    }
}

private struct MissionsClipboardTabIcon: View {
    var body: some View {
        ZStack(alignment: .top) {
            RoundedRectangle(cornerRadius: 6, style: .continuous)
                .fill(Color(hex: "38BDF8"))
                .frame(width: 28, height: 32)
                .overlay(
                    RoundedRectangle(cornerRadius: 6, style: .continuous)
                        .stroke(Color(hex: "0369A1"), lineWidth: 1.6)
                )

            RoundedRectangle(cornerRadius: 4, style: .continuous)
                .fill(Color.white)
                .frame(width: 22, height: 24)
                .offset(y: 5)
                .overlay(
                    Image(systemName: "checkmark")
                        .font(.system(size: 13, weight: .black))
                        .foregroundColor(Color(hex: "22C55E"))
                        .offset(y: 5)
                )

            RoundedRectangle(cornerRadius: 3)
                .fill(Color(hex: "FACC15"))
                .frame(width: 14, height: 6)
                .overlay(RoundedRectangle(cornerRadius: 3).stroke(Color(hex: "92400E"), lineWidth: 1))
                .offset(y: -2)
        }
    }
}

private struct WorldGlobeTabIcon: View {
    var body: some View {
        ZStack {
            Circle()
                .fill(
                    LinearGradient(
                        colors: [Color(hex: "38BDF8"), Color(hex: "0284C7")],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 34, height: 34)
                .overlay(Circle().stroke(Color(hex: "0C4A6E"), lineWidth: 1.6))

            // Stylized green continents
            Circle()
                .fill(Color(hex: "4ADE80"))
                .frame(width: 14, height: 16)
                .offset(x: -5, y: -3)
            Circle()
                .fill(Color(hex: "22C55E"))
                .frame(width: 11, height: 13)
                .offset(x: 7, y: 5)
            Ellipse()
                .fill(Color(hex: "4ADE80"))
                .frame(width: 10, height: 7)
                .offset(x: 6, y: -8)
        }
        .clipShape(Circle())
    }
}
