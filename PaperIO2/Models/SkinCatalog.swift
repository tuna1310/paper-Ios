import Foundation

/// Master catalog of 104 skins across Common/Rare/Epic/Legendary Heroes, Classic skins, and Country Flags & Seasonal Events.
enum SkinCatalog {
    static let all: [SkinDefinition] = {
        var list: [SkinDefinition] = []
        list.append(contentsOf: commonHeroes)
        list.append(contentsOf: rareHeroes)
        list.append(contentsOf: epicHeroes)
        list.append(contentsOf: legendaryHeroes)
        list.append(contentsOf: classicSkins)
        list.append(contentsOf: flagAndEventSkins)
        return list
    }()

    static func byCategory(_ category: SkinCategory) -> [SkinDefinition] {
        all.filter { $0.category == category }
    }

    static func skin(id: String) -> SkinDefinition {
        all.first { $0.id == id } ?? classicSkins.first { $0.id == "wizard" } ?? all[0]
    }

    // MARK: - Common Heroes (7)
    static let commonHeroes: [SkinDefinition] = [
        SkinDefinition(id: "hero_cubey", name: "Cubey", category: .common, blueprint: .heroCube, primaryHex: "FFCE2B", secondaryHex: "F59E0B", accentHex: "38BDF8", territoryPattern: .gradient, trailEffect: .classic, unlockRule: .free, perks: [.speed], flagCode: nil),
        SkinDefinition(id: "hero_droid", name: "Droid Cubey", category: .common, blueprint: .droidCubey, primaryHex: "3B82F6", secondaryHex: "1D4ED8", accentHex: "22D3EE", territoryPattern: .grid, trailEffect: .neon, unlockRule: .heroCards(40), perks: [.speed, .shield], flagCode: nil),
        SkinDefinition(id: "hero_spark", name: "Spark", category: .common, blueprint: .heroVisor, primaryHex: "22C55E", secondaryHex: "15803D", accentHex: "FDE047", territoryPattern: .stripes, trailEffect: .sparkle, unlockRule: .heroCards(40), perks: [.speed], flagCode: nil),
        SkinDefinition(id: "hero_shielder", name: "Bulwark", category: .common, blueprint: .heroRobot, primaryHex: "64748B", secondaryHex: "334155", accentHex: "38BDF8", territoryPattern: .grid, trailEffect: .classic, unlockRule: .heroCards(40), perks: [.shield], flagCode: nil),
        SkinDefinition(id: "hero_scout", name: "Scout", category: .common, blueprint: .heroVisor, primaryHex: "FB923C", secondaryHex: "C2410C", accentHex: "FEF08A", territoryPattern: .dots, trailEffect: .bubbles, unlockRule: .heroCards(40), perks: [.vision], flagCode: nil),
        SkinDefinition(id: "hero_magneto", name: "Puller", category: .common, blueprint: .heroCube, primaryHex: "EF4444", secondaryHex: "B91C1C", accentHex: "E2E8F0", territoryPattern: .gradient, trailEffect: .classic, unlockRule: .heroCards(40), perks: [.magnet], flagCode: nil),
        SkinDefinition(id: "hero_dash", name: "Dasher", category: .common, blueprint: .heroNinja, primaryHex: "06B6D4", secondaryHex: "0E7490", accentHex: "F43F5E", territoryPattern: .stripes, trailEffect: .neon, unlockRule: .heroCards(40), perks: [.speed, .vision], flagCode: nil)
    ]

    // MARK: - Rare Heroes (4)
    static let rareHeroes: [SkinDefinition] = [
        SkinDefinition(id: "hero_blaze", name: "Blaze", category: .rare, blueprint: .heroFlame, primaryHex: "FF5E3A", secondaryHex: "DC2626", accentHex: "FACC15", territoryPattern: .gradient, trailEffect: .flame, unlockRule: .heroCards(60), perks: [.speed, .magnet], flagCode: nil),
        SkinDefinition(id: "hero_frost", name: "Frostbite", category: .rare, blueprint: .heroFrost, primaryHex: "38BDF8", secondaryHex: "0284C7", accentHex: "E0F2FE", territoryPattern: .snowflakes, trailEffect: .ice, unlockRule: .heroCards(60), perks: [.shield, .speed], flagCode: nil),
        SkinDefinition(id: "hero_shadow", name: "Shadow", category: .rare, blueprint: .heroNinja, primaryHex: "312E81", secondaryHex: "1E1B4B", accentHex: "A855F7", territoryPattern: .stars, trailEffect: .sparkle, unlockRule: .heroCards(60), perks: [.vision, .speed], flagCode: nil),
        SkinDefinition(id: "hero_volt", name: "Volt", category: .rare, blueprint: .heroRobot, primaryHex: "EAB308", secondaryHex: "A16207", accentHex: "22D3EE", territoryPattern: .grid, trailEffect: .neon, unlockRule: .heroCards(60), perks: [.speed, .shield], flagCode: nil)
    ]

    // MARK: - Epic Heroes (3)
    static let epicHeroes: [SkinDefinition] = [
        SkinDefinition(id: "hero_nova", name: "Nova", category: .epic, blueprint: .heroCrown, primaryHex: "D946EF", secondaryHex: "86198F", accentHex: "FDE047", territoryPattern: .stars, trailEffect: .sparkle, unlockRule: .heroCards(80), perks: [.speed, .magnet, .vision], flagCode: nil),
        SkinDefinition(id: "hero_mecha", name: "Mecha Rex", category: .epic, blueprint: .heroRobot, primaryHex: "10B981", secondaryHex: "047857", accentHex: "FB7185", territoryPattern: .grid, trailEffect: .neon, unlockRule: .heroCards(80), perks: [.shield, .magnet], flagCode: nil),
        SkinDefinition(id: "hero_valkyrie", name: "Valkyrie", category: .epic, blueprint: .heroCrown, primaryHex: "EC4899", secondaryHex: "9D174D", accentHex: "38BDF8", territoryPattern: .gradient, trailEffect: .rainbow, unlockRule: .heroCards(80), perks: [.speed, .shield, .vision], flagCode: nil)
    ]

    // MARK: - Legendary Heroes (3)
    static let legendaryHeroes: [SkinDefinition] = [
        SkinDefinition(id: "hero_dragon", name: "Astral Dragon", category: .legendary, blueprint: .heroDragon, primaryHex: "F59E0B", secondaryHex: "B45309", accentHex: "EF4444", territoryPattern: .gradient, trailEffect: .flame, unlockRule: .heroCards(100), perks: [.speed, .shield, .magnet, .vision], flagCode: nil),
        SkinDefinition(id: "hero_cosmic", name: "Cosmic King", category: .legendary, blueprint: .heroCrown, primaryHex: "6366F1", secondaryHex: "3730A3", accentHex: "F472B6", territoryPattern: .stars, trailEffect: .rainbow, unlockRule: .heroCards(100), perks: [.speed, .shield, .magnet, .vision], flagCode: nil),
        SkinDefinition(id: "hero_prism", name: "Prism God", category: .legendary, blueprint: .heroFlame, primaryHex: "14B8A6", secondaryHex: "0F766E", accentHex: "FDE047", territoryPattern: .sprinkles, trailEffect: .rainbow, unlockRule: .heroCards(100), perks: [.speed, .shield, .magnet, .vision], flagCode: nil)
    ]

    // MARK: - Classic Skins (67 — matching video count & iconic models)
    static let classicSkins: [SkinDefinition] = [
        // 14 Starting Unlocked / Video Showcase Classics
        SkinDefinition(id: "brain", name: "Brain", category: .classic, blueprint: .brain, primaryHex: "F48FB1", secondaryHex: "C2185B", accentHex: "FCE4EC", territoryPattern: .brainWaves, trailEffect: .bubbles, unlockRule: .free, perks: [], flagCode: nil),
        SkinDefinition(id: "car", name: "Car", category: .classic, blueprint: .car, primaryHex: "EF4444", secondaryHex: "991B1B", accentHex: "38BDF8", territoryPattern: .stripes, trailEffect: .flame, unlockRule: .free, perks: [], flagCode: nil),
        SkinDefinition(id: "cow", name: "Cow", category: .classic, blueprint: .cow, primaryHex: "F8FAFC", secondaryHex: "1E293B", accentHex: "F472B6", territoryPattern: .spots, trailEffect: .classic, unlockRule: .free, perks: [], flagCode: nil),
        SkinDefinition(id: "dino", name: "Dino", category: .classic, blueprint: .dino, primaryHex: "2563EB", secondaryHex: "1E40AF", accentHex: "93C5FD", territoryPattern: .spots, trailEffect: .classic, unlockRule: .free, perks: [], flagCode: nil),
        SkinDefinition(id: "donut", name: "Donut", category: .classic, blueprint: .donut, primaryHex: "F472B6", secondaryHex: "D97706", accentHex: "38BDF8", territoryPattern: .sprinkles, trailEffect: .rainbow, unlockRule: .free, perks: [], flagCode: nil),
        SkinDefinition(id: "ghost", name: "Ghost", category: .classic, blueprint: .ghost, primaryHex: "E2E8F0", secondaryHex: "94A3B8", accentHex: "7C3AED", territoryPattern: .gradient, trailEffect: .sparkle, unlockRule: .free, perks: [], flagCode: nil),
        SkinDefinition(id: "hippo", name: "Hippo", category: .classic, blueprint: .hippo, primaryHex: "8B85A1", secondaryHex: "5B5470", accentHex: "F9A8D4", territoryPattern: .dots, trailEffect: .bubbles, unlockRule: .free, perks: [], flagCode: nil),
        SkinDefinition(id: "ufo", name: "UFO", category: .classic, blueprint: .ufo, primaryHex: "84CC16", secondaryHex: "4D7C0F", accentHex: "38BDF8", territoryPattern: .stars, trailEffect: .neon, unlockRule: .free, perks: [], flagCode: nil),
        SkinDefinition(id: "unicorn", name: "Unicorn", category: .classic, blueprint: .unicorn, primaryHex: "F9A8D4", secondaryHex: "EC4899", accentHex: "FDE047", territoryPattern: .gradient, trailEffect: .rainbow, unlockRule: .free, perks: [], flagCode: nil),
        SkinDefinition(id: "whale", name: "Whale", category: .classic, blueprint: .whale, primaryHex: "38BDF8", secondaryHex: "0369A1", accentHex: "FFFFFF", territoryPattern: .bubblesPattern, trailEffect: .bubbles, unlockRule: .free, perks: [], flagCode: nil),
        SkinDefinition(id: "eagle", name: "Eagle", category: .classic, blueprint: .eagle, primaryHex: "92400E", secondaryHex: "451A03", accentHex: "FACC15", territoryPattern: .stripes, trailEffect: .classic, unlockRule: .free, perks: [], flagCode: nil),
        SkinDefinition(id: "hammer", name: "Hammer", category: .classic, blueprint: .hammer, primaryHex: "60A5FA", secondaryHex: "1E3A8A", accentHex: "94A3B8", territoryPattern: .grid, trailEffect: .neon, unlockRule: .free, perks: [], flagCode: nil),
        SkinDefinition(id: "wizard", name: "Wizard", category: .classic, blueprint: .wizard, primaryHex: "6D28D9", secondaryHex: "4C1D95", accentHex: "F97316", territoryPattern: .gradient, trailEffect: .sparkle, unlockRule: .free, perks: [], flagCode: nil),
        SkinDefinition(id: "watermelon", name: "Watermelon", category: .classic, blueprint: .watermelon, primaryHex: "EF4444", secondaryHex: "16A34A", accentHex: "1E293B", territoryPattern: .dots, trailEffect: .classic, unlockRule: .free, perks: [], flagCode: nil),

        // Additional showcase + milestone skins (matching video sequence)
        SkinDefinition(id: "rhino", name: "Rhino", category: .classic, blueprint: .rhino, primaryHex: "64748B", secondaryHex: "475569", accentHex: "E2E8F0", territoryPattern: .solid, trailEffect: .classic, unlockRule: .coins(2500), perks: [], flagCode: nil),
        SkinDefinition(id: "streak3", name: "Fox", category: .classic, blueprint: .animalFox, primaryHex: "F97316", secondaryHex: "C2410C", accentHex: "FFFFFF", territoryPattern: .gradient, trailEffect: .flame, unlockRule: .loginStreak(3), perks: [], flagCode: nil),
        SkinDefinition(id: "streak7", name: "Golden Lion", category: .classic, blueprint: .animalLion, primaryHex: "F59E0B", secondaryHex: "B45309", accentHex: "FEF08A", territoryPattern: .stars, trailEffect: .sparkle, unlockRule: .loginStreak(7), perks: [], flagCode: nil),
        SkinDefinition(id: "kills300", name: "Great Shark", category: .classic, blueprint: .animalShark, primaryHex: "0EA5E9", secondaryHex: "0369A1", accentHex: "F1F5F9", territoryPattern: .stripes, trailEffect: .bubbles, unlockRule: .totalKills(300), perks: [], flagCode: nil),
        SkinDefinition(id: "chests24", name: "Diamond", category: .classic, blueprint: .objectDiamond, primaryHex: "22D3EE", secondaryHex: "0284C7", accentHex: "FFFFFF", territoryPattern: .grid, trailEffect: .sparkle, unlockRule: .chestsOpened(24), perks: [], flagCode: nil),
        SkinDefinition(id: "orbs50", name: "Planet", category: .classic, blueprint: .objectPlanet, primaryHex: "8B5CF6", secondaryHex: "4C1D95", accentHex: "FDE047", territoryPattern: .stars, trailEffect: .neon, unlockRule: .powerOrbsUsed(50), perks: [], flagCode: nil),
        SkinDefinition(id: "orbs150", name: "Rocket", category: .classic, blueprint: .objectRocket, primaryHex: "F43F5E", secondaryHex: "9F1239", accentHex: "FBBF24", territoryPattern: .stars, trailEffect: .flame, unlockRule: .powerOrbsUsed(150), perks: [], flagCode: nil),
        SkinDefinition(id: "countries10", name: "Royal Crown", category: .classic, blueprint: .objectCrown, primaryHex: "FACC15", secondaryHex: "CA8A04", accentHex: "EF4444", territoryPattern: .gradient, trailEffect: .sparkle, unlockRule: .countriesCompleted(10), perks: [], flagCode: nil),
        SkinDefinition(id: "power30", name: "Bumblebee", category: .classic, blueprint: .animalBee, primaryHex: "FACC15", secondaryHex: "1E293B", accentHex: "E0F2FE", territoryPattern: .stripes, trailEffect: .sparkle, unlockRule: .powerUpsUsed(30), perks: [], flagCode: nil),
        SkinDefinition(id: "power60", name: "Frog", category: .classic, blueprint: .animalFrog, primaryHex: "22C55E", secondaryHex: "15803D", accentHex: "FEF08A", territoryPattern: .spots, trailEffect: .bubbles, unlockRule: .powerUpsUsed(60), perks: [], flagCode: nil),
        SkinDefinition(id: "power120", name: "Rubik Cube", category: .classic, blueprint: .objectRubik, primaryHex: "EF4444", secondaryHex: "2563EB", accentHex: "FACC15", territoryPattern: .grid, trailEffect: .rainbow, unlockRule: .powerUpsUsed(120), perks: [], flagCode: nil),
        SkinDefinition(id: "revive1", name: "Lucky Pig", category: .classic, blueprint: .animalPig, primaryHex: "FB7185", secondaryHex: "E11D48", accentHex: "FDA4AF", territoryPattern: .dots, trailEffect: .bubbles, unlockRule: .revivesUsed(1), perks: [], flagCode: nil),
        SkinDefinition(id: "revive5", name: "Panda", category: .classic, blueprint: .animalPanda, primaryHex: "F8FAFC", secondaryHex: "0F172A", accentHex: "4ADE80", territoryPattern: .spots, trailEffect: .classic, unlockRule: .revivesUsed(5), perks: [], flagCode: nil),
        SkinDefinition(id: "revive15", name: "Phoenix", category: .classic, blueprint: .heroFlame, primaryHex: "FB923C", secondaryHex: "DC2626", accentHex: "FDE047", territoryPattern: .gradient, trailEffect: .flame, unlockRule: .revivesUsed(15), perks: [], flagCode: nil)
    ] + extraClassicSkins

    private static let extraClassicSkins: [SkinDefinition] = {
        let specs: [(String, String, SkinBlueprint, String, String, String, TerritoryPattern, TrailEffectStyle, SkinUnlockRule)] = [
            ("cat", "Kitty", .animalCat, "F59E0B", "B45309", "FFFFFF", .spots, .classic, .coins(1500)),
            ("penguin", "Penguin", .animalPenguin, "1E293B", "0F172A", "F97316", .snowflakes, .ice, .coins(1800)),
            ("duck", "Duckling", .animalDuck, "FDE047", "EAB308", "FB923C", .dots, .bubbles, .coins(1200)),
            ("burger", "Burger", .foodBurger, "D97706", "78350F", "22C55E", .stripes, .classic, .coins(2200)),
            ("pizza", "Pizza", .foodPizza, "FACC15", "DC2626", "F97316", .spots, .flame, .coins(2400)),
            ("sushi", "Sushi", .foodSushi, "FFFFFF", "0F172A", "FB7185", .stripes, .classic, .coins(2600)),
            ("taco", "Taco", .foodTaco, "FBBF24", "16A34A", "EF4444", .dots, .classic, .coins(2800)),
            ("avocado", "Avocado", .foodAvocado, "84CC16", "365314", "78350F", .gradient, .classic, .coins(3000)),
            ("cheese", "Cheese", .foodCheese, "FDE047", "CA8A04", "F59E0B", .dots, .classic, .coins(2000)),
            ("dice", "Dice", .objectDice, "F8FAFC", "CBD5E1", "0F172A", .dots, .classic, .coins(1600)),
            ("bomb", "Bomb", .objectBomb, "334155", "0F172A", "EF4444", .grid, .flame, .coins(3200)),
            ("cactus", "Cactus", .objectCactus, "16A34A", "14532D", "F472B6", .stripes, .classic, .coins(2500)),
            ("emerald_cube", "Emerald", .objectDiamond, "10B981", "047857", "A7F3D0", .grid, .sparkle, .coins(4750)),
            ("ruby_cube", "Ruby", .objectDiamond, "E11D48", "881337", "FDA4AF", .grid, .sparkle, .coins(4750)),
            ("sapphire_cube", "Sapphire", .objectDiamond, "2563EB", "1E3A8A", "93C5FD", .grid, .sparkle, .coins(4750)),
            ("mint_donut", "Mint Donut", .donut, "34D399", "D97706", "FFFFFF", .sprinkles, .bubbles, .coins(3500)),
            ("choco_donut", "Choco Donut", .donut, "78350F", "D97706", "F472B6", .sprinkles, .classic, .coins(3500)),
            ("cyber_car", "Cyber Car", .car, "38BDF8", "0369A1", "22D3EE", .grid, .neon, .coins(4200)),
            ("gold_car", "Taxi", .car, "FACC15", "CA8A04", "0F172A", .stripes, .classic, .coins(3800)),
            ("pink_cow", "Strawberry Cow", .cow, "FBCFE8", "DB2777", "F472B6", .spots, .bubbles, .coins(3900)),
            ("green_dino", "Rex", .dino, "22C55E", "15803D", "FACC15", .spots, .classic, .coins(3600)),
            ("red_dino", "Raptor", .dino, "EF4444", "991B1B", "FDBA74", .stripes, .flame, .coins(4100)),
            ("alien_ufo", "Mothership", .ufo, "A855F7", "581C87", "22D3EE", .stars, .neon, .gems(30)),
            ("ice_whale", "Beluga", .whale, "E0F2FE", "0284C7", "FFFFFF", .snowflakes, .ice, .coins(4000)),
            ("pink_whale", "Bubble Whale", .whale, "F472B6", "BE185D", "FFFFFF", .dots, .bubbles, .coins(4000)),
            ("golden_hammer", "Sky Hammer", .hammer, "FBBF24", "B45309", "38BDF8", .stars, .sparkle, .gems(45)),
            ("neon_ghost", "Neon Spirit", .ghost, "22D3EE", "0891B2", "F472B6", .grid, .neon, .coins(4500)),
            ("shadow_ghost", "Phantom", .ghost, "6366F1", "312E81", "C084FC", .stars, .sparkle, .coins(4500)),
            ("blue_unicorn", "Skycorn", .unicorn, "60A5FA", "1D4ED8", "FDE047", .stars, .rainbow, .coins(4750)),
            ("gold_rhino", "Armored Rhino", .rhino, "94A3B8", "334155", "FACC15", .grid, .classic, .coins(4800)),
            ("arctic_fox", "Arctic Fox", .animalFox, "F8FAFC", "94A3B8", "38BDF8", .snowflakes, .ice, .coins(4200)),
            ("white_tiger", "White Tiger", .animalLion, "F1F5F9", "334155", "38BDF8", .stripes, .ice, .gems(50)),
            ("lava_shark", "Lava Shark", .animalShark, "DC2626", "7F1D1D", "FACC15", .gradient, .flame, .gems(60)),
            ("cyber_bee", "Robo Bee", .animalBee, "22D3EE", "0F172A", "FDE047", .grid, .neon, .coins(5000)),
            ("toxic_frog", "Poison Frog", .animalFrog, "84CC16", "4D7C0F", "A855F7", .spots, .neon, .coins(4600)),
            ("king_penguin", "Emperor", .animalPenguin, "0F172A", "334155", "FACC15", .snowflakes, .ice, .coins(4900)),
            ("mars_planet", "Mars", .objectPlanet, "EA580C", "9A3412", "FDBA74", .dots, .flame, .coins(4400)),
            ("saturn", "Saturn", .objectPlanet, "FDE047", "B45309", "38BDF8", .stars, .sparkle, .gems(40)),
            ("astro_rocket", "Starship", .objectRocket, "E2E8F0", "475569", "3B82F6", .stars, .neon, .gems(55)),
            ("sun_eagle", "Golden Eagle", .eagle, "D97706", "78350F", "FEF08A", .gradient, .sparkle, .coins(5200)),
            ("royal_hippo", "Purple Hippo", .hippo, "A855F7", "6B21A8", "FDE047", .dots, .bubbles, .coins(4300)),
            ("candy_brain", "Mega Mind", .brain, "C084FC", "7E22CE", "F472B6", .brainWaves, .neon, .gems(40)),
            ("melon_gold", "Golden Melon", .watermelon, "FACC15", "16A34A", "0F172A", .dots, .sparkle, .coins(4750)),
            ("dark_wizard", "Archmage", .wizard, "1E1B4B", "0F172A", "38BDF8", .stars, .sparkle, .gems(65)),
            ("fire_wizard", "Pyromancer", .wizard, "B91C1C", "7F1D1D", "FACC15", .gradient, .flame, .gems(65)),
            ("cheese_burger", "Double Burger", .foodBurger, "F59E0B", "78350F", "EF4444", .stripes, .classic, .coins(4200)),
            ("pepperoni", "Supreme", .foodPizza, "EF4444", "FACC15", "22C55E", .spots, .classic, .coins(4200)),
            ("salmon_sushi", "Nigiri", .foodSushi, "FB923C", "FFFFFF", "1E293B", .stripes, .classic, .coins(4200)),
            ("party_cactus", "Fiesta Cactus", .objectCactus, "22C55E", "15803D", "FACC15", .sprinkles, .rainbow, .coins(4400))
        ]
        // Wait: ensure total classicSkins count is exactly 67 (28 above + 39 = 67!)
        return specs.prefix(39).map { item in
            SkinDefinition(
                id: item.0,
                name: item.1,
                category: .classic,
                blueprint: item.2,
                primaryHex: item.3,
                secondaryHex: item.4,
                accentHex: item.5,
                territoryPattern: item.6,
                trailEffect: item.7,
                unlockRule: item.8,
                perks: [],
                flagCode: nil
            )
        }
    }()

    // MARK: - Country Flags & Seasonal Events (20 — brings total to 104 skins!)
    static let flagAndEventSkins: [SkinDefinition] = [
        // Country Flags (14)
        SkinDefinition(id: "flag_us", name: "USA", category: .flagsAndEvents, blueprint: .flagCube, primaryHex: "2563EB", secondaryHex: "EF4444", accentHex: "FFFFFF", territoryPattern: .flag("US"), trailEffect: .sparkle, unlockRule: .coins(1500), perks: [], flagCode: "US"),
        SkinDefinition(id: "flag_vn", name: "Vietnam", category: .flagsAndEvents, blueprint: .flagCube, primaryHex: "DA251D", secondaryHex: "FFFF00", accentHex: "FACC15", territoryPattern: .flag("VN"), trailEffect: .sparkle, unlockRule: .coins(1500), perks: [], flagCode: "VN"),
        SkinDefinition(id: "flag_jp", name: "Japan", category: .flagsAndEvents, blueprint: .flagCube, primaryHex: "FFFFFF", secondaryHex: "BC002D", accentHex: "EF4444", territoryPattern: .flag("JP"), trailEffect: .classic, unlockRule: .coins(1500), perks: [], flagCode: "JP"),
        SkinDefinition(id: "flag_gb", name: "United Kingdom", category: .flagsAndEvents, blueprint: .flagCube, primaryHex: "1D4ED8", secondaryHex: "DC2626", accentHex: "FFFFFF", territoryPattern: .flag("GB"), trailEffect: .classic, unlockRule: .coins(1500), perks: [], flagCode: "GB"),
        SkinDefinition(id: "flag_fr", name: "France", category: .flagsAndEvents, blueprint: .flagCube, primaryHex: "2563EB", secondaryHex: "EF4444", accentHex: "FFFFFF", territoryPattern: .flag("FR"), trailEffect: .classic, unlockRule: .coins(1500), perks: [], flagCode: "FR"),
        SkinDefinition(id: "flag_de", name: "Germany", category: .flagsAndEvents, blueprint: .flagCube, primaryHex: "1E293B", secondaryHex: "EF4444", accentHex: "FACC15", territoryPattern: .flag("DE"), trailEffect: .classic, unlockRule: .coins(1500), perks: [], flagCode: "DE"),
        SkinDefinition(id: "flag_br", name: "Brazil", category: .flagsAndEvents, blueprint: .flagCube, primaryHex: "16A34A", secondaryHex: "FACC15", accentHex: "1D4ED8", territoryPattern: .flag("BR"), trailEffect: .rainbow, unlockRule: .coins(1500), perks: [], flagCode: "BR"),
        SkinDefinition(id: "flag_kr", name: "South Korea", category: .flagsAndEvents, blueprint: .flagCube, primaryHex: "F8FAFC", secondaryHex: "EF4444", accentHex: "2563EB", territoryPattern: .flag("KR"), trailEffect: .neon, unlockRule: .coins(1500), perks: [], flagCode: "KR"),
        SkinDefinition(id: "flag_ca", name: "Canada", category: .flagsAndEvents, blueprint: .flagCube, primaryHex: "EF4444", secondaryHex: "FFFFFF", accentHex: "DC2626", territoryPattern: .flag("CA"), trailEffect: .classic, unlockRule: .coins(1500), perks: [], flagCode: "CA"),
        SkinDefinition(id: "flag_au", name: "Australia", category: .flagsAndEvents, blueprint: .flagCube, primaryHex: "1E3A8A", secondaryHex: "EF4444", accentHex: "FFFFFF", territoryPattern: .flag("AU"), trailEffect: .sparkle, unlockRule: .coins(1500), perks: [], flagCode: "AU"),
        SkinDefinition(id: "flag_it", name: "Italy", category: .flagsAndEvents, blueprint: .flagCube, primaryHex: "16A34A", secondaryHex: "EF4444", accentHex: "FFFFFF", territoryPattern: .flag("IT"), trailEffect: .classic, unlockRule: .coins(1500), perks: [], flagCode: "IT"),
        SkinDefinition(id: "flag_es", name: "Spain", category: .flagsAndEvents, blueprint: .flagCube, primaryHex: "DC2626", secondaryHex: "FACC15", accentHex: "EF4444", territoryPattern: .flag("ES"), trailEffect: .flame, unlockRule: .coins(1500), perks: [], flagCode: "ES"),
        SkinDefinition(id: "flag_mx", name: "Mexico", category: .flagsAndEvents, blueprint: .flagCube, primaryHex: "15803D", secondaryHex: "DC2626", accentHex: "FFFFFF", territoryPattern: .flag("MX"), trailEffect: .classic, unlockRule: .coins(1500), perks: [], flagCode: "MX"),
        SkinDefinition(id: "flag_pa", name: "Panama", category: .flagsAndEvents, blueprint: .flagCube, primaryHex: "2563EB", secondaryHex: "EF4444", accentHex: "FFFFFF", territoryPattern: .flag("PA"), trailEffect: .sparkle, unlockRule: .coins(1500), perks: [], flagCode: "PA"),

        // Seasonal Event Exclusive Skins (6)
        SkinDefinition(id: "event_pumpkin", name: "Jack O' Lantern", category: .flagsAndEvents, blueprint: .seasonalPumpkin, primaryHex: "F97316", secondaryHex: "9A3412", accentHex: "FACC15", territoryPattern: .cobweb, trailEffect: .flame, unlockRule: .seasonalEvent("Halloween"), perks: [.vision], flagCode: nil),
        SkinDefinition(id: "event_vampire", name: "Count Cube", category: .flagsAndEvents, blueprint: .seasonalVampire, primaryHex: "4C1D95", secondaryHex: "991B1B", accentHex: "F8FAFC", territoryPattern: .cobweb, trailEffect: .sparkle, unlockRule: .seasonalEvent("Halloween"), perks: [.speed], flagCode: nil),
        SkinDefinition(id: "event_skeleton", name: "Spooky Skull", category: .flagsAndEvents, blueprint: .ghost, primaryHex: "F1F5F9", secondaryHex: "475569", accentHex: "A855F7", territoryPattern: .cobweb, trailEffect: .neon, unlockRule: .gems(25), perks: [], flagCode: nil),
        SkinDefinition(id: "event_santa", name: "Santa Claus", category: .flagsAndEvents, blueprint: .seasonalSanta, primaryHex: "DC2626", secondaryHex: "FFFFFF", accentHex: "FACC15", territoryPattern: .snowflakes, trailEffect: .ice, unlockRule: .seasonalEvent("Winter Frost"), perks: [.magnet], flagCode: nil),
        SkinDefinition(id: "event_snowman", name: "Frosty", category: .flagsAndEvents, blueprint: .seasonalSnowman, primaryHex: "F8FAFC", secondaryHex: "38BDF8", accentHex: "F97316", territoryPattern: .snowflakes, trailEffect: .ice, unlockRule: .seasonalEvent("Winter Frost"), perks: [.shield], flagCode: nil),
        SkinDefinition(id: "event_reindeer", name: "Rudolph", category: .flagsAndEvents, blueprint: .seasonalReindeer, primaryHex: "92400E", secondaryHex: "451A03", accentHex: "EF4444", territoryPattern: .snowflakes, trailEffect: .sparkle, unlockRule: .gems(25), perks: [], flagCode: nil)
    ]
}

// Helper static territory pattern alias for whale
private extension TerritoryPattern {
    static var bubblesPattern: TerritoryPattern { .dots }
}
