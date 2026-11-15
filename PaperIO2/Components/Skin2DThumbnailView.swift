import SwiftUI

/// Crisp 2D cartoon isometric icon representing any of the 104 skins in grids, bubbles, and HUDs.
struct Skin2DThumbnailView: View {
    let skin: SkinDefinition
    var size: CGFloat = 64

    var body: some View {
        ZStack {
            switch skin.blueprint {
            case .wizard:
                wizardIcon
            case .watermelon:
                watermelonIcon
            case .brain:
                brainIcon
            case .car:
                carIcon
            case .cow:
                cowIcon
            case .dino:
                dinoIcon
            case .donut:
                donutIcon
            case .ghost:
                ghostIcon
            case .hippo:
                hippoIcon
            case .rhino:
                rhinoIcon
            case .ufo:
                ufoIcon
            case .unicorn:
                unicornIcon
            case .whale:
                whaleIcon
            case .eagle:
                eagleIcon
            case .hammer:
                hammerIcon
            case .flagCube:
                flagCubeIcon
            case .seasonalPumpkin:
                pumpkinIcon
            case .seasonalSanta:
                santaIcon
            case .seasonalSnowman:
                snowmanIcon
            default:
                genericCubeCharacterIcon
            }
        }
        .frame(width: size, height: size)
    }

    // MARK: - Signature Video Skins

    private var wizardIcon: some View {
        ZStack {
            // Robe body
            RoundedRectangle(cornerRadius: size * 0.16)
                .fill(skin.primaryColor)
                .frame(width: size * 0.62, height: size * 0.56)
                .overlay(RoundedRectangle(cornerRadius: size * 0.16).stroke(Color.black.opacity(0.6), lineWidth: 1.5))
                .offset(y: size * 0.14)

            // Orange/gold scarf
            RoundedRectangle(cornerRadius: size * 0.08)
                .fill(Color(hex: "F97316"))
                .frame(width: size * 0.60, height: size * 0.16)
                .overlay(
                    HStack(spacing: size * 0.08) {
                        Rectangle().fill(Color(hex: "FACC15")).frame(width: size * 0.09)
                        Rectangle().fill(Color(hex: "FACC15")).frame(width: size * 0.09)
                    }
                )
                .offset(y: size * 0.02)

            // Face & Hair
            RoundedRectangle(cornerRadius: size * 0.15)
                .fill(Color(hex: "FDE6C4"))
                .frame(width: size * 0.54, height: size * 0.40)
                .overlay(RoundedRectangle(cornerRadius: size * 0.15).stroke(Color.black.opacity(0.6), lineWidth: 1.5))
                .offset(y: -size * 0.18)

            // Dark brown hair top
            RoundedCornerShape(radius: size * 0.14, corners: [.topLeft, .topRight])
                .fill(Color(hex: "451A03"))
                .frame(width: size * 0.56, height: size * 0.16)
                .offset(y: -size * 0.31)

            // Round golden glasses
            HStack(spacing: size * 0.04) {
                Circle().stroke(Color(hex: "F59E0B"), lineWidth: 2).frame(width: size * 0.16, height: size * 0.16)
                    .background(Circle().fill(Color(hex: "38BDF8").opacity(0.45)))
                Circle().stroke(Color(hex: "F59E0B"), lineWidth: 2).frame(width: size * 0.16, height: size * 0.16)
                    .background(Circle().fill(Color(hex: "38BDF8").opacity(0.45)))
            }
            .offset(y: -size * 0.16)

            // Magic wand spark
            Circle()
                .fill(Color(hex: "F472B6"))
                .frame(width: size * 0.14, height: size * 0.14)
                .shadow(color: Color(hex: "F472B6"), radius: 4)
                .offset(x: size * 0.34, y: size * 0.16)
        }
    }

    private var watermelonIcon: some View {
        ZStack {
            TriangleShape()
                .fill(skin.secondaryColor)
                .frame(width: size * 0.78, height: size * 0.58)
                .overlay(TriangleShape().stroke(Color.black.opacity(0.55), lineWidth: 1.5))
            TriangleShape()
                .fill(Color(hex: "DCFCE7"))
                .frame(width: size * 0.68, height: size * 0.50)
                .offset(y: -size * 0.02)
            TriangleShape()
                .fill(skin.primaryColor)
                .frame(width: size * 0.58, height: size * 0.42)
                .offset(y: -size * 0.03)
            // Seeds
            HStack(spacing: size * 0.08) {
                Circle().fill(Color(hex: "1E293B")).frame(width: size * 0.05, height: size * 0.05)
                Circle().fill(Color(hex: "1E293B")).frame(width: size * 0.05, height: size * 0.05)
            }
            .offset(y: size * 0.04)
        }
    }

    private var brainIcon: some View {
        ZStack {
            HStack(spacing: 2) {
                RoundedRectangle(cornerRadius: size * 0.18)
                    .fill(skin.primaryColor)
                    .frame(width: size * 0.36, height: size * 0.62)
                RoundedRectangle(cornerRadius: size * 0.18)
                    .fill(skin.primaryColor)
                    .frame(width: size * 0.36, height: size * 0.62)
            }
            .overlay(
                RoundedRectangle(cornerRadius: size * 0.22)
                    .stroke(skin.secondaryColor, lineWidth: 2)
            )
            VStack(spacing: size * 0.09) {
                Capsule().fill(skin.secondaryColor.opacity(0.55)).frame(width: size * 0.52, height: 3)
                Capsule().fill(skin.secondaryColor.opacity(0.55)).frame(width: size * 0.46, height: 3)
                Capsule().fill(skin.secondaryColor.opacity(0.55)).frame(width: size * 0.52, height: 3)
            }
        }
    }

    private var carIcon: some View {
        ZStack {
            // Wheels
            HStack(spacing: size * 0.32) {
                Circle().fill(Color(hex: "1E293B")).frame(width: size * 0.18, height: size * 0.18)
                Circle().fill(Color(hex: "1E293B")).frame(width: size * 0.18, height: size * 0.18)
            }
            .offset(y: size * 0.22)

            // Body
            RoundedRectangle(cornerRadius: size * 0.12)
                .fill(skin.primaryColor)
                .frame(width: size * 0.78, height: size * 0.34)
                .overlay(RoundedRectangle(cornerRadius: size * 0.12).stroke(Color.black.opacity(0.6), lineWidth: 1.5))
                .offset(y: size * 0.08)

            // Roof cab & window
            RoundedRectangle(cornerRadius: size * 0.1)
                .fill(skin.primaryColor)
                .frame(width: size * 0.48, height: size * 0.26)
                .overlay(
                    RoundedRectangle(cornerRadius: size * 0.06)
                        .fill(skin.accentColor)
                        .frame(width: size * 0.36, height: size * 0.14)
                )
                .overlay(RoundedRectangle(cornerRadius: size * 0.1).stroke(Color.black.opacity(0.55), lineWidth: 1.5))
                .offset(y: -size * 0.12)
        }
    }

    private var cowIcon: some View {
        ZStack {
            // Horns
            HStack(spacing: size * 0.44) {
                Circle().fill(Color(hex: "FDE047")).frame(width: size * 0.14, height: size * 0.14)
                Circle().fill(Color(hex: "FDE047")).frame(width: size * 0.14, height: size * 0.14)
            }
            .offset(y: -size * 0.28)

            RoundedRectangle(cornerRadius: size * 0.18)
                .fill(skin.primaryColor)
                .frame(width: size * 0.68, height: size * 0.62)
                .overlay(
                    Circle().fill(skin.secondaryColor).frame(width: size * 0.22).offset(x: -size * 0.18, y: -size * 0.14)
                )
                .overlay(RoundedRectangle(cornerRadius: size * 0.18).stroke(Color.black.opacity(0.6), lineWidth: 1.5))

            // Pink snout
            RoundedRectangle(cornerRadius: size * 0.12)
                .fill(skin.accentColor)
                .frame(width: size * 0.46, height: size * 0.24)
                .offset(y: size * 0.14)

            eyePair(color: skin.secondaryColor, yOffset: -size * 0.06)
        }
    }

    private var dinoIcon: some View {
        ZStack {
            // Back spikes
            HStack(spacing: size * 0.06) {
                TriangleShape().fill(skin.accentColor).frame(width: size * 0.14, height: size * 0.14)
                TriangleShape().fill(skin.accentColor).frame(width: size * 0.14, height: size * 0.14)
            }
            .offset(x: -size * 0.12, y: -size * 0.32)

            RoundedRectangle(cornerRadius: size * 0.20)
                .fill(skin.primaryColor)
                .frame(width: size * 0.64, height: size * 0.66)
                .overlay(RoundedRectangle(cornerRadius: size * 0.20).stroke(Color.black.opacity(0.6), lineWidth: 1.5))

            eyePair(color: .white, pupil: .black, yOffset: -size * 0.10)
        }
    }

    private var donutIcon: some View {
        ZStack {
            Circle()
                .fill(skin.secondaryColor)
                .frame(width: size * 0.76, height: size * 0.76)
                .overlay(Circle().stroke(Color.black.opacity(0.55), lineWidth: 1.5))
            Circle()
                .fill(skin.primaryColor)
                .frame(width: size * 0.70, height: size * 0.62)
                .offset(y: -size * 0.04)
            // Sprinkles
            HStack(spacing: size * 0.12) {
                Capsule().fill(Color(hex: "38BDF8")).frame(width: 8, height: 3).rotationEffect(.degrees(30))
                Capsule().fill(Color(hex: "FACC15")).frame(width: 8, height: 3).rotationEffect(.degrees(-25))
                Capsule().fill(Color(hex: "4ADE80")).frame(width: 8, height: 3).rotationEffect(.degrees(15))
            }
            .offset(y: -size * 0.18)
            // Center hole
            Circle()
                .fill(Color(hex: "1B8CEB").opacity(0.85))
                .frame(width: size * 0.24, height: size * 0.24)
        }
    }

    private var ghostIcon: some View {
        ZStack {
            RoundedRectangle(cornerRadius: size * 0.26)
                .fill(skin.primaryColor)
                .frame(width: size * 0.64, height: size * 0.68)
                .overlay(RoundedRectangle(cornerRadius: size * 0.26).stroke(skin.secondaryColor, lineWidth: 2))

            HStack(spacing: size * 0.12) {
                RoundedRectangle(cornerRadius: 3).fill(skin.accentColor).frame(width: size * 0.13, height: size * 0.18)
                RoundedRectangle(cornerRadius: 3).fill(skin.accentColor).frame(width: size * 0.13, height: size * 0.18)
            }
            .offset(y: -size * 0.05)
        }
    }

    private var hippoIcon: some View {
        ZStack {
            RoundedRectangle(cornerRadius: size * 0.20)
                .fill(skin.primaryColor)
                .frame(width: size * 0.68, height: size * 0.62)
                .overlay(RoundedRectangle(cornerRadius: size * 0.20).stroke(Color.black.opacity(0.55), lineWidth: 1.5))
            RoundedRectangle(cornerRadius: size * 0.14)
                .fill(skin.secondaryColor)
                .frame(width: size * 0.56, height: size * 0.26)
                .offset(y: size * 0.15)
            eyePair(color: .white, pupil: .black, yOffset: -size * 0.12)
        }
    }

    private var rhinoIcon: some View {
        ZStack {
            RoundedRectangle(cornerRadius: size * 0.18)
                .fill(skin.primaryColor)
                .frame(width: size * 0.68, height: size * 0.60)
                .overlay(RoundedRectangle(cornerRadius: size * 0.18).stroke(Color.black.opacity(0.55), lineWidth: 1.5))
            TriangleShape()
                .fill(skin.accentColor)
                .frame(width: size * 0.20, height: size * 0.26)
                .offset(x: size * 0.24, y: -size * 0.06)
            eyePair(color: .white, pupil: .black, yOffset: -size * 0.10)
        }
    }

    private var ufoIcon: some View {
        ZStack {
            Circle()
                .fill(skin.accentColor.opacity(0.85))
                .frame(width: size * 0.42, height: size * 0.42)
                .offset(y: -size * 0.12)
            Ellipse()
                .fill(skin.primaryColor)
                .frame(width: size * 0.82, height: size * 0.34)
                .overlay(Ellipse().stroke(skin.secondaryColor, lineWidth: 2))
                .offset(y: size * 0.06)
            HStack(spacing: size * 0.14) {
                Circle().fill(Color(hex: "FDE047")).frame(width: 5, height: 5)
                Circle().fill(Color(hex: "FDE047")).frame(width: 5, height: 5)
                Circle().fill(Color(hex: "FDE047")).frame(width: 5, height: 5)
            }
            .offset(y: size * 0.06)
        }
    }

    private var unicornIcon: some View {
        ZStack {
            TriangleShape()
                .fill(skin.accentColor)
                .frame(width: size * 0.16, height: size * 0.28)
                .offset(y: -size * 0.36)
            RoundedRectangle(cornerRadius: size * 0.18)
                .fill(skin.primaryColor)
                .frame(width: size * 0.62, height: size * 0.62)
                .overlay(RoundedRectangle(cornerRadius: size * 0.18).stroke(skin.secondaryColor, lineWidth: 1.8))
            eyePair(color: .white, pupil: Color(hex: "4C1D95"), yOffset: -size * 0.04)
        }
    }

    private var whaleIcon: some View {
        ZStack {
            RoundedRectangle(cornerRadius: size * 0.24)
                .fill(skin.primaryColor)
                .frame(width: size * 0.72, height: size * 0.56)
                .overlay(RoundedRectangle(cornerRadius: size * 0.24).stroke(skin.secondaryColor, lineWidth: 1.8))
            RoundedCornerShape(radius: size * 0.16, corners: [.bottomLeft, .bottomRight])
                .fill(Color.white)
                .frame(width: size * 0.66, height: size * 0.22)
                .offset(y: size * 0.15)
            // Water spout
            HStack(spacing: 4) {
                Circle().fill(Color(hex: "BAE6FD")).frame(width: 6, height: 6)
                Circle().fill(Color(hex: "BAE6FD")).frame(width: 6, height: 6)
            }
            .offset(y: -size * 0.35)
            eyePair(color: Color(hex: "1E293B"), yOffset: -size * 0.03)
        }
    }

    private var eagleIcon: some View {
        ZStack {
            RoundedRectangle(cornerRadius: size * 0.18)
                .fill(skin.primaryColor)
                .frame(width: size * 0.66, height: size * 0.56)
                .offset(y: size * 0.10)
            RoundedRectangle(cornerRadius: size * 0.16)
                .fill(Color.white)
                .frame(width: size * 0.54, height: size * 0.40)
                .offset(y: -size * 0.12)
            TriangleShape()
                .fill(skin.accentColor)
                .frame(width: size * 0.20, height: size * 0.16)
                .rotationEffect(.degrees(180))
                .offset(y: size * 0.04)
            eyePair(color: Color(hex: "0F172A"), yOffset: -size * 0.14)
        }
    }

    private var hammerIcon: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 4)
                .fill(Color(hex: "78350F"))
                .frame(width: size * 0.16, height: size * 0.64)
                .offset(y: size * 0.14)
            RoundedRectangle(cornerRadius: size * 0.12)
                .fill(skin.primaryColor)
                .frame(width: size * 0.72, height: size * 0.42)
                .overlay(RoundedRectangle(cornerRadius: size * 0.12).stroke(skin.secondaryColor, lineWidth: 2))
                .offset(y: -size * 0.12)
        }
    }

    private var flagCubeIcon: some View {
        ZStack {
            RoundedRectangle(cornerRadius: size * 0.18)
                .fill(skin.primaryColor)
                .frame(width: size * 0.68, height: size * 0.68)
                .overlay(
                    HStack(spacing: 0) {
                        skin.primaryColor
                        skin.accentColor
                        skin.secondaryColor
                    }
                    .clipShape(RoundedRectangle(cornerRadius: size * 0.18))
                )
                .overlay(RoundedRectangle(cornerRadius: size * 0.18).stroke(Color.black.opacity(0.6), lineWidth: 1.5))

            if let code = skin.flagCode {
                Text(flagEmoji(for: code))
                    .font(.system(size: size * 0.42))
            }
        }
    }

    private var pumpkinIcon: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 3)
                .fill(Color(hex: "16A34A"))
                .frame(width: size * 0.14, height: size * 0.20)
                .offset(y: -size * 0.34)
            RoundedRectangle(cornerRadius: size * 0.22)
                .fill(skin.primaryColor)
                .frame(width: size * 0.70, height: size * 0.62)
                .overlay(RoundedRectangle(cornerRadius: size * 0.22).stroke(skin.secondaryColor, lineWidth: 2))
            HStack(spacing: size * 0.14) {
                TriangleShape().fill(skin.accentColor).frame(width: size * 0.14, height: size * 0.14)
                TriangleShape().fill(skin.accentColor).frame(width: size * 0.14, height: size * 0.14)
            }
            .offset(y: -size * 0.04)
        }
    }

    private var santaIcon: some View {
        ZStack {
            RoundedRectangle(cornerRadius: size * 0.18)
                .fill(skin.primaryColor)
                .frame(width: size * 0.66, height: size * 0.64)
                .overlay(RoundedRectangle(cornerRadius: size * 0.18).stroke(Color.black.opacity(0.55), lineWidth: 1.5))
            RoundedRectangle(cornerRadius: size * 0.10)
                .fill(Color.white)
                .frame(width: size * 0.56, height: size * 0.24)
                .offset(y: size * 0.18)
            eyePair(color: Color(hex: "1E293B"), yOffset: -size * 0.08)
        }
    }

    private var snowmanIcon: some View {
        ZStack {
            RoundedRectangle(cornerRadius: size * 0.22)
                .fill(skin.primaryColor)
                .frame(width: size * 0.66, height: size * 0.66)
                .overlay(RoundedRectangle(cornerRadius: size * 0.22).stroke(skin.secondaryColor, lineWidth: 1.8))
            // Carrot nose
            TriangleShape()
                .fill(skin.accentColor)
                .frame(width: size * 0.14, height: size * 0.16)
                .rotationEffect(.degrees(90))
                .offset(x: size * 0.06, y: size * 0.04)
            eyePair(color: Color(hex: "0F172A"), yOffset: -size * 0.10)
        }
    }

    private var genericCubeCharacterIcon: some View {
        ZStack {
            // Top glossy bevel cube
            RoundedRectangle(cornerRadius: size * 0.20, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [skin.primaryColor, skin.secondaryColor],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: size * 0.68, height: size * 0.68)
                .overlay(
                    RoundedRectangle(cornerRadius: size * 0.20, style: .continuous)
                        .stroke(Color.white.opacity(0.65), lineWidth: 1.8)
                )
                .shadow(color: Color.black.opacity(0.22), radius: 3, y: 2)

            // Cute cartoon eyes
            HStack(spacing: size * 0.08) {
                Circle()
                    .fill(Color.white)
                    .frame(width: size * 0.20, height: size * 0.20)
                    .overlay(Circle().fill(Color(hex: "0F172A")).frame(width: size * 0.10, height: size * 0.10))
                Circle()
                    .fill(Color.white)
                    .frame(width: size * 0.20, height: size * 0.20)
                    .overlay(Circle().fill(Color(hex: "0F172A")).frame(width: size * 0.10, height: size * 0.10))
            }
            .offset(y: -size * 0.02)

            if skin.blueprint == .heroCrown || skin.blueprint == .objectCrown {
                Image(systemName: "crown.fill")
                    .font(.system(size: size * 0.24))
                    .foregroundColor(Color(hex: "FDE047"))
                    .offset(y: -size * 0.40)
            }
        }
    }

    private func eyePair(color: Color, pupil: Color? = nil, yOffset: CGFloat) -> some View {
        HStack(spacing: size * 0.12) {
            Circle().fill(color).frame(width: size * 0.13, height: size * 0.13)
                .overlay(Group {
                    if let pupil = pupil {
                        Circle().fill(pupil).frame(width: size * 0.07, height: size * 0.07)
                    }
                })
            Circle().fill(color).frame(width: size * 0.13, height: size * 0.13)
                .overlay(Group {
                    if let pupil = pupil {
                        Circle().fill(pupil).frame(width: size * 0.07, height: size * 0.07)
                    }
                })
        }
        .offset(y: yOffset)
    }

    private func flagEmoji(for code: String) -> String {
        let base: UInt32 = 127397
        var result = ""
        for scalar in code.uppercased().unicodeScalars {
            if let v = UnicodeScalar(base + scalar.value) {
                result.unicodeScalars.append(v)
            }
        }
        return result.isEmpty ? "🏳️" : result
    }
}

private struct TriangleShape: Shape {
    func path(in rect: CGRect) -> Path {
        var p = Path()
        p.move(to: CGPoint(x: rect.midX, y: rect.minY))
        p.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        p.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        p.closeSubpath()
        return p
    }
}
