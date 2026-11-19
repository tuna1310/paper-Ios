import Foundation

/// Daily mission objective categories rotated randomly each day.
enum MissionKind: String, Codable, CaseIterable, Sendable {
    case reachMatchPercent
    case accumulateTerritory
    case eliminateRivals
    case playMatches
    case surviveSeconds
    case finishTopThree
    case conquerCountry
}

/// Single daily mission entry with integer progress tracking.
struct DailyMission: Identifiable, Codable, Equatable, Sendable {
    let id: String
    let kind: MissionKind
    let title: String
    let target: Int
    var progress: Int

    var isCompleted: Bool {
        progress >= target
    }

    var fraction: Double {
        guard target > 0 else { return 1.0 }
        return min(1.0, Double(progress) / Double(target))
    }
}

/// Persisted state for today's 3 random missions and the Daily Mission Chest.
struct DailyMissionState: Codable, Equatable, Sendable {
    var dayKey: String
    var missions: [DailyMission]
    var chestClaimed: Bool

    var completedCount: Int {
        missions.filter(\.isCompleted).count
    }

    var allCompleted: Bool {
        !missions.isEmpty && missions.allSatisfy(\.isCompleted)
    }

    var canClaimChest: Bool {
        allCompleted && !chestClaimed
    }
}

/// Outcome of opening either the Daily Mission Chest or a Shop Hero Chest.
struct ChestReward: Equatable, Sendable {
    let sourceName: String
    let gold: Int
    let diamonds: Int
    let unlockedSkinId: String?
}

/// Deterministic daily mission generator (3 random missions/day) and 1%-skin Daily Chest roller.
enum DailyMissionSystem {
    static func dayKey(for date: Date) -> String {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0) ?? .current
        let comps = calendar.dateComponents([.year, .month, .day], from: date)
        let year = comps.year ?? 2026
        let month = comps.month ?? 1
        let day = comps.day ?? 1
        return String(format: "%04d-%02d-%02d", year, month, day)
    }

    static func generateDailyState(forDayKey key: String) -> DailyMissionState {
        let seed = stableSeed(for: key)
        var rng = SeededRandomGenerator(seed: seed)
        var pool = MissionKind.allCases
        pool.shuffle(using: &rng)
        let chosenKinds = Array(pool.prefix(GameConfig.dailyMissionCount))

        let missions = chosenKinds.enumerated().map { index, kind in
            buildMission(index: index, kind: kind, dayKey: key, rng: &rng)
        }
        return DailyMissionState(dayKey: key, missions: missions, chestClaimed: false)
    }

    static func applyMatch(
        _ outcome: MatchOutcomeSnapshot,
        conqueredCountry: Bool,
        to state: inout DailyMissionState
    ) {
        for idx in state.missions.indices {
            guard !state.missions[idx].isCompleted else { continue }
            var mission = state.missions[idx]
            let nextProgress = updatedProgress(
                for: mission,
                outcome: outcome,
                conqueredCountry: conqueredCountry
            )
            mission.progress = min(mission.target, nextProgress)
            state.missions[idx] = mission
        }
    }

    private static func updatedProgress(
        for mission: DailyMission,
        outcome: MatchOutcomeSnapshot,
        conqueredCountry: Bool
    ) -> Int {
        let matchPercent = Int(max(outcome.peakPercentage, outcome.finalPercentage).rounded(.down))
        let survived = Int(outcome.elapsedSeconds.rounded(.down))

        switch mission.kind {
        case .reachMatchPercent:
            return max(mission.progress, matchPercent)
        case .accumulateTerritory:
            return mission.progress + max(1, matchPercent)
        case .eliminateRivals:
            return mission.progress + outcome.kills
        case .playMatches:
            return mission.progress + 1
        case .surviveSeconds:
            return max(mission.progress, survived)
        case .finishTopThree:
            return mission.progress + (outcome.finalRank <= 3 ? 1 : 0)
        case .conquerCountry:
            return mission.progress + (conqueredCountry ? 1 : 0)
        }
    }

    /// Daily Mission Chest: 1% chance to drop an unowned skin; 99% random Diamonds + Gold <= 1,000 each.
    static func rollDailyChest(
        ownedSkinIds: Set<String>,
        rng: inout SeededRandomGenerator
    ) -> ChestReward {
        let skinRoll = Double.random(in: 0..<1, using: &rng)
        let unownedSkins = SkinCatalog.all.filter { !ownedSkinIds.contains($0.id) }

        if skinRoll < GameConfig.dailyChestSkinChance, !unownedSkins.isEmpty {
            let index = Int.random(in: 0..<unownedSkins.count, using: &rng)
            return ChestReward(
                sourceName: "Daily Mission Chest",
                gold: 0,
                diamonds: 0,
                unlockedSkinId: unownedSkins[index].id
            )
        }

        let rawGold = Int.random(in: GameConfig.dailyChestMinGold...GameConfig.dailyChestMaxGold, using: &rng)
        let rawDiamonds = Int.random(
            in: GameConfig.dailyChestMinDiamonds...GameConfig.dailyChestMaxDiamonds,
            using: &rng
        )
        let gold = min(rawGold, GameConfig.dailyChestMaxGold)
        let diamonds = min(rawDiamonds, GameConfig.dailyChestMaxDiamonds)

        return ChestReward(
            sourceName: "Daily Mission Chest",
            gold: gold,
            diamonds: diamonds,
            unlockedSkinId: nil
        )
    }

    private static func buildMission(
        index: Int,
        kind: MissionKind,
        dayKey: String,
        rng: inout SeededRandomGenerator
    ) -> DailyMission {
        let target: Int
        let title: String
        switch kind {
        case .reachMatchPercent:
            target = [15, 25, 35][Int.random(in: 0..<3, using: &rng)]
            title = "Reach \(target)% territory in one match"
        case .accumulateTerritory:
            target = [40, 60, 80][Int.random(in: 0..<3, using: &rng)]
            title = "Capture \(target)% total territory today"
        case .eliminateRivals:
            target = [3, 5, 8][Int.random(in: 0..<3, using: &rng)]
            title = "Eliminate \(target) rivals"
        case .playMatches:
            target = [2, 3, 4][Int.random(in: 0..<3, using: &rng)]
            title = "Play \(target) matches"
        case .surviveSeconds:
            target = [30, 45, 60][Int.random(in: 0..<3, using: &rng)]
            title = "Survive \(target)s in a single match"
        case .finishTopThree:
            target = [1, 2][Int.random(in: 0..<2, using: &rng)]
            title = target == 1 ? "Finish in Top 3 once" : "Finish in Top 3 (\(target) times)"
        case .conquerCountry:
            target = 1
            title = "Conquer 1 country in World Mode"
        }
        return DailyMission(
            id: "\(dayKey)-\(index)-\(kind.rawValue)",
            kind: kind,
            title: title,
            target: target,
            progress: 0
        )
    }

    private static func stableSeed(for text: String) -> UInt64 {
        var hash: UInt64 = 0xCBF2_9CE4_8422_2325
        for byte in text.utf8 {
            hash ^= UInt64(byte)
            hash = hash &* 0x0000_0100_0000_01B3
        }
        return hash == 0 ? 0x5041_5045_5233 : hash
    }
}
