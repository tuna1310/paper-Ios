import Foundation

/// Centralized localization lookup backed by `Localizable.xcstrings` (English only).
enum L10n {
    static var appTitle: String {
        String(localized: "app_title", bundle: .main)
    }

    static var demoControlsHint: String {
        String(localized: "demo_controls_hint", bundle: .main)
    }

    static var leaderboardTitle: String {
        String(localized: "hud_leaderboard_title", bundle: .main)
    }

    static var playerDefaultName: String {
        String(localized: "hud_player_default_name", bundle: .main)
    }

    static var restartButton: String {
        String(localized: "hud_restart_button", bundle: .main)
    }

    static var gameOverTitle: String {
        String(localized: "match_game_over_title", bundle: .main)
    }

    static var victoryTitle: String {
        String(localized: "match_victory_title", bundle: .main)
    }

    static var playAgainButton: String {
        String(localized: "match_play_again_button", bundle: .main)
    }

    static var endVictorySubtitle: String {
        String(localized: "match_end_victory", bundle: .main)
    }

    static var endSelfTrail: String {
        String(localized: "match_end_self_trail", bundle: .main)
    }

    static var endBoundary: String {
        String(localized: "match_end_boundary", bundle: .main)
    }

    static var endHeadOnMutual: String {
        String(localized: "match_end_head_on_mutual", bundle: .main)
    }

    static var endStarvation: String {
        String(localized: "match_end_starvation", bundle: .main)
    }

    static func percentageText(_ value: Double) -> String {
        let format = String(localized: "hud_percentage_format", bundle: .main)
        return String(format: format, locale: Locale(identifier: "en_US_POSIX"), value)
    }

    static func killsText(_ kills: Int) -> String {
        let format = String(localized: "hud_kills_format", bundle: .main)
        return String(format: format, locale: Locale(identifier: "en_US_POSIX"), kills)
    }

    static func endEnemyTrail(killerName: String) -> String {
        let format = String(localized: "match_end_enemy_trail_format", bundle: .main)
        return String(format: format, locale: Locale(identifier: "en_US_POSIX"), killerName)
    }

    static func endHeadOnLoss(killerName: String) -> String {
        let format = String(localized: "match_end_head_on_loss_format", bundle: .main)
        return String(format: format, locale: Locale(identifier: "en_US_POSIX"), killerName)
    }
}
