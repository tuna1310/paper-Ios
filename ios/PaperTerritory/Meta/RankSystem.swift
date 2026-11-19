import Foundation

/// Metadata entry backing each tier of the 10-tier competitive rank ladder.
private struct RankTierSpec: Sendable {
    let name: String
    let minPoints: Int
    let primaryHex: UInt32
    let secondaryHex: UInt32
    let symbolName: String
}

/// Ten-tier competitive rank ladder mapped 1:1 from Bronze (tier 0) through Legend (tier 9).
enum RankTier: Int, CaseIterable, Codable, Identifiable, Sendable {
    case bronze = 0
    case silver = 1
    case gold = 2
    case platinum = 3
    case diamond = 4
    case elite = 5
    case ace = 6
    case champion = 7
    case warlord = 8
    case legend = 9

    private static func spec(
        _ name: String,
        min: Int,
        primary: UInt32,
        secondary: UInt32,
        icon: String
    ) -> RankTierSpec {
        RankTierSpec(
            name: name,
            minPoints: min,
            primaryHex: primary,
            secondaryHex: secondary,
            symbolName: icon
        )
    }

    private static let specs: [RankTierSpec] = [
        spec("Bronze", min: 0, primary: 0xCD_7F_32, secondary: 0x7C_2D_12, icon: "shield.fill"),
        spec("Silver", min: 150, primary: 0x94_A3_B8, secondary: 0x47_55_69, icon: "shield.fill"),
        spec("Gold", min: 400, primary: 0xF5_9E_0B, secondary: 0xB4_53_09, icon: "shield.fill"),
        spec("Platinum", min: 750, primary: 0x38_BD_F8, secondary: 0x03_69_A1, icon: "diamond.fill"),
        spec("Diamond", min: 1_200, primary: 0x22_D3_EE, secondary: 0x0E_74_90, icon: "diamond.fill"),
        spec("Elite", min: 1_800, primary: 0x10_B9_81, secondary: 0x04_78_57, icon: "star.circle.fill"),
        spec("Master", min: 2_600, primary: 0x8B_5C_F6, secondary: 0x5B_21_B6, icon: "star.circle.fill"),
        spec("Grandmaster", min: 3_600, primary: 0xEC_48_99, secondary: 0x9D_17_4D, icon: "flame.fill"),
        spec("Warlord", min: 4_800, primary: 0xEF_44_44, secondary: 0x99_1B_1B, icon: "flame.fill"),
        spec("Legend", min: 6_500, primary: 0xFA_CC_15, secondary: 0xB4_53_09, icon: "crown.fill")
    ]

    var id: Int {
        rawValue
    }

    var displayName: String {
        Self.specs[rawValue].name
    }

    var minPoints: Int {
        Self.specs[rawValue].minPoints
    }

    var rewardMultiplier: Double {
        1.0 + Double(rawValue) * 0.05
    }

    var primaryHex: UInt32 {
        Self.specs[rawValue].primaryHex
    }

    var secondaryHex: UInt32 {
        Self.specs[rawValue].secondaryHex
    }

    var symbolName: String {
        Self.specs[rawValue].symbolName
    }

    var nextTier: RankTier? {
        RankTier(rawValue: rawValue + 1)
    }

    static func tier(for points: Int) -> RankTier {
        var resolved: RankTier = .bronze
        for candidate in RankTier.allCases where points >= candidate.minPoints {
            resolved = candidate
        }
        return resolved
    }

    static func progressToNext(points: Int) -> Double {
        let current = tier(for: points)
        guard let next = current.nextTier else {
            return 1.0
        }
        let span = max(1, next.minPoints - current.minPoints)
        let clamped = min(max(0, points - current.minPoints), span)
        return Double(clamped) / Double(span)
    }
}

/// Summary of Gold, Diamonds, Rank Points, and World milestones earned from a completed match.
struct MatchRewardBreakdown: Equatable, Sendable {
    let goldEarned: Int
    let diamondsEarned: Int
    let rankPointsDelta: Int
    let previousTier: RankTier
    let newTier: RankTier
    let countryConqueredName: String?
    let continentUnlockedName: String?

    var didRankUp: Bool {
        newTier.rawValue > previousTier.rawValue
    }
}

/// Pure deterministic match economy & rank points calculator scaling proportionally with territory %.
enum EconomyCalculator {
    static func calculateRewards(
        outcome: MatchOutcomeSnapshot,
        currentRankPoints: Int,
        countryBonusGold: Int = 0,
        countryBonusDiamonds: Int = 0
    ) -> MatchRewardBreakdown {
        let previousTier = RankTier.tier(for: currentRankPoints)
        let effectivePercent = min(100.0, max(0.0, max(outcome.peakPercentage, outcome.finalPercentage)))
        let multiplier = previousTier.rewardMultiplier

        let baseGold = Int((effectivePercent * GameConfig.goldPerPercent).rounded())
            + outcome.kills * GameConfig.goldPerKill
            + (outcome.isVictory ? GameConfig.victoryBonusGold : 0)
        let goldEarned = max(5, Int((Double(baseGold) * multiplier).rounded())) + countryBonusGold

        let baseDiamonds = Int((effectivePercent * GameConfig.diamondsPerPercent).rounded())
            + (outcome.kills / 2)
            + (outcome.isVictory ? GameConfig.victoryBonusDiamonds : 0)
        let diamondsEarned = max(1, Int((Double(baseDiamonds) * multiplier).rounded())) + countryBonusDiamonds

        let placementBonus = outcome.finalRank <= 3 ? (4 - outcome.finalRank) * 8 : 0
        let victoryRp = outcome.isVictory ? 60 : 0
        let rawRp = Int((effectivePercent * 1.2).rounded()) + outcome.kills * 8 + placementBonus + victoryRp
        let rankPointsDelta = max(5, rawRp)
        let newTier = RankTier.tier(for: currentRankPoints + rankPointsDelta)

        return MatchRewardBreakdown(
            goldEarned: goldEarned,
            diamondsEarned: diamondsEarned,
            rankPointsDelta: rankPointsDelta,
            previousTier: previousTier,
            newTier: newTier,
            countryConqueredName: nil,
            continentUnlockedName: nil
        )
    }
}
