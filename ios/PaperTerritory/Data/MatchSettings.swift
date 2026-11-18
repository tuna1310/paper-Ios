import Foundation

/// Gameplay rules & match configuration passed from Settings into `GameEngine`.
struct MatchSettings: Codable, Equatable, Sendable {
    var botDifficulty: BotDifficulty
    var edgeRule: EdgeRule
    var headOnRule: HeadOnRule
    var botCount: Int

    static let `default` = MatchSettings(
        botDifficulty: .normal,
        edgeRule: .die,
        headOnRule: .largerTerritoryWins,
        botCount: GameConfig.defaultBotCount
    )

    var clampedBotCount: Int {
        min(max(botCount, GameConfig.minBotCount), GameConfig.maxBotCount)
    }
}
