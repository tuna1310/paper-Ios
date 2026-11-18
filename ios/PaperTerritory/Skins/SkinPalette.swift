import Foundation

/// Color triple for an entity's territory fill, 2.5D bevel edge, and ribbon trail.
struct EntityPalette: Sendable {
    let baseHex: UInt32
    let darkHex: UInt32
    let trailHex: UInt32
}

/// Deterministic high-contrast color palettes for Step 1–2 arena rendering.
/// Step 4 replaces/extends this with the 120+ procedural SkinGenerator catalog.
enum SkinPalette {
    static let playerDefault = EntityPalette(
        baseHex: 0xFF_2A_6D,
        darkHex: 0xC8_13_4E,
        trailHex: 0xFF_75_9E
    )

    static let distinctBotPalettes: [EntityPalette] = [
        EntityPalette(baseHex: 0x1D_8A_FF, darkHex: 0x0D_5C_C4, trailHex: 0x74_BA_FF),
        EntityPalette(baseHex: 0x1E_C7_73, darkHex: 0x0F_91_4F, trailHex: 0x73_E4_AB),
        EntityPalette(baseHex: 0xFF_A8_1C, darkHex: 0xC7_75_00, trailHex: 0xFF_CD_75),
        EntityPalette(baseHex: 0x9B_4D_FF, darkHex: 0x67_23_C4, trailHex: 0xC6_96_FF),
        EntityPalette(baseHex: 0x00_C4_D6, darkHex: 0x00_89_99, trailHex: 0x66_E3_EE),
        EntityPalette(baseHex: 0xFF_62_B0, darkHex: 0xC4_2B_78, trailHex: 0xFF_9E_CE),
        EntityPalette(baseHex: 0x7C_D9_14, darkHex: 0x4E_98_00, trailHex: 0xAE_EC_68),
        EntityPalette(baseHex: 0xFF_5C_38, darkHex: 0xC2_32_14, trailHex: 0xFF_9B_84),
        EntityPalette(baseHex: 0x3D_5A_FE, darkHex: 0x1E_34_B8, trailHex: 0x89_9B_FF),
        EntityPalette(baseHex: 0xF5_C4_00, darkHex: 0xB8_8F_00, trailHex: 0xFA_DF_66),
        EntityPalette(baseHex: 0x00_BF_A5, darkHex: 0x00_82_70, trailHex: 0x64_DF_CD),
        EntityPalette(baseHex: 0xD9_46_EF, darkHex: 0x9B_19_B0, trailHex: 0xEC_8E_F6),
        EntityPalette(baseHex: 0xF9_73_16, darkHex: 0xBA_49_00, trailHex: 0xFC_AC_72),
        EntityPalette(baseHex: 0x0E_A5_E9, darkHex: 0x03_69_A1, trailHex: 0x67_CA_FA),
        EntityPalette(baseHex: 0xEC_48_99, darkHex: 0xAD_1F_65, trailHex: 0xF4_8F_C1)
    ]

    static func rgbaLittleEndian(hex: UInt32, alpha: UInt8 = 255) -> UInt32 {
        let r = UInt32((hex >> 16) & 0xFF)
        let g = UInt32((hex >> 8) & 0xFF)
        let b = UInt32(hex & 0xFF)
        let a = UInt32(alpha)
        return (a << 24) | (b << 16) | (g << 8) | r
    }
}
