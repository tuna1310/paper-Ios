import Foundation

/// Three Hero Chest tiers sold in the Shop for Diamonds.
enum HeroChestTier: String, CaseIterable, Identifiable, Sendable {
    case common
    case rare
    case superChest

    var id: String {
        rawValue
    }

    var displayName: String {
        switch self {
        case .common:
            return "Common Chest"
        case .rare:
            return "Rare Chest"
        case .superChest:
            return "Super Chest"
        }
    }

    var diamondCost: Int {
        switch self {
        case .common:
            return GameConfig.commonChestDiamonds
        case .rare:
            return GameConfig.rareChestDiamonds
        case .superChest:
            return GameConfig.superChestDiamonds
        }
    }

    var skinDropChance: Double {
        switch self {
        case .common:
            return 0.15
        case .rare:
            return 0.40
        case .superChest:
            return 0.80
        }
    }

    var oddsDescription: String {
        switch self {
        case .common:
            return "15% Common/Rare Skin + Gold & Diamonds"
        case .rare:
            return "40% Rare/Epic Skin + Big Gold & Diamonds"
        case .superChest:
            return "80% Epic/Legendary Skin + Mega Rewards"
        }
    }

    var eligibleRarities: [SkinRarity] {
        switch self {
        case .common:
            return [.common, .rare]
        case .rare:
            return [.rare, .epic]
        case .superChest:
            return [.epic, .legendary]
        }
    }

    var primaryHex: UInt32 {
        switch self {
        case .common:
            return 0x3B_82_F6
        case .rare:
            return 0x93_33_EA
        case .superChest:
            return 0xF5_9E_0B
        }
    }

    var secondaryHex: UInt32 {
        switch self {
        case .common:
            return 0x1D_4E_D8
        case .rare:
            return 0x58_1C_87
        case .superChest:
            return 0xB4_53_09
        }
    }
}

/// Deterministic Hero Chest reward generator.
enum HeroChestRoller {
    static func roll(
        tier: HeroChestTier,
        ownedSkinIds: Set<String>,
        rng: inout SeededRandomGenerator
    ) -> ChestReward {
        let baseGold: Int
        let baseDiamonds: Int
        switch tier {
        case .common:
            baseGold = Int.random(in: 120...320, using: &rng)
            baseDiamonds = Int.random(in: 8...25, using: &rng)
        case .rare:
            baseGold = Int.random(in: 350...850, using: &rng)
            baseDiamonds = Int.random(in: 25...75, using: &rng)
        case .superChest:
            baseGold = Int.random(in: 900...2_000, using: &rng)
            baseDiamonds = Int.random(in: 70...180, using: &rng)
        }

        let pool = SkinCatalog.skins(for: tier.eligibleRarities).filter { !ownedSkinIds.contains($0.id) }
        let skinRoll = Double.random(in: 0..<1, using: &rng)

        if skinRoll < tier.skinDropChance, !pool.isEmpty {
            let pick = pool[Int.random(in: 0..<pool.count, using: &rng)]
            return ChestReward(
                sourceName: tier.displayName,
                gold: baseGold,
                diamonds: baseDiamonds,
                unlockedSkinId: pick.id
            )
        }

        // Extra currency compensation when no skin drops or pool is already complete.
        let bonusGold = tier == .superChest ? 450 : (tier == .rare ? 180 : 60)
        return ChestReward(
            sourceName: tier.displayName,
            gold: baseGold + bonusGold,
            diamonds: baseDiamonds,
            unlockedSkinId: nil
        )
    }
}
