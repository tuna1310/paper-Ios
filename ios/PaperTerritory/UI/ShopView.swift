import SwiftUI

/// Shop tab categories: Skins (Gold/Diamonds/Real Money), Hero Chests (Diamonds), Gold Packs, Diamond Packs.
enum ShopSection: String, CaseIterable, Identifiable {
    case skins
    case chests
    case gold
    case diamonds

    var id: String {
        rawValue
    }

    var title: String {
        switch self {
        case .skins:
            return "Skins"
        case .chests:
            return "Hero Chests"
        case .gold:
            return "Gold"
        case .diamonds:
            return "Diamonds"
        }
    }
}

/// Full native Shop featuring Skins, Hero Chests (Common/Rare/Super), Real-Money Gold, and Real-Money Diamonds.
struct ShopView: View {
    @ObservedObject var store: PlayerProfileStore
    @ObservedObject var storeKit: StoreKitManager
    @State private var selectedSection: ShopSection = .skins
    @State private var pendingOffer: StoreOffer?

    private let skinColumns = [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)]

    var body: some View {
        VStack(spacing: 12) {
            sectionPicker

            if let message = store.feedbackBanner ?? storeKit.statusMessage {
                Text(message)
                    .font(.system(size: 13, weight: .bold, design: .rounded))
                    .foregroundColor(Color(hex: 0xFA_CC_15))
                    .padding(.horizontal, 12)
                    .multilineTextAlignment(.center)
            }

            ScrollView {
                switch selectedSection {
                case .skins:
                    skinsGrid
                case .chests:
                    heroChestsList
                case .gold:
                    realMoneyOffersList(
                        title: "Gold Store",
                        icon: "circle.fill",
                        iconHex: 0xFA_CC_15,
                        offers: StoreCatalog.goldOffers
                    )
                case .diamonds:
                    realMoneyOffersList(
                        title: "Diamond Store",
                        icon: "diamond.fill",
                        iconHex: 0x38_BD_F8,
                        offers: StoreCatalog.diamondOffers
                    )
                }
            }
        }
        .padding(.horizontal, 14)
        .sheet(item: $pendingOffer) { offer in
            ParentGateView(
                offerTitle: offer.title,
                offerPrice: storeKit.displayPrice(for: offer),
                onApproved: {
                    pendingOffer = nil
                    Task {
                        _ = await storeKit.purchase(offer)
                    }
                },
                onCancel: {
                    pendingOffer = nil
                }
            )
        }
        .task {
            await storeKit.loadProducts()
        }
    }

    private var sectionPicker: some View {
        HStack(spacing: 6) {
            ForEach(ShopSection.allCases) { section in
                let active = selectedSection == section
                Button {
                    selectedSection = section
                    store.feedbackBanner = nil
                } label: {
                    Text(section.title)
                        .font(.system(size: 12, weight: .black, design: .rounded))
                        .foregroundColor(active ? Color(hex: 0x0F_17_2A) : .white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                        .background(Capsule().fill(active ? Color(hex: 0xFA_CC_15) : Color.white.opacity(0.14)))
                }
            }
        }
    }

    private var skinsGrid: some View {
        LazyVGrid(columns: skinColumns, spacing: 12) {
            ForEach(SkinCatalog.all) { skin in
                skinCard(skin)
            }
        }
        .padding(.bottom, 24)
    }

    private func skinCard(_ skin: SkinDefinition) -> some View {
        let owned = store.profile.ownedSkinIds.contains(skin.id)
        let equipped = store.profile.equippedSkinId == skin.id

        return VStack(spacing: 8) {
            HStack {
                Text(skin.rarity.displayName.uppercased())
                    .font(.system(size: 9, weight: .black, design: .rounded))
                    .foregroundColor(.white)
                    .padding(.horizontal, 7)
                    .padding(.vertical, 3)
                    .background(Capsule().fill(Color(hex: skin.rarity.badgeHex)))
                Spacer()
                if equipped {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(Color(hex: 0x22_C5_5E))
                }
            }

            SkinAvatarView(skin: skin, size: 54)

            Text(skin.name)
                .font(.system(size: 14, weight: .black, design: .rounded))
                .foregroundColor(.white)
                .lineLimit(1)

            skinActionButton(skin: skin, owned: owned, equipped: equipped)
        }
        .padding(12)
        .background(RoundedRectangle(cornerRadius: 18).fill(Color.white.opacity(0.12)))
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .stroke(equipped ? Color(hex: 0x22_C5_5E) : Color.white.opacity(0.25), lineWidth: equipped ? 2.5 : 1)
        )
    }

    private func skinActionButton(skin: SkinDefinition, owned: Bool, equipped: Bool) -> some View {
        Button {
            handleSkinTap(skin, owned: owned)
        } label: {
            Text(skinButtonLabel(skin: skin, owned: owned, equipped: equipped))
                .font(.system(size: 12, weight: .black, design: .rounded))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 7)
                .background(Capsule().fill(skinButtonColor(skin: skin, owned: owned, equipped: equipped)))
        }
    }

    private func handleSkinTap(_ skin: SkinDefinition, owned: Bool) {
        if owned {
            store.equipSkin(skin.id)
            return
        }
        if case let .realMoney(productId, _) = skin.price {
            pendingOffer = StoreCatalog.offer(withId: productId)
            return
        }
        _ = store.buySkin(skin)
    }

    private func skinButtonLabel(skin: SkinDefinition, owned: Bool, equipped: Bool) -> String {
        if equipped {
            return "Equipped"
        }
        if owned {
            return "Equip"
        }
        switch skin.price {
        case .free:
            return "Free"
        case let .gold(cost):
            return "\(cost) Gold"
        case let .diamonds(cost):
            return "\(cost) Diamonds"
        case let .realMoney(productId, fallback):
            if let offer = StoreCatalog.offer(withId: productId) {
                return storeKit.displayPrice(for: offer)
            }
            return fallback
        }
    }

    private func skinButtonColor(skin: SkinDefinition, owned: Bool, equipped: Bool) -> Color {
        if equipped {
            return Color(hex: 0x16_A3_4A)
        }
        if owned {
            return Color(hex: 0x25_63_EB)
        }
        switch skin.price {
        case .free:
            return Color(hex: 0x22_C5_5E)
        case .gold:
            return Color(hex: 0xD9_77_06)
        case .diamonds:
            return Color(hex: 0x02_84_C7)
        case .realMoney:
            return Color(hex: 0x93_33_EA)
        }
    }

    private var heroChestsList: some View {
        VStack(spacing: 14) {
            ForEach(HeroChestTier.allCases) { tier in
                HStack(spacing: 14) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 16)
                            .fill(
                                LinearGradient(
                                    colors: [Color(hex: tier.primaryHex), Color(hex: tier.secondaryHex)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 66, height: 66)
                        Image(systemName: "shippingbox.fill")
                            .font(.system(size: 30))
                            .foregroundColor(.white)
                    }

                    VStack(alignment: .leading, spacing: 4) {
                        Text(tier.displayName)
                            .font(.system(size: 17, weight: .black, design: .rounded))
                            .foregroundColor(.white)
                        Text(tier.oddsDescription)
                            .font(.system(size: 12, weight: .semibold, design: .rounded))
                            .foregroundColor(.white.opacity(0.8))
                    }

                    Spacer()

                    Button {
                        _ = store.openHeroChest(tier)
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: "diamond.fill")
                                .font(.system(size: 12))
                            Text("\(tier.diamondCost)")
                                .font(.system(size: 14, weight: .black, design: .rounded))
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 10)
                        .background(Capsule().fill(Color(hex: 0x02_84_C7)))
                        .overlay(Capsule().stroke(Color.white.opacity(0.65), lineWidth: 1.5))
                    }
                }
                .padding(14)
                .background(RoundedRectangle(cornerRadius: 20).fill(Color.white.opacity(0.12)))
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color(hex: tier.primaryHex).opacity(0.8), lineWidth: 1.5)
                )
            }
        }
        .padding(.bottom, 24)
    }

    private func realMoneyOffersList(
        title: String,
        icon: String,
        iconHex: UInt32,
        offers: [StoreOffer]
    ) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.system(size: 16, weight: .black, design: .rounded))
                .foregroundColor(.white)

            ForEach(offers) { offer in
                HStack(spacing: 14) {
                    Image(systemName: icon)
                        .font(.system(size: 28))
                        .foregroundColor(Color(hex: iconHex))
                        .frame(width: 50, height: 50)
                        .background(Circle().fill(Color.white.opacity(0.12)))

                    VStack(alignment: .leading, spacing: 3) {
                        HStack(spacing: 6) {
                            Text(offer.title)
                                .font(.system(size: 16, weight: .black, design: .rounded))
                                .foregroundColor(.white)
                            if let badge = offer.badge {
                                Text(badge)
                                    .font(.system(size: 9, weight: .black, design: .rounded))
                                    .foregroundColor(Color(hex: 0x0F_17_2A))
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 2)
                                    .background(Capsule().fill(Color(hex: 0xFA_CC_15)))
                            }
                        }
                        Text(offer.subtitle)
                            .font(.system(size: 12, weight: .semibold, design: .rounded))
                            .foregroundColor(.white.opacity(0.75))
                    }

                    Spacer()

                    Button {
                        pendingOffer = offer
                    } label: {
                        Text(storeKit.displayPrice(for: offer))
                            .font(.system(size: 14, weight: .black, design: .rounded))
                            .foregroundColor(.white)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 10)
                            .background(Capsule().fill(Color(hex: 0x22_C5_5E)))
                    }
                }
                .padding(14)
                .background(RoundedRectangle(cornerRadius: 18).fill(Color.white.opacity(0.12)))
                .overlay(RoundedRectangle(cornerRadius: 18).stroke(Color.white.opacity(0.25), lineWidth: 1))
            }

            Text("Real-money purchases use Apple StoreKit and require Parent Gate confirmation.")
                .font(.system(size: 11, weight: .semibold, design: .rounded))
                .foregroundColor(.white.opacity(0.65))
                .padding(.top, 4)
        }
        .padding(.bottom, 24)
    }
}
