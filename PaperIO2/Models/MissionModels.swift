import Foundation

/// Metric tracked by daily or lifetime missions.
enum MissionMetric: String, Codable {
    case completeCountries
    case outsideTerritorySeconds
    case insideEnemyTerritorySeconds
    case defeatEnemies
    case reachPercentage
    case collectOrbs
    case winMatches
    case playTeamMatches
    case openChests
    case reviveTimes
}

/// Active daily or lifetime mission card item.
struct MissionItem: Identifiable, Codable, Hashable {
    let id: String
    let title: String
    let metric: MissionMetric
    let target: Int
    var progress: Int
    let rewardCoins: Int
    let rewardGems: Int
    var isClaimed: Bool
    let isLifetime: Bool

    var isCompleted: Bool {
        progress >= target
    }

    var progressFraction: Double {
        guard target > 0 else { return 0 }
        return min(1.0, Double(progress) / Double(target))
    }
}

/// Pool of daily and lifetime missions matching Paper.io 2 gameplay.
enum MissionTemplates {
    static let dailyPool: [(String, MissionMetric, Int, Int)] = [
        ("Complete 3 more countries", .completeCountries, 3, 550),
        ("Stay outside your territory for 6s straight", .outsideTerritorySeconds, 6, 300),
        ("Stay inside enemy territory for 3s straight", .insideEnemyTerritorySeconds, 3, 450),
        ("Defeat 8 rivals in matches", .defeatEnemies, 8, 400),
        ("Collect 5 power-up orbs", .collectOrbs, 5, 350),
        ("Reach 40% territory in a match", .reachPercentage, 40, 500),
        ("Play 2 Team Battle matches", .playTeamMatches, 2, 420),
        ("Win 1 Classic Arena match", .winMatches, 1, 600)
    ]

    static func defaultDailyMissions() -> [MissionItem] {
        [
            MissionItem(id: "daily_0", title: "Complete 3 more countries", metric: .completeCountries, target: 3, progress: 0, rewardCoins: 550, rewardGems: 0, isClaimed: false, isLifetime: false),
            MissionItem(id: "daily_1", title: "Stay outside your territory for 6s straight", metric: .outsideTerritorySeconds, target: 6, progress: 0, rewardCoins: 300, rewardGems: 0, isClaimed: false, isLifetime: false),
            MissionItem(id: "daily_2", title: "Stay inside enemy territory for 3s straight", metric: .insideEnemyTerritorySeconds, target: 3, progress: 0, rewardCoins: 450, rewardGems: 0, isClaimed: false, isLifetime: false)
        ]
    }

    static func defaultLifetimeMissions() -> [MissionItem] {
        [
            MissionItem(id: "life_kills_100", title: "Defeat 100 rivals", metric: .defeatEnemies, target: 100, progress: 77, rewardCoins: 0, rewardGems: 15, isClaimed: false, isLifetime: true),
            MissionItem(id: "life_kills_300", title: "Defeat 300 rivals", metric: .defeatEnemies, target: 300, progress: 77, rewardCoins: 0, rewardGems: 40, isClaimed: false, isLifetime: true),
            MissionItem(id: "life_chests_24", title: "Open 24 Hero Chests", metric: .openChests, target: 24, progress: 13, rewardCoins: 0, rewardGems: 25, isClaimed: false, isLifetime: true),
            MissionItem(id: "life_orbs_50", title: "Use 50 Power Orbs", metric: .collectOrbs, target: 50, progress: 25, rewardCoins: 1500, rewardGems: 10, isClaimed: false, isLifetime: true),
            MissionItem(id: "life_countries_10", title: "Conquer 10 countries", metric: .completeCountries, target: 10, progress: 3, rewardCoins: 0, rewardGems: 35, isClaimed: false, isLifetime: true),
            MissionItem(id: "life_revive_5", title: "Revive 5 times using Gems", metric: .revivesUsed, target: 5, progress: 0, rewardCoins: 1000, rewardGems: 20, isClaimed: false, isLifetime: true)
        ]
    }
}
