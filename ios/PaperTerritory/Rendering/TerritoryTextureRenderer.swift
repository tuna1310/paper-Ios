import CoreGraphics
import SpriteKit

/// Renders the entire 120x120 territory grid into a single reusable `SKMutableTexture`,
/// updating only dirty cell bounding rects to guarantee zero hot-loop allocations at 60/120 Hz.
final class TerritoryTextureRenderer {
    let gridWidth: Int
    let gridHeight: Int
    let pixelsPerCell: Int
    let textureWidth: Int
    let textureHeight: Int
    let texture: SKMutableTexture

    private var pixelBuffer: [UInt32]
    private var baseColors: [UInt32]
    private var bevelColors: [UInt32]

    private let neutralFloorColor: UInt32
    private let gridDotColor: UInt32

    init(
        gridWidth: Int = GameConfig.gridSize,
        gridHeight: Int = GameConfig.gridSize,
        pixelsPerCell: Int = GameConfig.territoryPixelsPerCell
    ) {
        self.gridWidth = gridWidth
        self.gridHeight = gridHeight
        self.pixelsPerCell = max(1, pixelsPerCell)
        self.textureWidth = gridWidth * self.pixelsPerCell
        self.textureHeight = gridHeight * self.pixelsPerCell

        self.neutralFloorColor = SkinPalette.rgbaLittleEndian(hex: GameConfig.arenaFloorHex)
        self.gridDotColor = SkinPalette.rgbaLittleEndian(hex: GameConfig.arenaGridDotHex)

        self.pixelBuffer = [UInt32](repeating: neutralFloorColor, count: textureWidth * textureHeight)
        self.baseColors = [UInt32](repeating: neutralFloorColor, count: 256)
        self.bevelColors = [UInt32](repeating: neutralFloorColor, count: 256)

        self.texture = SKMutableTexture(size: CGSize(width: textureWidth, height: textureHeight))
        self.texture.filteringMode = .nearest
    }

    func registerPalette(ownerId: UInt8, baseHex: UInt32, darkHex: UInt32) {
        let index = Int(ownerId)
        baseColors[index] = SkinPalette.rgbaLittleEndian(hex: baseHex)
        bevelColors[index] = SkinPalette.rgbaLittleEndian(hex: darkHex)
    }

    /// Updates only the modified cells within `dirtyRect` and pushes the updated pixels to `SKMutableTexture`.
    /// Returns `true` if a texture upload occurred.
    @discardableResult
    func syncIfDirty(grid: GridMap) -> Bool {
        let dirty = grid.consumeDirtyRect()
        guard !dirty.isEmpty else { return false }

        let minX = max(0, dirty.minX)
        let maxX = min(gridWidth - 1, dirty.maxX)
        let minY = max(0, dirty.minY)
        let maxY = min(gridHeight - 1, dirty.maxY)
        guard minX <= maxX, minY <= maxY else { return false }

        for gy in minY...maxY {
            for gx in minX...maxX {
                let owner = grid.owner(at: gx, gy: gy)
                paintCell(gx: gx, gy: gy, owner: owner, grid: grid)
            }
        }

        // Also refresh top-edge cells immediately below dirty rows so 2.5D bevel edges stay exact
        if maxY + 1 < gridHeight {
            let gyAbove = maxY + 1
            for gx in minX...maxX {
                let owner = grid.owner(at: gx, gy: gyAbove)
                paintCell(gx: gx, gy: gyAbove, owner: owner, grid: grid)
            }
        }

        let byteCount = pixelBuffer.count * MemoryLayout<UInt32>.stride
        texture.modifyPixelData { rawPointer, length in
            guard let rawPointer, length >= byteCount else { return }
            self.pixelBuffer.withUnsafeBytes { srcBytes in
                guard let srcBase = srcBytes.baseAddress else { return }
                rawPointer.copyMemory(from: srcBase, byteCount: byteCount)
            }
        }

        return true
    }

    private func paintCell(gx: Int, gy: Int, owner: UInt8, grid: GridMap) {
        let startPx = gx * pixelsPerCell
        let startPy = gy * pixelsPerCell

        if owner == GameConfig.neutralOwnerId {
            let isGridDot = (gx % 4 == 0) && (gy % 4 == 0)
            for pyOffset in 0..<pixelsPerCell {
                let rowStart = (startPy + pyOffset) * textureWidth + startPx
                for pxOffset in 0..<pixelsPerCell {
                    let color = (isGridDot && pxOffset == 0 && pyOffset == 0) ? gridDotColor : neutralFloorColor
                    pixelBuffer[rowStart + pxOffset] = color
                }
            }
            return
        }

        let ownerIndex = Int(owner)
        let fill = baseColors[ownerIndex]
        let southNeighbor = gy > 0 ? grid.owner(at: gx, gy: gy - 1) : GameConfig.neutralOwnerId
        let showBottomBevel = southNeighbor != owner
        let bevel = bevelColors[ownerIndex]

        for pyOffset in 0..<pixelsPerCell {
            let rowStart = (startPy + pyOffset) * textureWidth + startPx
            let rowColor = (showBottomBevel && pyOffset == 0) ? bevel : fill
            for pxOffset in 0..<pixelsPerCell {
                pixelBuffer[rowStart + pxOffset] = rowColor
            }
        }
    }
}
