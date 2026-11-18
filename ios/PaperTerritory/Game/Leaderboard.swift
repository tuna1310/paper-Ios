import Foundation

/// Single row in the live arena ranking.
struct LeaderboardEntry: Identifiable, Equatable, Sendable {
    let id: UInt8
    let rank: Int
    let name: String
    let colorHex: UInt32
    let percentage: Double
    let kills: Int
    let isPlayer: Bool
    let isAlive: Bool
}

/// Top 5 leaderboard snapshot plus optional pinned human-player row if ranked outside Top 5.
struct LeaderboardSnapshot: Equatable, Sendable {
    let topFive: [LeaderboardEntry]
    let playerOutsideTopFive: LeaderboardEntry?

    static let empty = LeaderboardSnapshot(topFive: [], playerOutsideTopFive: nil)
}

/// Computes deterministic arena rankings sorted by territory percentage descending, then kills descending.
enum Leaderboard {
    static func build(
        entities: [Entity],
        grid: GridMap,
        topCount: Int = GameConfig.leaderboardTopCount
    ) -> LeaderboardSnapshot {
        var ranked = entities.map { entity -> (Entity, Double) in
            let pct = (grid.percentage(for: entity.id) * 100.0).rounded() / 100.0
            return (entity, pct)
        }

        ranked.sort { lhs, rhs in
            if lhs.1 != rhs.1 { return lhs.1 > rhs.1 }
            if lhs.0.kills != rhs.0.kills { return lhs.0.kills > rhs.0.kills }
            return lhs.0.id < rhs.0.id
        }

        var topEntries: [LeaderboardEntry] = []
        topEntries.reserveCapacity(topCount)
        var playerFallback: LeaderboardEntry?

        for (index, item) in ranked.enumerated() {
            let entity = item.0
            let entry = LeaderboardEntry(
                id: entity.id,
                rank: index + 1,
                name: entity.name,
                colorHex: entity.colorHex,
                percentage: item.1,
                kills: entity.kills,
                isPlayer: !entity.isBot,
                isAlive: entity.isAlive
            )
            if index < topCount {
                topEntries.append(entry)
            } else if entry.isPlayer {
                playerFallback = entry
            }
        }

        return LeaderboardSnapshot(topFive: topEntries, playerOutsideTopFive: playerFallback)
    }
}
