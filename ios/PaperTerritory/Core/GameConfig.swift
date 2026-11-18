import CoreGraphics
import Foundation

/// Central tuning constants for Paper Territory.
/// All simulation, rendering, input, and AI parameters live here with zero magic numbers in logic.
enum GameConfig {
    // MARK: - Grid & Arena
    static let gridSize: Int = 120
    static let cellSizePoints: CGFloat = 22.0
    static let starterRadiusCells: Int = 2 // 5x5 cells ((2*2+1)^2 = 25)
    static let neutralOwnerId: UInt8 = 0
    static let humanPlayerId: UInt8 = 1

    // MARK: - Movement & Turn Buffer
    static let turnQueueCapacity: Int = 2
    static let moveSpeedCellsPerSecond: Double = 9.5
    static let swipeThresholdPoints: CGFloat = 14.0

    // MARK: - Fixed Timestep Simulation
    static let fixedTimestepSeconds: Double = 1.0 / 60.0
    static let maxSimStepsPerFrame: Int = 3
    static let maxFrameDeltaSeconds: Double = 0.05

    // MARK: - Rendering & Pooling
    static let territoryPixelsPerCell: Int = 2
    static let pooledTrailNodesPerEntity: Int = 600
    static let cameraLerpFactor: CGFloat = 0.16
    static let defaultVisibleWidthCells: CGFloat = 22.0
    static let minCameraZoomOut: CGFloat = 0.72
    static let maxCameraZoom: CGFloat = 1.15

    // MARK: - Arena Visual Palette (RGBA Hex)
    static let arenaFloorHex: UInt32 = 0xEB_F7_F0
    static let arenaGridDotHex: UInt32 = 0xC6_E6_DF
    static let arenaBorderHex: UInt32 = 0x80_CB_C4
    static let arenaOuterBgHex: UInt32 = 0xCF_D8_DC
}
