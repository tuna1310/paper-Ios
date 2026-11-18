import CoreGraphics
import Foundation

/// Smoothly follows the human player in world points and scales cleanly for iPhone/iPad portrait and landscape.
struct CameraController: Sendable {
    private(set) var position: CGPoint = .zero
    private(set) var scale: CGFloat = 1.0

    mutating func snap(to target: CGPoint, territoryPercent: Double, viewportSize: CGSize) {
        position = target
        scale = desiredScale(territoryPercent: territoryPercent, viewportSize: viewportSize)
    }

    mutating func update(
        target: CGPoint,
        territoryPercent: Double,
        viewportSize: CGSize,
        dt: Double
    ) {
        let stepFactor = min(1.0, GameConfig.cameraLerpFactor * CGFloat(dt * 60.0))
        position.x += (target.x - position.x) * stepFactor
        position.y += (target.y - position.y) * stepFactor

        let targetScale = desiredScale(territoryPercent: territoryPercent, viewportSize: viewportSize)
        scale += (targetScale - scale) * min(1.0, stepFactor * 0.5)
    }

    private func desiredScale(territoryPercent: Double, viewportSize: CGSize) -> CGFloat {
        let minDim = max(1.0, min(viewportSize.width, viewportSize.height))
        let desiredWorldWidth = GameConfig.defaultVisibleWidthCells * GameConfig.cellSizePoints
        let baseCameraScale = desiredWorldWidth / minDim
        let territoryFactor = 1.0 + CGFloat(min(max(territoryPercent, 0.0), 100.0) / 100.0) * 0.25
        return min(max(baseCameraScale * territoryFactor, GameConfig.minCameraZoomOut), GameConfig.maxCameraZoom * 1.4)
    }
}
