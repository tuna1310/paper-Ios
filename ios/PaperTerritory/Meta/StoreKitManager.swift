import Combine
import Foundation
import StoreKit

/// Reward payload fulfilled when a real-money StoreKit 2 purchase completes.
enum StoreProductKind: Equatable, Sendable {
    case goldPack(Int)
    case diamondPack(Int)
    case skin(skinId: String)
}

/// Real-money shop offer backed by an App Store Connect / StoreKit 2 product ID.
struct StoreOffer: Identifiable, Equatable, Sendable {
    let id: String
    let title: String
    let subtitle: String
    let fallbackPrice: String
    let badge: String?
    let kind: StoreProductKind
}

/// Catalog of real-money Gold packs, Diamond packs, and Premium Skins sold via StoreKit 2.
enum StoreCatalog {
    static let goldOffers: [StoreOffer] = [
        StoreOffer(
            id: "com.paperterritory.gold.small",
            title: "1,500 Gold",
            subtitle: "Starter Gold Pouch",
            fallbackPrice: "$0.99",
            badge: nil,
            kind: .goldPack(1_500)
        ),
        StoreOffer(
            id: "com.paperterritory.gold.medium",
            title: "5,000 Gold",
            subtitle: "Popular Treasure Bag",
            fallbackPrice: "$2.99",
            badge: "POPULAR",
            kind: .goldPack(5_000)
        ),
        StoreOffer(
            id: "com.paperterritory.gold.large",
            title: "15,000 Gold",
            subtitle: "Royal Gold Vault",
            fallbackPrice: "$6.99",
            badge: "BEST VALUE",
            kind: .goldPack(15_000)
        )
    ]

    static let diamondOffers: [StoreOffer] = [
        StoreOffer(
            id: "com.paperterritory.diamonds.small",
            title: "120 Diamonds",
            subtitle: "Sparkling Gem Pouch",
            fallbackPrice: "$0.99",
            badge: nil,
            kind: .diamondPack(120)
        ),
        StoreOffer(
            id: "com.paperterritory.diamonds.medium",
            title: "450 Diamonds",
            subtitle: "Crystal Vault Pack",
            fallbackPrice: "$2.99",
            badge: "POPULAR",
            kind: .diamondPack(450)
        ),
        StoreOffer(
            id: "com.paperterritory.diamonds.large",
            title: "1,400 Diamonds",
            subtitle: "Mythic Diamond Hoard",
            fallbackPrice: "$7.99",
            badge: "BEST VALUE",
            kind: .diamondPack(1_400)
        )
    ]

    static var skinOffers: [StoreOffer] {
        SkinCatalog.all.compactMap { skin in
            guard case let .realMoney(productId, fallbackPrice) = skin.price else {
                return nil
            }
            return StoreOffer(
                id: productId,
                title: skin.name,
                subtitle: "\(skin.rarity.displayName) Exclusive Skin",
                fallbackPrice: fallbackPrice,
                badge: skin.rarity.displayName.uppercased(),
                kind: .skin(skinId: skin.id)
            )
        }
    }

    static var allOffers: [StoreOffer] {
        goldOffers + diamondOffers + skinOffers
    }

    static func offer(withId id: String) -> StoreOffer? {
        allOffers.first(where: { $0.id == id })
    }
}

/// Outcome of a StoreKit 2 purchase attempt.
enum StorePurchaseOutcome: Equatable, Sendable {
    case purchased(StoreOffer)
    case cancelled
    case pending
    case storeUnavailable(String)
    case failed(String)
}

/// Native Apple StoreKit 2 manager (zero third-party payment SDKs).
@MainActor
final class StoreKitManager: ObservableObject {
    @Published private(set) var productsById: [String: Product] = [:]
    @Published private(set) var isLoadingProducts = false
    @Published var statusMessage: String?

    var onVerifiedOffer: ((StoreOffer) -> Void)?

    func listenForTransactions() async {
        for await result in Transaction.updates {
            await handleTransactionResult(result)
        }
    }

    func loadProducts() async {
        isLoadingProducts = true
        defer { isLoadingProducts = false }
        let ids = StoreCatalog.allOffers.map(\.id)
        do {
            let loaded = try await Product.products(for: ids)
            var map: [String: Product] = [:]
            for product in loaded {
                map[product.id] = product
            }
            productsById = map
        } catch {
            statusMessage = "App Store products unavailable right now."
        }
    }

    func displayPrice(for offer: StoreOffer) -> String {
        productsById[offer.id]?.displayPrice ?? offer.fallbackPrice
    }

    func purchase(_ offer: StoreOffer) async -> StorePurchaseOutcome {
        if productsById.isEmpty {
            await loadProducts()
        }
        guard let product = productsById[offer.id] else {
            let msg = "StoreKit product not configured on App Store Connect for this sideloaded build."
            statusMessage = msg
            return .storeUnavailable(msg)
        }

        do {
            let result = try await product.purchase()
            switch result {
            case let .success(verification):
                guard case let .verified(transaction) = verification else {
                    return .failed("Purchase verification failed.")
                }
                await transaction.finish()
                onVerifiedOffer?(offer)
                statusMessage = "Purchased \(offer.title)!"
                return .purchased(offer)
            case .userCancelled:
                return .cancelled
            case .pending:
                statusMessage = "Purchase pending parental or App Store approval."
                return .pending
            @unknown default:
                return .failed("Unexpected StoreKit response.")
            }
        } catch {
            statusMessage = "Purchase failed: \(error.localizedDescription)"
            return .failed(error.localizedDescription)
        }
    }

    func restorePurchases() async {
        do {
            try await AppStore.sync()
            for await result in Transaction.currentEntitlements {
                await handleTransactionResult(result)
            }
            statusMessage = "Purchases restored."
        } catch {
            statusMessage = "Restore failed: \(error.localizedDescription)"
        }
    }

    private func handleTransactionResult(_ result: VerificationResult<Transaction>) async {
        guard case let .verified(transaction) = result else { return }
        if let offer = StoreCatalog.offer(withId: transaction.productID) {
            onVerifiedOffer?(offer)
        }
        await transaction.finish()
    }
}
