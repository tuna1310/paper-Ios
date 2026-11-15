import SwiftUI

/// Bottom navigation bar tabs matching the 5-tab layout.
enum MainTab: Int, CaseIterable, Identifiable {
    case shop = 0
    case heroes = 1
    case home = 2
    case missions = 3
    case world = 4

    var id: Int { rawValue }

    var title: String {
        switch self {
        case .shop: return "Shop"
        case .heroes: return "Heroes"
        case .home: return "Home"
        case .missions: return "Missions"
        case .world: return "World"
        }
    }
}

/// Rarity and collection tier for skins and heroes.
enum SkinCategory: String, Codable, CaseIterable, Identifiable {
    case common
    case rare
    case epic
    case legendary
    case classic
    case flagsAndEvents

    var id: String { rawValue }

    var title: String {
        switch self {
        case .common: return "Common"
        case .rare: return "Rare"
        case .epic: return "Epic"
        case .legendary: return "Legendary"
        case .classic: return "Classic"
        case .flagsAndEvents: return "Flags & Events"
        }
    }

    var badgeColors: [Color] {
        switch self {
        case .common:
            return [Color(hex: "3AB7FF"), Color(hex: "1C88EB")]
        case .rare:
            return [Color(hex: "FFCE3A"), Color(hex: "F59E0B")]
        case .epic:
            return [Color(hex: "F455C8"), Color(hex: "B624E3")]
        case .legendary:
            return [Color(hex: "FF5E62"), Color(hex: "FFCE3A"), Color(hex: "38E58D"), Color(hex: "3AB7FF"), Color(hex: "C855FF")]
        case .classic:
            return [Color(hex: "41C7FF"), Color(hex: "2297E8")]
        case .flagsAndEvents:
            return [Color(hex: "FF7B39"), Color(hex: "E93F6D")]
        }
    }

    var isHeroTier: Bool {
        switch self {
        case .common, .rare, .epic, .legendary:
            return true
        case .classic, .flagsAndEvents:
            return false
        }
    }
}

/// Passive attribute badges displayed on Hero cards.
enum HeroPerkType: String, Codable, Hashable {
    case speed
    case shield
    case magnet
    case vision

    var systemIcon: String {
        switch self {
        case .speed: return "bolt.fill"
        case .shield: return "shield.fill"
        case .magnet: return "scope"
        case .vision: return "eye.fill"
        }
    }

    var badgeColor: Color {
        switch self {
        case .speed: return Color(hex: "22C55E")
        case .shield: return Color(hex: "3B82F6")
        case .magnet: return Color(hex: "F59E0B")
        case .vision: return Color(hex: "EC4899")
        }
    }
}

/// Territory surface visual style rendered inside the arena.
enum TerritoryPattern: Codable, Hashable {
    case solid
    case gradient
    case spots
    case sprinkles
    case brainWaves
    case stripes
    case stars
    case grid
    case cobweb
    case snowflakes
    case flag(String)
}

/// Trail particle & ribbon styles for skins.
enum TrailEffectStyle: String, Codable, CaseIterable {
    case classic
    case sparkle
    case rainbow
    case flame
    case ice
    case neon
    case bubbles
}

/// Supported playable game modes.
enum GameModeType: String, Codable, CaseIterable, Identifiable {
    case worldConquest
    case classic
    case teamBattle
    case halloweenEvent
    case christmasEvent

    var id: String { rawValue }

    var title: String {
        switch self {
        case .worldConquest: return "World Map"
        case .classic: return "Classic Arena"
        case .teamBattle: return "Team Battle"
        case .halloweenEvent: return "Halloween"
        case .christmasEvent: return "Winter Frost"
        }
    }

    var subtitle: String {
        switch self {
        case .worldConquest: return "Conquer countries toward 100%"
        case .classic: return "Free-for-all crown showdown"
        case .teamBattle: return "Red Team vs Blue Team (5v5)"
        case .halloweenEvent: return "Limited Event • Spooky Map"
        case .christmasEvent: return "Limited Event • Snowy Map"
        }
    }

    var iconName: String {
        switch self {
        case .worldConquest: return "globe.americas.fill"
        case .classic: return "crown.fill"
        case .teamBattle: return "shield.lefthalf.filled"
        case .halloweenEvent: return "moon.stars.fill"
        case .christmasEvent: return "snowflake"
        }
    }

    var accentColors: [Color] {
        switch self {
        case .worldConquest: return [Color(hex: "28B6FF"), Color(hex: "0A7BE3")]
        case .classic: return [Color(hex: "FFD538"), Color(hex: "F59E0B")]
        case .teamBattle: return [Color(hex: "FF4B5C"), Color(hex: "2B7BFF")]
        case .halloweenEvent: return [Color(hex: "FF7D29"), Color(hex: "6D28D9")]
        case .christmasEvent: return [Color(hex: "38BDF8"), Color(hex: "0284C7")]
        }
    }

    var isSeasonal: Bool {
        self == .halloweenEvent || self == .christmasEvent
    }
}

/// Collectible in-match power-up orbs.
enum PowerUpOrbType: String, CaseIterable {
    case speed
    case shield
    case magnet
    case giant

    var title: String {
        switch self {
        case .speed: return "TURBO"
        case .shield: return "SHIELD"
        case .magnet: return "MAGNET"
        case .giant: return "GIANT"
        }
    }

    var colorHex: String {
        switch self {
        case .speed: return "9333EA"
        case .shield: return "0EA5E9"
        case .magnet: return "F59E0B"
        case .giant: return "10B981"
        }
    }

    var systemIcon: String {
        switch self {
        case .speed: return "bolt.fill"
        case .shield: return "shield.fill"
        case .magnet: return "dot.radiowaves.left.and.right"
        case .giant: return "arrow.up.left.and.arrow.down.right"
        }
    }
}

/// Chest rarity tiers available in the Shop.
enum ChestRarity: String, Codable, CaseIterable, Identifiable {
    case common
    case rare
    case epic
    case legendary

    var id: String { rawValue }

    var title: String {
        switch self {
        case .common: return "Common"
        case .rare: return "Rare"
        case .epic: return "Epic"
        case .legendary: return "Legendary"
        }
    }

    var gemCost: Int {
        switch self {
        case .common: return 10
        case .rare: return 70
        case .epic: return 120
        case .legendary: return 300
        }
    }

    var cardColors: [Color] {
        switch self {
        case .common: return [Color(hex: "4CC3FF"), Color(hex: "1B8CEB")]
        case .rare: return [Color(hex: "FFE14D"), Color(hex: "F59E0B")]
        case .epic: return [Color(hex: "F455C8"), Color(hex: "9D1FE0")]
        case .legendary: return [Color(hex: "FF5E62"), Color(hex: "FFD53D"), Color(hex: "2BE3AC"), Color(hex: "9B51E0")]
        }
    }
}

/// Unlock requirements displayed on skin cards and evaluated by GameStore.
enum SkinUnlockRule: Codable, Hashable {
    case free
    case coins(Int)
    case gems(Int)
    case heroCards(Int)
    case loginStreak(Int)
    case totalKills(Int)
    case chestsOpened(Int)
    case powerOrbsUsed(Int)
    case countriesCompleted(Int)
    case powerUpsUsed(Int)
    case revivesUsed(Int)
    case seasonalEvent(String)

    var shortRequirementText: String? {
        switch self {
        case .free, .coins, .gems, .heroCards:
            return nil
        case .loginStreak(let n):
            return "Play \(n) days in a row"
        case .totalKills(let n):
            return "Defeat \(n) enemies"
        case .chestsOpened(let n):
            return "Open \(n) chests"
        case .powerOrbsUsed(let n):
            return "Use \(n) power orbs"
        case .countriesCompleted(let n):
            return "Complete \(n) countries"
        case .powerUpsUsed(let n):
            return "Use \(n) power-ups"
        case .revivesUsed(let n):
            return "Revive \(n) time\(n == 1 ? "" : "s")"
        case .seasonalEvent(let event):
            return "\(event) Event"
        }
    }
}

/// 3D geometric archetype used to build both SceneKit and 2D thumbnails.
enum SkinBlueprint: String, Codable, Hashable {
    // Signature skins seen in video
    case wizard
    case watermelon
    case brain
    case car
    case cow
    case dino
    case donut
    case ghost
    case rhino
    case unicorn
    case whale
    case hammer
    case ufo
    case eagle
    case hippo
    case droidCubey

    // Hero archetypes
    case heroCube
    case heroVisor
    case heroCrown
    case heroFlame
    case heroFrost
    case heroNinja
    case heroRobot
    case heroDragon

    // Classic archetypes
    case flagCube
    case animalFox
    case animalCat
    case animalPanda
    case animalFrog
    case animalBee
    case animalPenguin
    case animalLion
    case animalShark
    case animalPig
    case animalDuck
    case foodBurger
    case foodPizza
    case foodSushi
    case foodTaco
    case foodAvocado
    case foodCheese
    case objectRocket
    case objectCrown
    case objectDiamond
    case objectPlanet
    case objectRubik
    case objectDice
    case objectBomb
    case objectCactus
    case seasonalPumpkin
    case seasonalVampire
    case seasonalSanta
    case seasonalSnowman
    case seasonalReindeer
}

/// Complete definition of an unlockable skin or hero.
struct SkinDefinition: Identifiable, Hashable {
    let id: String
    let name: String
    let category: SkinCategory
    let blueprint: SkinBlueprint
    let primaryHex: String
    let secondaryHex: String
    let accentHex: String
    let territoryPattern: TerritoryPattern
    let trailEffect: TrailEffectStyle
    let unlockRule: SkinUnlockRule
    let perks: [HeroPerkType]
    let flagCode: String?

    var primaryColor: Color { Color(hex: primaryHex) }
    var secondaryColor: Color { Color(hex: secondaryHex) }
    var accentColor: Color { Color(hex: accentHex) }
}

// MARK: - Color & Shape Helpers

extension Color {
    init(hex: String) {
        let cleaned = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: cleaned).scanHexInt64(&int)
        let r, g, b, a: UInt64
        switch cleaned.count {
        case 3:
            (r, g, b, a) = ((int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17, 255)
        case 6:
            (r, g, b, a) = (int >> 16, int >> 8 & 0xFF, int & 0xFF, 255)
        case 8:
            (r, g, b, a) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (r, g, b, a) = (255, 255, 255, 255)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255.0,
            green: Double(g) / 255.0,
            blue: Double(b) / 255.0,
            opacity: Double(a) / 255.0
        )
    }
}

extension UIColor {
    convenience init(hex: String) {
        let cleaned = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: cleaned).scanHexInt64(&int)
        let r, g, b, a: UInt64
        switch cleaned.count {
        case 6:
            (r, g, b, a) = (int >> 16, int >> 8 & 0xFF, int & 0xFF, 255)
        case 8:
            (r, g, b, a) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (r, g, b, a) = (255, 255, 255, 255)
        }
        self.init(
            red: CGFloat(r) / 255.0,
            green: CGFloat(g) / 255.0,
            blue: CGFloat(b) / 255.0,
            alpha: CGFloat(a) / 255.0
        )
    }
}

/// Custom rounded corners shape compatible with iOS 16+.
struct RoundedCornerShape: Shape {
    var radius: CGFloat = 16
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let bezier = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(bezier.cgPath)
    }
}

extension Int {
    /// Formats currency like Paper.io 2 (`13.78K`, `1.2M`, `44`).
    var compactFormatted: String {
        if self >= 1_000_000 {
            return String(format: "%.2fM", Double(self) / 1_000_000.0)
        } else if self >= 10_000 {
            return String(format: "%.2fK", Double(self) / 1_000.0)
        }
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.groupingSeparator = ","
        return formatter.string(from: NSNumber(value: self)) ?? "\(self)"
    }
}
