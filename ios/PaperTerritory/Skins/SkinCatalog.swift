import Foundation

/// Visual rarity tier for collectible skins and chest drop pools.
enum SkinRarity: String, Codable, CaseIterable, Sendable {
    case common
    case rare
    case epic
    case legendary

    var displayName: String {
        switch self {
        case .common:
            return "Common"
        case .rare:
            return "Rare"
        case .epic:
            return "Epic"
        case .legendary:
            return "Legendary"
        }
    }

    var badgeHex: UInt32 {
        switch self {
        case .common:
            return 0x64_74_8B
        case .rare:
            return 0x25_63_EB
        case .epic:
            return 0x93_33_EA
        case .legendary:
            return 0xF5_9E_0B
        }
    }
}

/// Procedural surface motif rendered on both SwiftUI skin cards and SpriteKit player blocks.
enum SkinPattern: String, Codable, CaseIterable, Sendable {
    case solid
    case stripes
    case checker
    case star
    case crown
    case visor
    case horns
    case halo
}

/// Acquisition currency or IAP binding for a skin in the Shop.
enum SkinPrice: Equatable, Hashable, Sendable {
    case free
    case gold(Int)
    case diamonds(Int)
    case realMoney(productId: String, fallbackPrice: String)
}

/// Pure-native procedural skin definition.
struct SkinDefinition: Identifiable, Equatable, Hashable, Sendable {
    let id: String
    let name: String
    let palette: EntityPalette
    let accentHex: UInt32
    let pattern: SkinPattern
    let rarity: SkinRarity
    let price: SkinPrice
}

/// Full native catalog of Paper.io 2-inspired procedural skins (Gold, Diamonds, and Real-Money IAP).
enum SkinCatalog {
    static let starterSkinId = "classic_pink"

    static let all: [SkinDefinition] = [
        SkinDefinition(
            id: "classic_pink",
            name: "Classic Pink",
            palette: SkinPalette.playerDefault,
            accentHex: 0xFF_D6_E4,
            pattern: .solid,
            rarity: .common,
            price: .free
        ),
        SkinDefinition(
            id: "ocean_wave",
            name: "Ocean Wave",
            palette: EntityPalette(baseHex: 0x0E_A5_E9, darkHex: 0x03_69_A1, trailHex: 0x7D_D3_FC),
            accentHex: 0xE0_F2_FE,
            pattern: .stripes,
            rarity: .common,
            price: .gold(250)
        ),
        SkinDefinition(
            id: "neon_slime",
            name: "Neon Slime",
            palette: EntityPalette(baseHex: 0x22_C5_5E, darkHex: 0x15_80_3D, trailHex: 0x86_EF_AC),
            accentHex: 0xDC_FC_E7,
            pattern: .checker,
            rarity: .common,
            price: .gold(400)
        ),
        SkinDefinition(
            id: "solar_flare",
            name: "Solar Flare",
            palette: EntityPalette(baseHex: 0xF9_73_16, darkHex: 0xC2_41_0C, trailHex: 0xFD_BA_74),
            accentHex: 0xFE_F0_8A,
            pattern: .stripes,
            rarity: .common,
            price: .gold(600)
        ),
        SkinDefinition(
            id: "arctic_fox",
            name: "Arctic Fox",
            palette: EntityPalette(baseHex: 0x38_BD_F8, darkHex: 0x02_84_C7, trailHex: 0xBA_E6_FD),
            accentHex: 0xFF_FF_FF,
            pattern: .visor,
            rarity: .common,
            price: .gold(850)
        ),
        SkinDefinition(
            id: "sakura_bloom",
            name: "Sakura Bloom",
            palette: EntityPalette(baseHex: 0xF4_72_B6, darkHex: 0xBE_18_5D, trailHex: 0xFB_CF_E8),
            accentHex: 0xFF_F1_F2,
            pattern: .star,
            rarity: .rare,
            price: .gold(1_200)
        ),
        SkinDefinition(
            id: "cyber_violet",
            name: "Cyber Violet",
            palette: EntityPalette(baseHex: 0x8B_5C_F6, darkHex: 0x5B_21_B6, trailHex: 0xC4_B5_FD),
            accentHex: 0x38_BD_F8,
            pattern: .visor,
            rarity: .rare,
            price: .gold(1_800)
        ),
        SkinDefinition(
            id: "emerald_knight",
            name: "Emerald Knight",
            palette: EntityPalette(baseHex: 0x10_B9_81, darkHex: 0x04_78_57, trailHex: 0x6E_E7_B7),
            accentHex: 0xFD_E0_47,
            pattern: .crown,
            rarity: .rare,
            price: .gold(2_500)
        ),
        SkinDefinition(
            id: "lava_core",
            name: "Lava Core",
            palette: EntityPalette(baseHex: 0xEF_44_44, darkHex: 0x99_1B_1B, trailHex: 0xFC_A5_A5),
            accentHex: 0xFB_BF_24,
            pattern: .horns,
            rarity: .rare,
            price: .diamonds(80)
        ),
        SkinDefinition(
            id: "shadow_ninja",
            name: "Shadow Ninja",
            palette: EntityPalette(baseHex: 0x33_41_55, darkHex: 0x0F_17_2A, trailHex: 0x94_A3_B8),
            accentHex: 0xEF_44_44,
            pattern: .visor,
            rarity: .rare,
            price: .diamonds(120)
        ),
        SkinDefinition(
            id: "gold_ingot",
            name: "Gold Ingot",
            palette: EntityPalette(baseHex: 0xEA_B3_08, darkHex: 0xA1_62_07, trailHex: 0xFD_E0_47),
            accentHex: 0xFF_FB_EB,
            pattern: .crown,
            rarity: .epic,
            price: .diamonds(220)
        ),
        SkinDefinition(
            id: "galaxy_star",
            name: "Galaxy Star",
            palette: EntityPalette(baseHex: 0x4F_46_E5, darkHex: 0x31_2E_81, trailHex: 0xA5_B4_FC),
            accentHex: 0xFE_F0_8A,
            pattern: .star,
            rarity: .epic,
            price: .diamonds(300)
        ),
        SkinDefinition(
            id: "frost_titan",
            name: "Frost Titan",
            palette: EntityPalette(baseHex: 0x06_B6_D4, darkHex: 0x15_5E_75, trailHex: 0x67_E8_F9),
            accentHex: 0xEC_FE_FF,
            pattern: .horns,
            rarity: .epic,
            price: .diamonds(380)
        ),
        SkinDefinition(
            id: "royal_sovereign",
            name: "Royal Sovereign",
            palette: EntityPalette(baseHex: 0xA8_55_F7, darkHex: 0x6B_21_A8, trailHex: 0xD8_B4_FE),
            accentHex: 0xFA_CC_15,
            pattern: .crown,
            rarity: .epic,
            price: .diamonds(480)
        ),
        SkinDefinition(
            id: "dragon_scale",
            name: "Dragon Scale",
            palette: EntityPalette(baseHex: 0xDC_26_26, darkHex: 0x7F_1D_1D, trailHex: 0xF8_71_71),
            accentHex: 0xFA_CC_15,
            pattern: .horns,
            rarity: .legendary,
            price: .diamonds(650)
        ),
        SkinDefinition(
            id: "celestial_angel",
            name: "Celestial Halo",
            palette: EntityPalette(baseHex: 0x3B_82_F6, darkHex: 0x1D_4E_D8, trailHex: 0x93_C5_FD),
            accentHex: 0xFE_F0_8A,
            pattern: .halo,
            rarity: .legendary,
            price: .diamonds(850)
        ),
        SkinDefinition(
            id: "phoenix_blaze",
            name: "Phoenix Blaze",
            palette: EntityPalette(baseHex: 0xEA_58_0C, darkHex: 0x9A_34_12, trailHex: 0xFB_92_3C),
            accentHex: 0xFE_F0_8A,
            pattern: .halo,
            rarity: .legendary,
            price: .realMoney(productId: "com.paperterritory.skin.phoenix", fallbackPrice: "$1.99")
        ),
        SkinDefinition(
            id: "diamond_prism",
            name: "Diamond Prism",
            palette: EntityPalette(baseHex: 0x22_D3_EE, darkHex: 0x0E_74_90, trailHex: 0xA5_F3_FC),
            accentHex: 0xFF_FF_FF,
            pattern: .star,
            rarity: .legendary,
            price: .realMoney(productId: "com.paperterritory.skin.diamond_prism", fallbackPrice: "$2.99")
        ),
        SkinDefinition(
            id: "void_emperor",
            name: "Void Emperor",
            palette: EntityPalette(baseHex: 0x7C_3A_ED, darkHex: 0x2E_10_65, trailHex: 0xC4_B5_FD),
            accentHex: 0xF4_3F_5E,
            pattern: .crown,
            rarity: .legendary,
            price: .realMoney(productId: "com.paperterritory.skin.void_emperor", fallbackPrice: "$4.99")
        )
    ]

    static func skin(withId id: String) -> SkinDefinition {
        all.first(where: { $0.id == id }) ?? all[0]
    }

    static func skins(for rarities: [SkinRarity]) -> [SkinDefinition] {
        all.filter { rarities.contains($0.rarity) }
    }
}
