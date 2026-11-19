import SwiftUI

/// Primary navigation tabs for the Paper Territory native hub.
enum MainTab: String, CaseIterable, Identifiable {
    case play
    case world
    case missions
    case rank
    case shop

    var id: String {
        rawValue
    }

    var title: String {
        switch self {
        case .play:
            return "Play"
        case .world:
            return "World"
        case .missions:
            return "Missions"
        case .rank:
            return "Rank"
        case .shop:
            return "Shop"
        }
    }

    var iconName: String {
        switch self {
        case .play:
            return "gamecontroller.fill"
        case .world:
            return "globe.americas.fill"
        case .missions:
            return "checklist"
        case .rank:
            return "trophy.fill"
        case .shop:
            return "bag.fill"
        }
    }
}

/// Active play session identifier passed to `.fullScreenCover`.
struct ActiveMatchSession: Identifiable {
    let id = UUID()
    let countryStage: CountryStage?
}

/// Root container view hosting the native SwiftUI Home Hub, World Map, Missions, Rank, Shop, and SpriteKit Arena.
struct ContentView: View {
    @StateObject private var store = PlayerProfileStore()
    @StateObject private var storeKit = StoreKitManager()
    @State private var selectedTab: MainTab = .play
    @State private var activeSession: ActiveMatchSession?
    @State private var showSettings = false

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color(hex: 0x0B_3B_8C), Color(hex: 0x09_1E_42)],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: 10) {
                topStatusBar
                tabBody
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                bottomTabBar
            }

            if let chestReward = store.latestChestReward {
                Color.black.opacity(0.65)
                    .ignoresSafeArea()
                    .onTapGesture {
                        store.latestChestReward = nil
                    }
                RewardModalView(reward: chestReward) {
                    store.latestChestReward = nil
                }
            }
        }
        .fullScreenCover(item: $activeSession) { session in
            DemoPlayView(profileStore: store, countryStage: session.countryStage) {
                activeSession = nil
            }
        }
        .sheet(isPresented: $showSettings) {
            SettingsView(store: store, storeKit: storeKit)
        }
        .onAppear {
            store.ensureDailyMissionsCurrent()
        }
        .task {
            storeKit.onVerifiedOffer = { offer in
                store.fulfillStoreOffer(offer)
            }
            await storeKit.listenForTransactions()
        }
    }

    private var topStatusBar: some View {
        HStack(spacing: 8) {
            Button {
                selectedTab = .rank
            } label: {
                RankBadgeView(tier: store.currentRankTier, compact: true)
            }

            Spacer()

            CurrencyPillView(iconName: "circle.fill", iconHex: 0xFA_CC_15, amount: store.profile.gold)
            CurrencyPillView(iconName: "diamond.fill", iconHex: 0x38_BD_F8, amount: store.profile.diamonds)

            Button {
                showSettings = true
            } label: {
                Image(systemName: "gearshape.fill")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.white)
                    .padding(7)
                    .background(Circle().fill(Color.white.opacity(0.16)))
            }
        }
        .padding(.horizontal, 14)
        .padding(.top, 8)
    }

    @ViewBuilder
    private var tabBody: some View {
        switch selectedTab {
        case .play:
            HomeView(
                store: store,
                onPlayClassic: { activeSession = ActiveMatchSession(countryStage: nil) },
                onOpenWorld: { selectedTab = .world },
                onOpenShop: { selectedTab = .shop }
            )
        case .world:
            WorldMapView(store: store) { country in
                activeSession = ActiveMatchSession(countryStage: country)
            }
        case .missions:
            MissionsView(store: store)
        case .rank:
            RankView(store: store)
        case .shop:
            ShopView(store: store, storeKit: storeKit)
        }
    }

    private var bottomTabBar: some View {
        HStack(spacing: 6) {
            ForEach(MainTab.allCases) { tab in
                let active = selectedTab == tab
                Button {
                    selectedTab = tab
                } label: {
                    VStack(spacing: 3) {
                        ZStack(alignment: .topTrailing) {
                            Image(systemName: tab.iconName)
                                .font(.system(size: 17, weight: .bold))
                            if tab == .missions && store.profile.dailyMissions.canClaimChest {
                                Circle()
                                    .fill(Color(hex: 0xEF_44_44))
                                    .frame(width: 8, height: 8)
                                    .offset(x: 4, y: -3)
                            }
                        }
                        Text(tab.title)
                            .font(.system(size: 10, weight: .black, design: .rounded))
                    }
                    .foregroundColor(active ? Color(hex: 0xFA_CC_15) : .white.opacity(0.68))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                    .background(
                        RoundedRectangle(cornerRadius: 14)
                            .fill(active ? Color.white.opacity(0.16) : Color.clear)
                    )
                }
            }
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(Color(hex: 0x06_11_28).opacity(0.92))
    }
}
