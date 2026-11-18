import SpriteKit
import UIKit

/// Pooled SpriteKit nodes representing an entity's block body, eyes, shadow, nametag, and trail segments.
private final class EntityVisualPool {
    let rootNode = SKNode()
    let shadowNode: SKSpriteNode
    let bodyNode: SKSpriteNode
    let leftEyeNode: SKSpriteNode
    let rightEyeNode: SKSpriteNode
    let crownNode: SKSpriteNode
    let nameLabel: SKLabelNode
    var trailPool: [SKSpriteNode] = []

    init(name: String, color: UIColor, trailColor: UIColor, size: CGFloat) {
        let shadowSize = CGSize(width: size * 0.96, height: size * 0.96)
        shadowNode = SKSpriteNode(color: UIColor.black.withAlphaComponent(0.18), size: shadowSize)
        shadowNode.position = CGPoint(x: 2.0, y: -3.5)
        shadowNode.zPosition = 9

        bodyNode = SKSpriteNode(color: color, size: CGSize(width: size, height: size))
        bodyNode.zPosition = 10

        let eyeSize = CGSize(width: size * 0.18, height: size * 0.24)
        leftEyeNode = SKSpriteNode(color: .white, size: eyeSize)
        rightEyeNode = SKSpriteNode(color: .white, size: eyeSize)

        let pupilSize = CGSize(width: size * 0.09, height: size * 0.12)
        let pupilColor = UIColor(red: 0.05, green: 0.10, blue: 0.35, alpha: 1.0)
        let leftPupil = SKSpriteNode(color: pupilColor, size: pupilSize)
        let rightPupil = SKSpriteNode(color: pupilColor, size: pupilSize)
        leftEyeNode.addChild(leftPupil)
        rightEyeNode.addChild(rightPupil)

        leftEyeNode.position = CGPoint(x: size * 0.18, y: size * 0.18)
        rightEyeNode.position = CGPoint(x: size * 0.18, y: -size * 0.18)
        bodyNode.addChild(leftEyeNode)
        bodyNode.addChild(rightEyeNode)

        crownNode = SKSpriteNode(
            color: UIColor(red: 1.0, green: 0.84, blue: 0.0, alpha: 1.0),
            size: CGSize(width: size * 0.55, height: size * 0.28)
        )
        crownNode.position = CGPoint(x: 0, y: size * 0.72)
        crownNode.zPosition = 11
        crownNode.isHidden = true

        nameLabel = SKLabelNode(text: name)
        nameLabel.fontName = "HelveticaNeue-Bold"
        nameLabel.fontSize = 11
        nameLabel.fontColor = UIColor(red: 0.04, green: 0.10, blue: 0.35, alpha: 0.9)
        nameLabel.position = CGPoint(x: 0, y: -size * 1.15)
        nameLabel.zPosition = 12

        rootNode.addChild(shadowNode)
        rootNode.addChild(bodyNode)
        rootNode.addChild(crownNode)
        rootNode.addChild(nameLabel)

        trailPool.reserveCapacity(GameConfig.pooledTrailNodesPerEntity)
        let cellPts = GameConfig.cellSizePoints
        let segSize = CGSize(width: cellPts * 0.86, height: cellPts * 0.86)
        for _ in 0..<GameConfig.pooledTrailNodesPerEntity {
            let seg = SKSpriteNode(color: trailColor, size: segSize)
            seg.zPosition = 5
            seg.isHidden = true
            trailPool.append(seg)
        }
    }

    func update(entity: Entity, isLeader: Bool, cellSize: CGFloat) {
        rootNode.isHidden = !entity.isAlive
        if !entity.isAlive {
            hideAllTrailSegments()
            return
        }

        let worldPos = CGPoint(x: CGFloat(entity.posX) * cellSize, y: CGFloat(entity.posY) * cellSize)
        rootNode.position = worldPos
        bodyNode.zRotation = CGFloat(entity.direction.angleRadians)
        crownNode.isHidden = !isLeader

        let trailCount = entity.trail.points.count
        let poolCount = trailPool.count
        let visibleCount = min(trailCount, poolCount)

        for idx in 0..<visibleCount {
            let pt = entity.trail.points[idx]
            let node = trailPool[idx]
            node.isHidden = false
            node.position = CGPoint(
                x: (CGFloat(pt.gx) + 0.5) * cellSize,
                y: (CGFloat(pt.gy) + 0.5) * cellSize
            )
        }
        if visibleCount < poolCount {
            for idx in visibleCount..<poolCount {
                let node = trailPool[idx]
                if node.isHidden {
                    break
                }
                node.isHidden = true
            }
        }
    }

    private func hideAllTrailSegments() {
        for seg in trailPool {
            if seg.isHidden {
                break
            }
            seg.isHidden = true
        }
    }
}

/// Snapshot of match state pushed sparingly (only on value changes) to SwiftUI HUD.
struct ArenaHUDState: Equatable, Sendable {
    var percentage: Double = 0
    var peakPercentage: Double = 0
    var kills: Int = 0
    var gameState: GameState = .playing
    var leaderboard: LeaderboardSnapshot = .empty

    var isPlaying: Bool {
        gameState == .playing
    }
}

/// High-performance SpriteKit scene hosting the single fixed-timestep loop,
/// dirty-rect territory texture, pooled entities/trails, and direct touch steering.
final class ArenaScene: SKScene {
    let engine: GameEngine
    private let territoryRenderer: TerritoryTextureRenderer
    private let territorySprite: SKSpriteNode
    private let worldContainer = SKNode()
    private let cameraNode = SKCameraNode()
    private var cameraController = CameraController()
    private let frameMetrics = FrameMetrics()

    private var entityPools: [UInt8: EntityVisualPool] = [:]
    private var accumulator: Double = 0
    private var lastUpdateTimestamp: TimeInterval = 0
    private var hudPublishTimer: Double = 0
    private var touchStartPoint: CGPoint?
    private var currentLeaderId: UInt8?

    var onHUDUpdate: ((ArenaHUDState) -> Void)?
    private var lastPublishedHUD = ArenaHUDState()

    init(engine: GameEngine) {
        self.engine = engine
        self.territoryRenderer = TerritoryTextureRenderer(
            gridWidth: engine.grid.width,
            gridHeight: engine.grid.height,
            pixelsPerCell: GameConfig.territoryPixelsPerCell
        )
        let worldWidth = CGFloat(engine.grid.width) * GameConfig.cellSizePoints
        let worldHeight = CGFloat(engine.grid.height) * GameConfig.cellSizePoints
        self.territorySprite = SKSpriteNode(
            texture: territoryRenderer.texture,
            size: CGSize(width: worldWidth, height: worldHeight)
        )
        super.init(size: CGSize(width: 390, height: 844))
        self.scaleMode = .resizeFill
        self.backgroundColor = UIColor(hex: GameConfig.arenaOuterBgHex)
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        nil
    }

    override func didMove(to view: SKView) {
        super.didMove(to: view)
        #if DEBUG
            view.showsFPS = true
            view.showsNodeCount = true
        #endif
        view.ignoresSiblingOrder = true

        setupWorldHierarchy()
        rebuildVisualPools()
        syncAllEntitiesAndCamera(snapCamera: true)
        publishHUD(force: true)
    }

    func restartMatch() {
        engine.resetMatch(autoStart: true)
        accumulator = 0
        lastUpdateTimestamp = 0
        hudPublishTimer = 0
        frameMetrics.reset()
        engine.grid.markAllDirty()
        rebuildVisualPools()
        syncAllEntitiesAndCamera(snapCamera: true)
        publishHUD(force: true)
    }

    func togglePause() {
        if engine.gameState == .playing {
            engine.pause()
        } else if engine.gameState == .paused {
            engine.resume()
            lastUpdateTimestamp = 0
        }
        publishHUD(force: true)
    }

    override func update(_ currentTime: TimeInterval) {
        _ = frameMetrics.beginFrame()
        defer { frameMetrics.endFrame() }

        if lastUpdateTimestamp == 0 {
            lastUpdateTimestamp = currentTime
            return
        }

        let rawDt = currentTime - lastUpdateTimestamp
        lastUpdateTimestamp = currentTime
        let clampedDt = min(max(0, rawDt), GameConfig.maxFrameDeltaSeconds)

        if engine.gameState == .playing {
            accumulator += clampedDt
            var steps = 0
            while accumulator >= GameConfig.fixedTimestepSeconds && steps < GameConfig.maxSimStepsPerFrame {
                engine.tick(dt: GameConfig.fixedTimestepSeconds)
                accumulator -= GameConfig.fixedTimestepSeconds
                steps += 1
            }

            hudPublishTimer += clampedDt
            let stateEnded = engine.gameState != .playing
            if stateEnded || hudPublishTimer >= GameConfig.hudPublishIntervalSeconds {
                hudPublishTimer = 0
                publishHUD(force: stateEnded)
            }
        }

        territoryRenderer.syncIfDirty(grid: engine.grid)
        syncAllEntitiesAndCamera(snapCamera: false, dt: clampedDt)
    }

    // MARK: - Direct Touch Steering (Zero SwiftUI Latency)

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        touchStartPoint = touch.location(in: self)
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first, let start = touchStartPoint else { return }
        let current = touch.location(in: self)
        let dx = current.x - start.x
        let dy = current.y - start.y
        let threshold = GameConfig.swipeThresholdPoints
        guard (dx * dx + dy * dy) >= threshold * threshold else { return }

        let dir: Direction = abs(dx) >= abs(dy)
            ? (dx >= 0 ? .right : .left)
            : (dy >= 0 ? .up : .down)

        engine.enqueuePlayerTurn(dir)
        touchStartPoint = current
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        touchStartPoint = nil
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        touchStartPoint = nil
    }

    // MARK: - iPad / Simulator Keyboard Steering

    override func pressesBegan(_ presses: Set<UIPress>, with event: UIPressesEvent?) {
        var handled = false
        for press in presses {
            guard let keyCode = press.key?.keyCode else { continue }
            switch keyCode {
            case .keyboardUpArrow, .keyboardW:
                engine.enqueuePlayerTurn(.up)
                handled = true
            case .keyboardRightArrow, .keyboardD:
                engine.enqueuePlayerTurn(.right)
                handled = true
            case .keyboardDownArrow, .keyboardS:
                engine.enqueuePlayerTurn(.down)
                handled = true
            case .keyboardLeftArrow, .keyboardA:
                engine.enqueuePlayerTurn(.left)
                handled = true
            default:
                break
            }
        }
        if !handled {
            super.pressesBegan(presses, with: event)
        }
    }

    // MARK: - Scene Setup & Sync

    private func setupWorldHierarchy() {
        removeAllChildren()
        worldContainer.removeAllChildren()

        let worldWidth = CGFloat(engine.grid.width) * GameConfig.cellSizePoints
        let worldHeight = CGFloat(engine.grid.height) * GameConfig.cellSizePoints

        let borderRect = CGRect(x: -10, y: -10, width: worldWidth + 20, height: worldHeight + 20)
        let borderNode = SKShapeNode(rect: borderRect, cornerRadius: 8)
        borderNode.fillColor = .clear
        borderNode.strokeColor = UIColor(hex: GameConfig.arenaBorderHex)
        borderNode.lineWidth = 14
        borderNode.zPosition = 2
        worldContainer.addChild(borderNode)

        territorySprite.anchorPoint = .zero
        territorySprite.position = .zero
        territorySprite.zPosition = 1
        worldContainer.addChild(territorySprite)

        addChild(worldContainer)
        camera = cameraNode
        addChild(cameraNode)
    }

    private func rebuildVisualPools() {
        for pool in entityPools.values {
            pool.rootNode.removeFromParent()
            for seg in pool.trailPool {
                seg.removeFromParent()
            }
        }
        entityPools.removeAll()

        for entity in engine.entities {
            territoryRenderer.registerPalette(
                ownerId: entity.id,
                baseHex: entity.colorHex,
                darkHex: entity.darkColorHex
            )
            let pool = EntityVisualPool(
                name: entity.name,
                color: UIColor(hex: entity.colorHex),
                trailColor: UIColor(hex: entity.trailColorHex).withAlphaComponent(0.65),
                size: GameConfig.cellSizePoints * 0.96
            )
            for seg in pool.trailPool {
                worldContainer.addChild(seg)
            }
            worldContainer.addChild(pool.rootNode)
            entityPools[entity.id] = pool
        }

        territoryRenderer.syncIfDirty(grid: engine.grid)
    }

    private func syncAllEntitiesAndCamera(snapCamera: Bool, dt: Double = GameConfig.fixedTimestepSeconds) {
        let cellPts = GameConfig.cellSizePoints
        for entity in engine.entities {
            entityPools[entity.id]?.update(
                entity: entity,
                isLeader: entity.id == currentLeaderId,
                cellSize: cellPts
            )
        }

        let target = CGPoint(
            x: CGFloat(engine.player.posX) * cellPts,
            y: CGFloat(engine.player.posY) * cellPts
        )
        let pct = engine.playerTerritoryPercentage
        if snapCamera {
            cameraController.snap(to: target, territoryPercent: pct, viewportSize: size)
        } else {
            cameraController.update(target: target, territoryPercent: pct, viewportSize: size, dt: dt)
        }
        cameraNode.position = cameraController.position
        cameraNode.setScale(cameraController.scale)
    }

    private func publishHUD(force: Bool) {
        let pct = (engine.playerTerritoryPercentage * 10.0).rounded() / 10.0
        let peak = (engine.peakTerritoryPercentage * 10.0).rounded() / 10.0
        let snapshot = engine.leaderboardSnapshot()
        currentLeaderId = snapshot.topFive.first?.id

        let current = ArenaHUDState(
            percentage: pct,
            peakPercentage: peak,
            kills: engine.player.kills,
            gameState: engine.gameState,
            leaderboard: snapshot
        )
        if force || current != lastPublishedHUD {
            lastPublishedHUD = current
            onHUDUpdate?(current)
        }
    }
}

private extension UIColor {
    convenience init(hex: UInt32) {
        let r = CGFloat((hex >> 16) & 0xFF) / 255.0
        let g = CGFloat((hex >> 8) & 0xFF) / 255.0
        let b = CGFloat(hex & 0xFF) / 255.0
        self.init(red: r, green: g, blue: b, alpha: 1.0)
    }
}
