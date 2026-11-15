import SceneKit
import SwiftUI
import UIKit

/// Interactive 3D SceneKit renderer for Home Territory Showcase and Skin Pedestal Modal.
struct Skin3DPreviewView: UIViewRepresentable {
    let skin: SkinDefinition
    var showTerritoryIsland: Bool = true
    var interactiveRotate: Bool = false

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    func makeUIView(context: Context) -> SCNView {
        let scnView = SCNView()
        scnView.backgroundColor = .clear
        scnView.antialiasingMode = .multisampling4X
        scnView.autoenablesDefaultLighting = false
        scnView.isUserInteractionEnabled = interactiveRotate

        if interactiveRotate {
            let pan = UIPanGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handlePan(_:)))
            scnView.addGestureRecognizer(pan)
        }

        let scene = SCNScene()
        scnView.scene = scene
        setupLightsAndCamera(in: scene)
        rebuildStage(in: scene, coordinator: context.coordinator)
        return scnView
    }

    func updateUIView(_ scnView: SCNView, context: Context) {
        guard let scene = scnView.scene else { return }
        if context.coordinator.currentSkinId != skin.id ||
            context.coordinator.showTerritoryIsland != showTerritoryIsland {
            rebuildStage(in: scene, coordinator: context.coordinator)
        }
    }

    private func setupLightsAndCamera(in scene: SCNScene) {
        let cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        cameraNode.camera?.fieldOfView = 38
        cameraNode.position = SCNVector3(0, 2.35, 5.4)
        cameraNode.eulerAngles = SCNVector3(-0.34, 0, 0)
        scene.rootNode.addChildNode(cameraNode)

        let keyLight = SCNNode()
        keyLight.light = SCNLight()
        keyLight.light?.type = .directional
        keyLight.light?.intensity = 1050
        keyLight.light?.castsShadow = false
        keyLight.position = SCNVector3(3, 6, 4)
        keyLight.look(at: SCNVector3Zero)
        scene.rootNode.addChildNode(keyLight)

        let fillLight = SCNNode()
        fillLight.light = SCNLight()
        fillLight.light?.type = .ambient
        fillLight.light?.intensity = 520
        fillLight.light?.color = UIColor(white: 0.96, alpha: 1.0)
        scene.rootNode.addChildNode(fillLight)
    }

    private func rebuildStage(in scene: SCNScene, coordinator: Coordinator) {
        coordinator.currentSkinId = skin.id
        coordinator.showTerritoryIsland = showTerritoryIsland

        scene.rootNode.childNode(withName: "stageRoot", recursively: false)?.removeFromParentNode()

        let stageRoot = SCNNode()
        stageRoot.name = "stageRoot"
        scene.rootNode.addChildNode(stageRoot)

        // Territory island or glowing pedestal
        if showTerritoryIsland {
            let island = buildHomeTerritoryIsland(color: UIColor(hex: skin.primaryHex))
            island.position = SCNVector3(0, -0.68, 0)
            stageRoot.addChildNode(island)
        } else {
            let halo = buildShowcasePedestal()
            halo.position = SCNVector3(0, -0.78, 0)
            stageRoot.addChildNode(halo)
        }

        // Character node
        let characterHolder = SCNNode()
        characterHolder.name = "characterHolder"
        let model = VoxelCharacter3DFactory.buildCharacter(for: skin)
        model.eulerAngles = SCNVector3(0, showTerritoryIsland ? -0.35 : -0.45, 0)
        characterHolder.addChildNode(model)
        characterHolder.position = SCNVector3(showTerritoryIsland ? -0.15 : 0, 0.05, 0)
        stageRoot.addChildNode(characterHolder)
        coordinator.characterNode = characterHolder

        // Gentle floating bob + rotation idle animation
        let bobUp = SCNAction.moveBy(x: 0, y: 0.10, z: 0, duration: 0.95)
        bobUp.timingMode = .easeInEaseOut
        let bobDown = SCNAction.moveBy(x: 0, y: -0.10, z: 0, duration: 0.95)
        bobDown.timingMode = .easeInEaseOut
        characterHolder.runAction(.repeatForever(.sequence([bobUp, bobDown])))

        if !interactiveRotate {
            let turnLeft = SCNAction.rotateBy(x: 0, y: 0.16, z: 0, duration: 1.8)
            turnLeft.timingMode = .easeInEaseOut
            let turnRight = SCNAction.rotateBy(x: 0, y: -0.16, z: 0, duration: 1.8)
            turnRight.timingMode = .easeInEaseOut
            model.runAction(.repeatForever(.sequence([turnLeft, turnRight])))
        }
    }

    private func buildHomeTerritoryIsland(color: UIColor) -> SCNNode {
        let root = SCNNode()

        // Main oval/blob territory base with 3D extruded edge
        let topCylinder = SCNCylinder(radius: 1.55, height: 0.18)
        topCylinder.radialSegmentCount = 36
        let topMat = SCNMaterial()
        topMat.diffuse.contents = color
        topCylinder.materials = [topMat]
        let topNode = SCNNode(geometry: topCylinder)
        topNode.scale = SCNVector3(1.25, 1.0, 0.72)
        topNode.position = SCNVector3(-0.35, 0, -0.15)
        root.addChildNode(topNode)

        // Darker underside lip
        let lipCylinder = SCNCylinder(radius: 1.56, height: 0.14)
        lipCylinder.radialSegmentCount = 36
        let lipMat = SCNMaterial()
        lipMat.diffuse.contents = color.darker(by: 0.28)
        lipCylinder.materials = [lipMat]
        let lipNode = SCNNode(geometry: lipCylinder)
        lipNode.scale = SCNVector3(1.25, 1.0, 0.72)
        lipNode.position = SCNVector3(-0.35, -0.11, -0.15)
        root.addChildNode(lipNode)

        // Curved white -> color ribbon trail extending to right like Home video frame
        for i in 0..<10 {
            let t = Float(i) / 9.0
            let box = SCNBox(width: 0.34, height: 0.08, length: 0.42, chamferRadius: 0.03)
            let mat = SCNMaterial()
            mat.diffuse.contents = UIColor.white.blended(with: color, factor: CGFloat(1.0 - t * 0.85))
            box.materials = [mat]
            let seg = SCNNode(geometry: box)
            let x = -0.1 + t * 1.65
            let z = 0.25 * sin(t * Float.pi) - 0.1
            seg.position = SCNVector3(x, 0.06, z)
            seg.eulerAngles = SCNVector3(0, -0.35 * cos(t * Float.pi), 0)
            root.addChildNode(seg)
        }

        return root
    }

    private func buildShowcasePedestal() -> SCNNode {
        let root = SCNNode()

        let outerRing = SCNCylinder(radius: 1.38, height: 0.08)
        outerRing.radialSegmentCount = 48
        let outerMat = SCNMaterial()
        outerMat.diffuse.contents = UIColor.white.withAlphaComponent(0.55)
        outerMat.emission.contents = UIColor(hex: "BAE6FD").withAlphaComponent(0.35)
        outerRing.materials = [outerMat]
        let outerNode = SCNNode(geometry: outerRing)
        outerNode.scale = SCNVector3(1.0, 1.0, 0.86)
        root.addChildNode(outerNode)

        let innerDisc = SCNCylinder(radius: 1.10, height: 0.10)
        innerDisc.radialSegmentCount = 48
        let innerMat = SCNMaterial()
        innerMat.diffuse.contents = UIColor(hex: "38BDF8")
        innerMat.emission.contents = UIColor.white.withAlphaComponent(0.25)
        innerDisc.materials = [innerMat]
        let innerNode = SCNNode(geometry: innerDisc)
        innerNode.scale = SCNVector3(1.0, 1.0, 0.86)
        innerNode.position = SCNVector3(0, 0.02, 0)
        root.addChildNode(innerNode)

        return root
    }

    final class Coordinator: NSObject {
        var currentSkinId: String = ""
        var showTerritoryIsland: Bool = true
        weak var characterNode: SCNNode?

        @objc func handlePan(_ gesture: UIPanGestureRecognizer) {
            guard let node = characterNode else { return }
            let translation = gesture.translation(in: gesture.view)
            node.eulerAngles.y += Float(translation.x) * 0.014
            gesture.setTranslation(.zero, in: gesture.view)
        }
    }
}

// MARK: - Procedural 3D Voxel Model Factory

private enum VoxelCharacter3DFactory {
    static func buildCharacter(for skin: SkinDefinition) -> SCNNode {
        let root = SCNNode()
        let pCol = UIColor(hex: skin.primaryHex)
        let sCol = UIColor(hex: skin.secondaryHex)
        let aCol = UIColor(hex: skin.accentHex)

        switch skin.blueprint {
        case .wizard:
            // Robe body
            root.addChildNode(box(w: 1.05, h: 0.85, l: 0.95, r: 0.12, color: pCol, y: -0.15))
            // Orange & yellow striped scarf
            root.addChildNode(box(w: 1.15, h: 0.22, l: 1.05, r: 0.08, color: UIColor(hex: "F97316"), y: 0.30))
            root.addChildNode(box(w: 0.28, h: 0.45, l: 0.16, r: 0.05, color: UIColor(hex: "FACC15"), x: 0.22, y: 0.08, z: 0.50))
            // Head
            root.addChildNode(box(w: 0.92, h: 0.68, l: 0.88, r: 0.14, color: UIColor(hex: "FDE6C4"), y: 0.68))
            // Hair cap
            root.addChildNode(box(w: 0.98, h: 0.26, l: 0.94, r: 0.10, color: UIColor(hex: "451A03"), y: 0.96))
            // Golden glasses
            root.addChildNode(torus(ringR: 0.16, pipeR: 0.03, color: UIColor(hex: "F59E0B"), x: -0.20, y: 0.68, z: 0.46, rotX: .pi / 2))
            root.addChildNode(torus(ringR: 0.16, pipeR: 0.03, color: UIColor(hex: "F59E0B"), x: 0.20, y: 0.68, z: 0.46, rotX: .pi / 2))
            // Wand + glowing pink spark
            let wand = cylinder(r: 0.05, h: 0.72, color: UIColor(hex: "78350F"), x: 0.68, y: 0.12, z: 0.38)
            wand.eulerAngles = SCNVector3(0.7, 0, -0.45)
            root.addChildNode(wand)
            let tip = sphere(r: 0.12, color: UIColor(hex: "F472B6"), x: 0.88, y: 0.30, z: 0.62, glow: true)
            root.addChildNode(tip)

        case .watermelon:
            let rind = box(w: 1.55, h: 0.22, l: 1.05, r: 0.06, color: sCol, y: -0.28)
            let pith = box(w: 1.44, h: 0.12, l: 0.96, r: 0.04, color: UIColor(hex: "DCFCE7"), y: -0.14)
            let wedge = SCNPyramid(width: 1.38, height: 0.92, length: 0.90)
            let wedgeMat = SCNMaterial()
            wedgeMat.diffuse.contents = pCol
            wedge.materials = [wedgeMat]
            let wedgeNode = SCNNode(geometry: wedge)
            wedgeNode.position = SCNVector3(0, -0.08, 0)
            root.addChildNode(rind)
            root.addChildNode(pith)
            root.addChildNode(wedgeNode)
            // Seeds
            for (sx, sy) in [(-0.26, 0.16), (0.22, 0.22), (0.0, 0.38)] {
                root.addChildNode(sphere(r: 0.055, color: UIColor(hex: "1E293B"), x: Float(sx), y: Float(sy), z: 0.30))
            }

        case .brain:
            root.addChildNode(box(w: 0.58, h: 0.88, l: 1.15, r: 0.24, color: pCol, x: -0.32, y: 0.20))
            root.addChildNode(box(w: 0.58, h: 0.88, l: 1.15, r: 0.24, color: pCol, x: 0.32, y: 0.20))
            for zPos in [-0.30, 0.0, 0.30] as [Float] {
                root.addChildNode(box(w: 1.10, h: 0.16, l: 0.14, r: 0.07, color: sCol, y: 0.62, z: zPos))
            }

        case .car:
            root.addChildNode(box(w: 1.50, h: 0.44, l: 0.92, r: 0.10, color: pCol, y: -0.08))
            root.addChildNode(box(w: 0.86, h: 0.40, l: 0.84, r: 0.10, color: pCol, x: -0.05, y: 0.30))
            root.addChildNode(box(w: 0.90, h: 0.24, l: 0.72, r: 0.04, color: aCol, x: -0.04, y: 0.30))
            for (wx, wz) in [(-0.46, 0.46), (0.46, 0.46), (-0.46, -0.46), (0.46, -0.46)] as [(Float, Float)] {
                let wheel = cylinder(r: 0.20, h: 0.14, color: UIColor(hex: "1E293B"), x: wx, y: -0.32, z: wz)
                wheel.eulerAngles = SCNVector3(Float.pi / 2, 0, 0)
                root.addChildNode(wheel)
            }

        case .cow:
            root.addChildNode(box(w: 1.12, h: 0.95, l: 1.25, r: 0.16, color: pCol, y: 0.12))
            root.addChildNode(box(w: 0.42, h: 0.42, l: 0.50, r: 0.08, color: sCol, x: -0.40, y: 0.32, z: 0.15))
            root.addChildNode(box(w: 0.80, h: 0.34, l: 0.34, r: 0.10, color: aCol, y: -0.02, z: 0.65))
            root.addChildNode(cone(r: 0.10, h: 0.28, color: UIColor(hex: "FDE047"), x: -0.36, y: 0.72, z: 0.28))
            root.addChildNode(cone(r: 0.10, h: 0.28, color: UIColor(hex: "FDE047"), x: 0.36, y: 0.72, z: 0.28))
            addEyes(to: root, y: 0.32, z: 0.63, color: sCol)

        case .dino:
            root.addChildNode(box(w: 0.95, h: 0.85, l: 1.20, r: 0.18, color: pCol, y: 0.0))
            root.addChildNode(box(w: 0.76, h: 0.70, l: 0.80, r: 0.16, color: pCol, y: 0.68, z: 0.30))
            for idx in 0..<3 {
                root.addChildNode(cone(r: 0.12, h: 0.26, color: aCol, x: 0, y: 0.95 - Float(idx) * 0.28, z: -0.15 - Float(idx) * 0.24))
            }
            addCartoonEyes(to: root, y: 0.72, z: 0.70)

        case .donut:
            let baseTorus = torus(ringR: 0.58, pipeR: 0.28, color: sCol, x: 0, y: 0.12, z: 0, rotX: 0.25)
            let frosting = torus(ringR: 0.58, pipeR: 0.27, color: pCol, x: 0, y: 0.18, z: 0, rotX: 0.25)
            root.addChildNode(baseTorus)
            root.addChildNode(frosting)
            let sprinkleColors = [UIColor(hex: "38BDF8"), UIColor(hex: "FACC15"), UIColor(hex: "4ADE80"), UIColor.white]
            for i in 0..<8 {
                let ang = Float(i) * (Float.pi * 2 / 8)
                let sp = box(w: 0.14, h: 0.06, l: 0.06, r: 0.02, color: sprinkleColors[i % sprinkleColors.count],
                             x: cos(ang) * 0.56, y: 0.44, z: sin(ang) * 0.56)
                sp.eulerAngles = SCNVector3(0, ang, 0)
                root.addChildNode(sp)
            }

        case .ghost:
            root.addChildNode(box(w: 1.05, h: 1.15, l: 1.05, r: 0.36, color: pCol, y: 0.22))
            for gx in [-0.32, 0.0, 0.32] as [Float] {
                root.addChildNode(sphere(r: 0.22, color: pCol, x: gx, y: -0.34, z: 0.24))
            }
            root.addChildNode(box(w: 0.16, h: 0.28, l: 0.08, r: 0.04, color: aCol, x: -0.22, y: 0.32, z: 0.53))
            root.addChildNode(box(w: 0.16, h: 0.28, l: 0.08, r: 0.04, color: aCol, x: 0.22, y: 0.32, z: 0.53))

        case .rhino:
            root.addChildNode(box(w: 1.10, h: 0.90, l: 1.32, r: 0.18, color: pCol, y: 0.12))
            root.addChildNode(cone(r: 0.15, h: 0.48, color: aCol, x: 0, y: 0.36, z: 0.80))
            addCartoonEyes(to: root, y: 0.30, z: 0.66)

        case .unicorn:
            root.addChildNode(box(w: 1.00, h: 0.96, l: 1.18, r: 0.18, color: pCol, y: 0.10))
            root.addChildNode(box(w: 0.72, h: 0.70, l: 0.80, r: 0.16, color: pCol, y: 0.68, z: 0.22))
            root.addChildNode(cone(r: 0.12, h: 0.46, color: aCol, x: 0, y: 1.18, z: 0.34))
            addCartoonEyes(to: root, y: 0.72, z: 0.62)

        case .whale:
            root.addChildNode(box(w: 1.16, h: 0.86, l: 1.38, r: 0.28, color: pCol, y: 0.12))
            root.addChildNode(box(w: 1.12, h: 0.28, l: 1.32, r: 0.14, color: .white, y: -0.18))
            root.addChildNode(sphere(r: 0.12, color: UIColor(hex: "BAE6FD"), x: -0.12, y: 0.75, z: 0.1))
            root.addChildNode(sphere(r: 0.10, color: UIColor(hex: "BAE6FD"), x: 0.14, y: 0.82, z: 0.0))
            addEyes(to: root, y: 0.18, z: 0.69, color: UIColor(hex: "0F172A"))

        case .hammer:
            root.addChildNode(cylinder(r: 0.12, h: 1.10, color: UIColor(hex: "78350F"), x: 0, y: -0.12, z: 0))
            root.addChildNode(box(w: 1.38, h: 0.74, l: 0.82, r: 0.14, color: pCol, y: 0.56))
            root.addChildNode(box(w: 1.44, h: 0.16, l: 0.86, r: 0.04, color: sCol, y: 0.56))

        case .ufo:
            let saucer = cylinder(r: 0.88, h: 0.24, color: pCol, x: 0, y: 0.05, z: 0)
            root.addChildNode(saucer)
            let dome = sphere(r: 0.50, color: aCol.withAlphaComponent(0.75), x: 0, y: 0.22, z: 0, glow: true)
            root.addChildNode(dome)
            for i in 0..<6 {
                let a = Float(i) * (Float.pi * 2 / 6)
                root.addChildNode(sphere(r: 0.09, color: UIColor(hex: "FDE047"), x: cos(a) * 0.75, y: 0.05, z: sin(a) * 0.75, glow: true))
            }

        case .eagle:
            root.addChildNode(box(w: 1.00, h: 0.76, l: 1.00, r: 0.16, color: pCol, y: 0.0))
            root.addChildNode(box(w: 0.82, h: 0.58, l: 0.82, r: 0.14, color: .white, y: 0.56))
            let beak = cone(r: 0.15, h: 0.30, color: aCol, x: 0, y: 0.48, z: 0.48)
            beak.eulerAngles = SCNVector3(Float.pi / 2, 0, 0)
            root.addChildNode(beak)
            addEyes(to: root, y: 0.62, z: 0.42, color: UIColor(hex: "0F172A"))

        case .flagCube:
            let flagImg = makeFlagTexture(code: skin.flagCode ?? "US", primary: pCol, secondary: sCol, accent: aCol)
            let cube = SCNBox(width: 1.15, height: 1.15, length: 1.15, chamferRadius: 0.18)
            let mat = SCNMaterial()
            mat.diffuse.contents = flagImg
            cube.materials = [mat]
            let node = SCNNode(geometry: cube)
            node.position = SCNVector3(0, 0.22, 0)
            root.addChildNode(node)
            addCartoonEyes(to: root, y: 0.26, z: 0.58)

        case .seasonalPumpkin:
            root.addChildNode(box(w: 1.12, h: 0.96, l: 1.12, r: 0.32, color: pCol, y: 0.16))
            root.addChildNode(box(w: 0.20, h: 0.30, l: 0.20, r: 0.04, color: UIColor(hex: "16A34A"), y: 0.76))
            root.addChildNode(cone(r: 0.13, h: 0.22, color: aCol, x: -0.22, y: 0.26, z: 0.57))
            root.addChildNode(cone(r: 0.13, h: 0.22, color: aCol, x: 0.22, y: 0.26, z: 0.57))

        case .seasonalSanta:
            root.addChildNode(box(w: 1.08, h: 1.02, l: 1.08, r: 0.20, color: pCol, y: 0.12))
            root.addChildNode(box(w: 0.88, h: 0.42, l: 0.92, r: 0.12, color: UIColor(hex: "FDE6C4"), y: 0.34))
            root.addChildNode(box(w: 0.90, h: 0.34, l: 0.34, r: 0.10, color: .white, y: 0.02, z: 0.48))
            root.addChildNode(cone(r: 0.55, h: 0.62, color: pCol, x: 0, y: 0.90, z: 0))
            root.addChildNode(sphere(r: 0.14, color: .white, x: 0, y: 1.24, z: 0))
            addEyes(to: root, y: 0.42, z: 0.47, color: UIColor(hex: "0F172A"))

        default:
            // Expressive Paper.io Hero / Creature / Object Cube
            root.addChildNode(box(w: 1.12, h: 1.12, l: 1.12, r: 0.22, color: pCol, y: 0.20))
            root.addChildNode(box(w: 1.16, h: 0.24, l: 1.16, r: 0.10, color: sCol, y: -0.24))
            addCartoonEyes(to: root, y: 0.28, z: 0.56)

            if skin.blueprint == .heroCrown || skin.blueprint == .objectCrown || skin.category == .legendary {
                root.addChildNode(box(w: 0.70, h: 0.28, l: 0.70, r: 0.06, color: UIColor(hex: "FACC15"), y: 0.88))
            } else if skin.blueprint == .heroFlame {
                root.addChildNode(cone(r: 0.38, h: 0.55, color: aCol, x: 0, y: 0.96, z: 0))
            } else if skin.blueprint == .heroVisor {
                root.addChildNode(box(w: 0.92, h: 0.26, l: 0.16, r: 0.06, color: aCol, y: 0.32, z: 0.54))
            }
        }

        return root
    }

    private static func addCartoonEyes(to parent: SCNNode, y: Float, z: Float) {
        for ex in [-0.22, 0.22] as [Float] {
            parent.addChildNode(sphere(r: 0.14, color: .white, x: ex, y: y, z: z))
            parent.addChildNode(sphere(r: 0.075, color: UIColor(hex: "0F172A"), x: ex, y: y, z: z + 0.09))
        }
    }

    private static func addEyes(to parent: SCNNode, y: Float, z: Float, color: UIColor) {
        parent.addChildNode(sphere(r: 0.09, color: color, x: -0.22, y: y, z: z))
        parent.addChildNode(sphere(r: 0.09, color: color, x: 0.22, y: y, z: z))
    }

    private static func box(w: CGFloat, h: CGFloat, l: CGFloat, r: CGFloat, color: UIColor, x: Float = 0, y: Float = 0, z: Float = 0) -> SCNNode {
        let geom = SCNBox(width: w, height: h, length: l, chamferRadius: r)
        let mat = SCNMaterial()
        mat.diffuse.contents = color
        geom.materials = [mat]
        let node = SCNNode(geometry: geom)
        node.position = SCNVector3(x, y, z)
        return node
    }

    private static func sphere(r: CGFloat, color: UIColor, x: Float = 0, y: Float = 0, z: Float = 0, glow: Bool = false) -> SCNNode {
        let geom = SCNSphere(radius: r)
        let mat = SCNMaterial()
        mat.diffuse.contents = color
        if glow {
            mat.emission.contents = color.withAlphaComponent(0.75)
        }
        geom.materials = [mat]
        let node = SCNNode(geometry: geom)
        node.position = SCNVector3(x, y, z)
        return node
    }

    private static func cylinder(r: CGFloat, h: CGFloat, color: UIColor, x: Float = 0, y: Float = 0, z: Float = 0) -> SCNNode {
        let geom = SCNCylinder(radius: r, height: h)
        let mat = SCNMaterial()
        mat.diffuse.contents = color
        geom.materials = [mat]
        let node = SCNNode(geometry: geom)
        node.position = SCNVector3(x, y, z)
        return node
    }

    private static func cone(r: CGFloat, h: CGFloat, color: UIColor, x: Float = 0, y: Float = 0, z: Float = 0) -> SCNNode {
        let geom = SCNCone(topRadius: 0.02, bottomRadius: r, height: h)
        let mat = SCNMaterial()
        mat.diffuse.contents = color
        geom.materials = [mat]
        let node = SCNNode(geometry: geom)
        node.position = SCNVector3(x, y, z)
        return node
    }

    private static func torus(ringR: CGFloat, pipeR: CGFloat, color: UIColor, x: Float, y: Float, z: Float, rotX: Float) -> SCNNode {
        let geom = SCNTorus(ringRadius: ringR, pipeRadius: pipeR)
        let mat = SCNMaterial()
        mat.diffuse.contents = color
        geom.materials = [mat]
        let node = SCNNode(geometry: geom)
        node.position = SCNVector3(x, y, z)
        node.eulerAngles = SCNVector3(rotX, 0, 0)
        return node
    }

    private static func makeFlagTexture(code: String, primary: UIColor, secondary: UIColor, accent: UIColor) -> UIImage {
        let size = CGSize(width: 128, height: 128)
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { ctx in
            let cg = ctx.cgContext
            cg.setFillColor(primary.cgColor)
            cg.fill(CGRect(origin: .zero, size: size))
            cg.setFillColor(accent.cgColor)
            cg.fill(CGRect(x: 0, y: 42, width: 128, height: 44))
            cg.setFillColor(secondary.cgColor)
            cg.fill(CGRect(x: 0, y: 86, width: 128, height: 42))
        }
    }
}

private extension UIColor {
    func darker(by factor: CGFloat) -> UIColor {
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        getRed(&r, green: &g, blue: &b, alpha: &a)
        return UIColor(red: max(0, r * (1 - factor)), green: max(0, g * (1 - factor)), blue: max(0, b * (1 - factor)), alpha: a)
    }

    func blended(with other: UIColor, factor: CGFloat) -> UIColor {
        var r1: CGFloat = 0, g1: CGFloat = 0, b1: CGFloat = 0, a1: CGFloat = 0
        var r2: CGFloat = 0, g2: CGFloat = 0, b2: CGFloat = 0, a2: CGFloat = 0
        getRed(&r1, green: &g1, blue: &b1, alpha: &a1)
        other.getRed(&r2, green: &g2, blue: &b2, alpha: &a2)
        let t = max(0, min(1, factor))
        return UIColor(
            red: r1 + (r2 - r1) * t,
            green: g1 + (g2 - g1) * t,
            blue: b1 + (b2 - b1) * t,
            alpha: a1 + (a2 - a1) * t
        )
    }
}
