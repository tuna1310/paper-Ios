import Foundation

/// Shop bundle or deal in the Shop screen.
struct GemPackItem: Identifiable {
    let id: String
    let gems: Int
    let priceLabel: String
    let badgeText: String?
    let stackTier: Int
}

struct CoinPackItem: Identifiable {
    let id: String
    let coins: Int
    let gemCost: Int
    let badgeText: String?
    let stackTier: Int
}

/// Reward granted when opening a chest or claiming daily offers.
struct ChestRevealReward: Identifiable {
    let id = UUID()
    let title: String
    let subtitle: String
    let coins: Int
    let gems: Int
    let heroId: String?
    let heroCardsAmount: Int
    let unlockedSkinId: String?
}

/// One day in the 7-day daily login reward calendar.
struct DailyLoginReward: Identifiable {
    let id: Int // Day 1...7
    let title: String
    let coins: Int
    let gems: Int
    let specialSkinId: String?

    var dayNumber: Int { id }
}

enum ShopCatalog {
    static let gemPacks: [GemPackItem] = [
        GemPackItem(id: "gems_20", gems: 20, priceLabel: "$0.99", badgeText: nil, stackTier: 1),
        GemPackItem(id: "gems_110", gems: 110, priceLabel: "$4.99", badgeText: nil, stackTier: 2),
        GemPackItem(id: "gems_500", gems: 500, priceLabel: "$19.99", badgeText: nil, stackTier: 3),
        GemPackItem(id: "gems_1100", gems: 1100, priceLabel: "$39.99", badgeText: "BEST VALUE", stackTier: 4)
    ]

    static let coinPacks: [CoinPackItem] = [
        CoinPackItem(id: "coins_3500", coins: 3500, gemCost: 20, badgeText: nil, stackTier: 1),
        CoinPackItem(id: "coins_22000", coins: 22000, gemCost: 100, badgeText: nil, stackTier: 2),
        CoinPackItem(id: "coins_70000", coins: 70000, gemCost: 300, badgeText: "MOST POPULAR", stackTier: 3),
        CoinPackItem(id: "coins_225000", coins: 225000, gemCost: 900, badgeText: nil, stackTier: 4)
    ]

    static let dailyLoginRewards: [DailyLoginReward] = [
        DailyLoginReward(id: 1, title: "500 Coins", coins: 500, gems: 0, specialSkinId: nil),
        DailyLoginReward(id: 2, title: "10 Gems", coins: 0, gems: 10, specialSkinId: nil),
        DailyLoginReward(id: 3, title: "Fox Skin", coins: 800, gems: 0, specialSkinId: "streak3"),
        DailyLoginReward(id: 4, title: "1,500 Coins", coins: 1500, gems: 0, specialSkinId: nil),
        DailyLoginReward(id: 5, title: "25 Gems", coins: 0, gems: 25, specialSkinId: nil),
        DailyLoginReward(id: 6, title: "3,000 Coins", coins: 3000, gems: 10, specialSkinId: nil),
        DailyLoginReward(id: 7, title: "Golden Lion", coins: 2500, gems: 35, specialSkinId: "streak7")
    ]
}
