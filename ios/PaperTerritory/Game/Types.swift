import Foundation

/// Four cardinal movement directions in grid space (+Y is up, +X is right).
enum Direction: UInt8, CaseIterable, Sendable {
    case up = 0
    case right = 1
    case down = 2
    case left = 3

    var dx: Int {
        switch self {
        case .up, .down: return 0
        case .right: return 1
        case .left: return -1
        }
    }

    var dy: Int {
        switch self {
        case .right, .left: return 0
        case .up: return 1
        case .down: return -1
        }
    }

    var opposite: Direction {
        switch self {
        case .up: return .down
        case .right: return .left
        case .down: return .up
        case .left: return .right
        }
    }

    var rotatedClockwise: Direction {
        switch self {
        case .up: return .right
        case .right: return .down
        case .down: return .left
        case .left: return .up
        }
    }

    var rotatedCounterClockwise: Direction {
        switch self {
        case .up: return .left
        case .left: return .down
        case .down: return .right
        case .right: return .up
        }
    }

    var angleRadians: Double {
        switch self {
        case .right: return 0
        case .up: return .pi / 2.0
        case .left: return .pi
        case .down: return -.pi / 2.0
        }
    }

    func isOpposite(to other: Direction) -> Bool {
        opposite == other
    }
}

/// Integer grid cell coordinate.
struct GridPoint: Hashable, Sendable {
    let gx: Int
    let gy: Int
}

/// Inclusive axis-aligned bounding rectangle in grid cell coordinates.
struct GridRect: Equatable, Sendable {
    var minX: Int
    var minY: Int
    var maxX: Int
    var maxY: Int

    static let empty = GridRect(minX: Int.max, minY: Int.max, maxX: Int.min, maxY: Int.min)

    var isEmpty: Bool {
        minX > maxX || minY > maxY
    }

    mutating func include(gx: Int, gy: Int) {
        if gx < minX {
            minX = gx
        }
        if gx > maxX {
            maxX = gx
        }
        if gy < minY {
            minY = gy
        }
        if gy > maxY {
            maxY = gy
        }
    }

    func union(_ other: GridRect) -> GridRect {
        if isEmpty {
            return other
        }
        if other.isEmpty {
            return self
        }
        return GridRect(
            minX: min(minX, other.minX),
            minY: min(minY, other.minY),
            maxX: max(maxX, other.maxX),
            maxY: max(maxY, other.maxY)
        )
    }

    func expanded(by margin: Int, minBound: Int, maxBoundX: Int, maxBoundY: Int) -> GridRect {
        guard !isEmpty else { return .empty }
        return GridRect(
            minX: max(minBound, minX - margin),
            minY: max(minBound, minY - margin),
            maxX: min(maxBoundX, maxX + margin),
            maxY: min(maxBoundY, maxY + margin)
        )
    }
}

/// Behavior when an entity reaches the outer arena boundary.
enum EdgeRule: String, Codable, CaseIterable, Sendable {
    case die
    case block
}

/// Behavior when two entity heads collide on the same cell or swap positions.
enum HeadOnRule: String, Codable, CaseIterable, Sendable {
    case largerTerritoryWins
    case bothDie
}

/// Bot intelligence and aggression tier.
enum BotDifficulty: String, Codable, CaseIterable, Sendable {
    case easy
    case normal
    case hard
}

/// Specific cause of an entity's elimination.
enum DeathReason: Equatable, Sendable {
    case selfTrail
    case enemyTrail(killerName: String)
    case boundary
    case headOnLoss(killerName: String)
    case headOnMutual
    case starvation

    var localizedDescription: String {
        switch self {
        case .selfTrail:
            return L10n.endSelfTrail
        case let .enemyTrail(killerName):
            return L10n.endEnemyTrail(killerName: killerName)
        case .boundary:
            return L10n.endBoundary
        case let .headOnLoss(killerName):
            return L10n.endHeadOnLoss(killerName: killerName)
        case .headOnMutual:
            return L10n.endHeadOnMutual
        case .starvation:
            return L10n.endStarvation
        }
    }
}

/// Five canonical match lifecycle states.
enum GameState: Equatable, Sendable {
    case ready
    case playing
    case paused
    case victory
    case gameOver(DeathReason)
}

/// Collision event emitted during a simulation tick.
struct CollisionEvent: Equatable, Sendable {
    let victimId: UInt8
    let killerId: UInt8?
    let reason: DeathReason
}

/// Result summary from closing a trail loop and running exterior flood fill.
struct CaptureResult: Equatable, Sendable {
    let ownerId: UInt8
    let capturedCellCount: Int
    let capturedBounds: GridRect

    static func empty(ownerId: UInt8) -> CaptureResult {
        CaptureResult(ownerId: ownerId, capturedCellCount: 0, capturedBounds: .empty)
    }
}

/// Optional match customization for skin palette and World Conquest stage targets.
struct MatchModeConfig: Equatable, Sendable {
    var playerPalette: EntityPalette
    var victoryPercentage: Double
    var countryStageId: String?

    static let classic = MatchModeConfig(
        playerPalette: SkinPalette.playerDefault,
        victoryPercentage: GameConfig.victoryPercentage,
        countryStageId: nil
    )
}

/// Immutable match performance summary emitted when a match ends.
struct MatchOutcomeSnapshot: Equatable, Sendable {
    let peakPercentage: Double
    let finalPercentage: Double
    let kills: Int
    let elapsedSeconds: Double
    let isVictory: Bool
    let finalRank: Int
    let countryStageId: String?
}
