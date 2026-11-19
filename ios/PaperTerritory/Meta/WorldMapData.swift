import Foundation

/// Procedural flag layout used to draw crisp native SwiftUI country badges with zero image assets.
enum FlagPattern: String, Codable, Sendable {
    case horizontalTricolor
    case verticalTricolor
    case circleCenter
    case cross
    case canton
    case diagonal
}

/// Visual colors & layout for a country's native flag emblem.
struct CountryFlagStyle: Equatable, Sendable {
    let primaryHex: UInt32
    let secondaryHex: UInt32
    let accentHex: UInt32
    let pattern: FlagPattern
}

/// Representative country stage inside a World Conquest continent.
struct CountryStage: Identifiable, Equatable, Sendable {
    let id: String
    let continentId: String
    let name: String
    let flag: CountryFlagStyle
    let difficulty: BotDifficulty
    let targetPercentage: Double
    let rewardGold: Int
    let rewardDiamonds: Int
}

/// Playable continent containing exactly 8 representative countries.
struct Continent: Identifiable, Equatable, Sendable {
    let id: String
    let name: String
    let orderIndex: Int
    let themeHex: UInt32
    let accentHex: UInt32
    let countries: [CountryStage]
}

/// Complete World Conquest catalog: 6 inhabited continents x 8 representative countries (48 stages).
/// Completing all 8 countries in continent N automatically unlocks continent N + 1.
enum WorldMapCatalog {
    static let continents: [Continent] = [
        Continent(
            id: "asia",
            name: "Asia",
            orderIndex: 0,
            themeHex: 0xEF_44_44,
            accentHex: 0xFB_BF_24,
            countries: asiaCountries
        ),
        Continent(
            id: "europe",
            name: "Europe",
            orderIndex: 1,
            themeHex: 0x25_63_EB,
            accentHex: 0x93_C5_FD,
            countries: europeCountries
        ),
        Continent(
            id: "north_america",
            name: "North America",
            orderIndex: 2,
            themeHex: 0x05_96_69,
            accentHex: 0x6E_E7_B7,
            countries: northAmericaCountries
        ),
        Continent(
            id: "south_america",
            name: "South America",
            orderIndex: 3,
            themeHex: 0xEA_B3_08,
            accentHex: 0x22_C5_5E,
            countries: southAmericaCountries
        ),
        Continent(
            id: "africa",
            name: "Africa",
            orderIndex: 4,
            themeHex: 0xF9_73_16,
            accentHex: 0xFD_E0_47,
            countries: africaCountries
        ),
        Continent(
            id: "oceania",
            name: "Oceania",
            orderIndex: 5,
            themeHex: 0x06_B6_D4,
            accentHex: 0xA5_F3_FC,
            countries: oceaniaCountries
        )
    ]

    static var allCountries: [CountryStage] {
        continents.flatMap(\.countries)
    }

    static func country(withId id: String) -> CountryStage? {
        allCountries.first(where: { $0.id == id })
    }

    static func continent(withId id: String) -> Continent? {
        continents.first(where: { $0.id == id })
    }

    static func completedCount(in continent: Continent, completedCountryIds: Set<String>) -> Int {
        continent.countries.filter { completedCountryIds.contains($0.id) }.count
    }

    static func isContinentCompleted(_ continent: Continent, completedCountryIds: Set<String>) -> Bool {
        completedCount(in: continent, completedCountryIds: completedCountryIds) >= continent.countries.count
    }

    /// Continent 0 (Asia) is unlocked initially; each subsequent continent unlocks when the prior reaches 8/8.
    static func isContinentUnlocked(_ continentId: String, completedCountryIds: Set<String>) -> Bool {
        guard let target = continent(withId: continentId) else { return false }
        if target.orderIndex == 0 {
            return true
        }
        guard let previous = continents.first(where: { $0.orderIndex == target.orderIndex - 1 }) else {
            return false
        }
        return isContinentCompleted(previous, completedCountryIds: completedCountryIds)
    }

    static func previousContinentName(for continent: Continent) -> String? {
        guard continent.orderIndex > 0 else { return nil }
        return continents.first(where: { $0.orderIndex == continent.orderIndex - 1 })?.name
    }

    static func nextContinent(after continentId: String) -> Continent? {
        guard let current = continent(withId: continentId) else { return nil }
        return continents.first(where: { $0.orderIndex == current.orderIndex + 1 })
    }

    // MARK: - 6 Continents x 8 Representative Countries

    private static func stage(
        _ id: String,
        _ continentId: String,
        _ name: String,
        flag: CountryFlagStyle,
        tier: Int
    ) -> CountryStage {
        let difficulty: BotDifficulty = tier < 2 ? .easy : (tier < 4 ? .normal : .hard)
        let targetPct = min(70.0, 35.0 + Double(tier) * 6.0)
        return CountryStage(
            id: id,
            continentId: continentId,
            name: name,
            flag: flag,
            difficulty: difficulty,
            targetPercentage: targetPct,
            rewardGold: 150 + tier * 65,
            rewardDiamonds: 15 + tier * 8
        )
    }

    private static func fl(
        _ primary: UInt32,
        _ secondary: UInt32,
        _ accent: UInt32,
        _ pattern: FlagPattern
    ) -> CountryFlagStyle {
        CountryFlagStyle(primaryHex: primary, secondaryHex: secondary, accentHex: accent, pattern: pattern)
    }

    private static let asiaCountries: [CountryStage] = [
        stage("jp", "asia", "Japan", flag: fl(0xFF_FF_FF, 0xFF_FF_FF, 0xDC_26_26, .circleCenter), tier: 0),
        stage("kr", "asia", "South Korea", flag: fl(0xFF_FF_FF, 0x25_63_EB, 0xDC_26_26, .circleCenter), tier: 0),
        stage("vn", "asia", "Vietnam", flag: fl(0xDA_25_1D, 0xDA_25_1D, 0xFF_FF_00, .circleCenter), tier: 0),
        stage("th", "asia", "Thailand", flag: fl(0xDC_26_26, 0xFF_FF_FF, 0x1E_3A_8A, .horizontalTricolor), tier: 0),
        stage("in", "asia", "India", flag: fl(0xF9_73_16, 0xFF_FF_FF, 0x16_A3_4A, .horizontalTricolor), tier: 0),
        stage("sg", "asia", "Singapore", flag: fl(0xEF_44_44, 0xFF_FF_FF, 0xFF_FF_FF, .horizontalTricolor), tier: 0),
        stage("id", "asia", "Indonesia", flag: fl(0xDC_26_26, 0xDC_26_26, 0xFF_FF_FF, .horizontalTricolor), tier: 0),
        stage("ph", "asia", "Philippines", flag: fl(0x25_63_EB, 0xDC_26_26, 0xFA_CC_15, .canton), tier: 0)
    ]

    private static let europeCountries: [CountryStage] = [
        stage("fr", "europe", "France", flag: fl(0x1D_4E_D8, 0xFF_FF_FF, 0xDC_26_26, .verticalTricolor), tier: 1),
        stage("de", "europe", "Germany", flag: fl(0x11_18_27, 0xDC_26_26, 0xFA_CC_15, .horizontalTricolor), tier: 1),
        stage("it", "europe", "Italy", flag: fl(0x16_A3_4A, 0xFF_FF_FF, 0xDC_26_26, .verticalTricolor), tier: 1),
        stage("es", "europe", "Spain", flag: fl(0xDC_26_26, 0xFA_CC_15, 0xDC_26_26, .horizontalTricolor), tier: 1),
        stage("uk", "europe", "United Kingdom", flag: fl(0x1E_3A_8A, 0xFF_FF_FF, 0xDC_26_26, .cross), tier: 1),
        stage("se", "europe", "Sweden", flag: fl(0x02_84_C7, 0x02_84_C7, 0xFA_CC_15, .cross), tier: 1),
        stage("gr", "europe", "Greece", flag: fl(0x02_84_C7, 0xFF_FF_FF, 0x02_84_C7, .canton), tier: 1),
        stage("ch", "europe", "Switzerland", flag: fl(0xDC_26_26, 0xDC_26_26, 0xFF_FF_FF, .cross), tier: 1)
    ]

    private static let naId = "north_america"
    private static let saId = "south_america"

    private static let northAmericaCountries: [CountryStage] = [
        stage("us", naId, "United States", flag: fl(0xDC_26_26, 0xFF_FF_FF, 0x1E_3A_8A, .canton), tier: 2),
        stage("ca", naId, "Canada", flag: fl(0xDC_26_26, 0xFF_FF_FF, 0xDC_26_26, .verticalTricolor), tier: 2),
        stage("mx", naId, "Mexico", flag: fl(0x15_80_3D, 0xFF_FF_FF, 0xDC_26_26, .verticalTricolor), tier: 2),
        stage("cu", naId, "Cuba", flag: fl(0x1D_4E_D8, 0xFF_FF_FF, 0xDC_26_26, .canton), tier: 2),
        stage("jm", naId, "Jamaica", flag: fl(0x16_A3_4A, 0x11_18_27, 0xFA_CC_15, .diagonal), tier: 2),
        stage("cr", naId, "Costa Rica", flag: fl(0x1D_4E_D8, 0xDC_26_26, 0x1D_4E_D8, .horizontalTricolor), tier: 2),
        stage("pa", naId, "Panama", flag: fl(0xFF_FF_FF, 0xDC_26_26, 0x1D_4E_D8, .canton), tier: 2),
        stage("gl", naId, "Greenland", flag: fl(0xFF_FF_FF, 0xDC_26_26, 0xDC_26_26, .circleCenter), tier: 2)
    ]

    private static let southAmericaCountries: [CountryStage] = [
        stage("br", saId, "Brazil", flag: fl(0x16_A3_4A, 0xFA_CC_15, 0x1D_4E_D8, .circleCenter), tier: 3),
        stage("ar", saId, "Argentina", flag: fl(0x38_BD_F8, 0xFF_FF_FF, 0x38_BD_F8, .horizontalTricolor), tier: 3),
        stage("cl", saId, "Chile", flag: fl(0xFF_FF_FF, 0xDC_26_26, 0x1D_4E_D8, .canton), tier: 3),
        stage("co", saId, "Colombia", flag: fl(0xFA_CC_15, 0x1D_4E_D8, 0xDC_26_26, .horizontalTricolor), tier: 3),
        stage("pe", saId, "Peru", flag: fl(0xDC_26_26, 0xFF_FF_FF, 0xDC_26_26, .verticalTricolor), tier: 3),
        stage("uy", saId, "Uruguay", flag: fl(0xFF_FF_FF, 0x25_63_EB, 0xFA_CC_15, .canton), tier: 3),
        stage("ec", saId, "Ecuador", flag: fl(0xFA_CC_15, 0x1D_4E_D8, 0xB9_1C_1C, .horizontalTricolor), tier: 3),
        stage("bo", saId, "Bolivia", flag: fl(0xDC_26_26, 0xFA_CC_15, 0x16_A3_4A, .horizontalTricolor), tier: 3)
    ]

    private static let africaCountries: [CountryStage] = [
        stage("eg", "africa", "Egypt", flag: fl(0xDC_26_26, 0xFF_FF_FF, 0x11_18_27, .horizontalTricolor), tier: 4),
        stage("ke", "africa", "Kenya", flag: fl(0x11_18_27, 0xDC_26_26, 0x16_A3_4A, .horizontalTricolor), tier: 4),
        stage("ma", "africa", "Morocco", flag: fl(0xB9_1C_1C, 0xB9_1C_1C, 0x15_80_3D, .circleCenter), tier: 4),
        stage("za", "africa", "South Africa", flag: fl(0x16_A3_4A, 0xDC_26_26, 0x1D_4E_D8, .diagonal), tier: 4),
        stage("ng", "africa", "Nigeria", flag: fl(0x15_80_3D, 0xFF_FF_FF, 0x15_80_3D, .verticalTricolor), tier: 4),
        stage("tz", "africa", "Tanzania", flag: fl(0x16_A3_4A, 0x02_84_C7, 0x11_18_27, .diagonal), tier: 4),
        stage("gh", "africa", "Ghana", flag: fl(0xDC_26_26, 0xFA_CC_15, 0x15_80_3D, .horizontalTricolor), tier: 4),
        stage("et", "africa", "Ethiopia", flag: fl(0x16_A3_4A, 0xFA_CC_15, 0xDC_26_26, .horizontalTricolor), tier: 4)
    ]

    private static let oceaniaCountries: [CountryStage] = [
        stage("au", "oceania", "Australia", flag: fl(0x1E_3A_8A, 0x1E_3A_8A, 0xDC_26_26, .canton), tier: 5),
        stage("nz", "oceania", "New Zealand", flag: fl(0x1E_3A_8A, 0x1E_3A_8A, 0xFF_FF_FF, .canton), tier: 5),
        stage("fj", "oceania", "Fiji", flag: fl(0x38_BD_F8, 0x38_BD_F8, 0xDC_26_26, .canton), tier: 5),
        stage("ws", "oceania", "Samoa", flag: fl(0xDC_26_26, 0xDC_26_26, 0x1E_3A_8A, .canton), tier: 5),
        stage("to", "oceania", "Tonga", flag: fl(0xDC_26_26, 0xFF_FF_FF, 0xDC_26_26, .canton), tier: 5),
        stage("pg", "oceania", "Papua New Guinea", flag: fl(0xDC_26_26, 0x11_18_27, 0xFA_CC_15, .diagonal), tier: 5),
        stage("pw", "oceania", "Palau", flag: fl(0x0E_A5_E9, 0x0E_A5_E9, 0xFA_CC_15, .circleCenter), tier: 5),
        stage("vu", "oceania", "Vanuatu", flag: fl(0xDC_26_26, 0x16_A3_4A, 0x11_18_27, .diagonal), tier: 5)
    ]
}
