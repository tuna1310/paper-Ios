import SwiftUI

/// Procedural Paper.io 2-style square avatar preview for any `SkinDefinition`.
struct SkinAvatarView: View {
    let skin: SkinDefinition
    var size: CGFloat = 56

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: size * 0.22)
                .fill(Color(hex: skin.palette.darkHex))
                .frame(width: size, height: size)
                .offset(y: size * 0.08)

            RoundedRectangle(cornerRadius: size * 0.22)
                .fill(Color(hex: skin.palette.baseHex))
                .frame(width: size, height: size)
                .overlay(patternOverlay)
                .overlay(
                    RoundedRectangle(cornerRadius: size * 0.22)
                        .stroke(Color.white.opacity(0.65), lineWidth: max(1.5, size * 0.04))
                )

            eyesOverlay
            topAccessoryOverlay
        }
        .frame(width: size * 1.15, height: size * 1.25)
    }

    @ViewBuilder
    private var patternOverlay: some View {
        switch skin.pattern {
        case .stripes:
            HStack(spacing: size * 0.14) {
                Rectangle().fill(Color(hex: skin.accentHex).opacity(0.45)).frame(width: size * 0.14)
                Rectangle().fill(Color(hex: skin.accentHex).opacity(0.45)).frame(width: size * 0.14)
            }
            .clipShape(RoundedRectangle(cornerRadius: size * 0.22))
        case .checker:
            VStack(spacing: 0) {
                HStack(spacing: 0) {
                    Color(hex: skin.accentHex).opacity(0.32)
                    Color.clear
                }
                HStack(spacing: 0) {
                    Color.clear
                    Color(hex: skin.accentHex).opacity(0.32)
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: size * 0.22))
        case .star:
            Image(systemName: "star.fill")
                .font(.system(size: size * 0.36, weight: .bold))
                .foregroundColor(Color(hex: skin.accentHex).opacity(0.42))
                .offset(y: size * 0.16)
        case .visor:
            Capsule()
                .fill(Color(hex: skin.accentHex).opacity(0.85))
                .frame(width: size * 0.72, height: size * 0.22)
                .offset(y: -size * 0.08)
        case .solid, .crown, .horns, .halo:
            EmptyView()
        }
    }

    private var eyesOverlay: some View {
        HStack(spacing: size * 0.16) {
            eyeDot
            eyeDot
        }
        .offset(y: -size * 0.08)
    }

    private var eyeDot: some View {
        ZStack {
            Capsule()
                .fill(Color.white)
                .frame(width: size * 0.18, height: size * 0.24)
            Circle()
                .fill(Color(hex: 0x0F_17_2A))
                .frame(width: size * 0.10, height: size * 0.10)
        }
    }

    @ViewBuilder
    private var topAccessoryOverlay: some View {
        switch skin.pattern {
        case .crown:
            Image(systemName: "crown.fill")
                .font(.system(size: size * 0.34, weight: .bold))
                .foregroundColor(Color(hex: skin.accentHex))
                .offset(y: -size * 0.54)
        case .halo:
            Ellipse()
                .stroke(Color(hex: skin.accentHex), lineWidth: max(2, size * 0.07))
                .frame(width: size * 0.68, height: size * 0.20)
                .offset(y: -size * 0.56)
        case .horns:
            HStack(spacing: size * 0.42) {
                Image(systemName: "triangle.fill")
                    .font(.system(size: size * 0.22))
                    .foregroundColor(Color(hex: skin.accentHex))
                Image(systemName: "triangle.fill")
                    .font(.system(size: size * 0.22))
                    .foregroundColor(Color(hex: skin.accentHex))
            }
            .offset(y: -size * 0.50)
        case .solid, .stripes, .checker, .star, .visor:
            EmptyView()
        }
    }
}

/// Procedural native SwiftUI country flag badge (zero external bitmap files).
struct CountryFlagBadgeView: View {
    let style: CountryFlagStyle
    var width: CGFloat = 46
    var height: CGFloat = 30

    var body: some View {
        ZStack {
            switch style.pattern {
            case .horizontalTricolor:
                VStack(spacing: 0) {
                    Color(hex: style.primaryHex)
                    Color(hex: style.secondaryHex)
                    Color(hex: style.accentHex)
                }
            case .verticalTricolor:
                HStack(spacing: 0) {
                    Color(hex: style.primaryHex)
                    Color(hex: style.secondaryHex)
                    Color(hex: style.accentHex)
                }
            case .circleCenter:
                ZStack {
                    Color(hex: style.primaryHex)
                    Circle()
                        .fill(Color(hex: style.accentHex))
                        .frame(width: height * 0.54, height: height * 0.54)
                }
            case .cross:
                ZStack {
                    Color(hex: style.primaryHex)
                    Rectangle().fill(Color(hex: style.accentHex)).frame(height: height * 0.24)
                    Rectangle().fill(Color(hex: style.accentHex)).frame(width: height * 0.24)
                }
            case .canton:
                ZStack(alignment: .topLeading) {
                    VStack(spacing: 0) {
                        Color(hex: style.primaryHex)
                        Color(hex: style.secondaryHex)
                    }
                    Color(hex: style.accentHex)
                        .frame(width: width * 0.46, height: height * 0.54)
                }
            case .diagonal:
                ZStack {
                    Color(hex: style.primaryHex)
                    Rectangle()
                        .fill(Color(hex: style.accentHex))
                        .frame(width: width * 1.4, height: height * 0.28)
                        .rotationEffect(.degrees(-25))
                }
            }
        }
        .frame(width: width, height: height)
        .clipShape(RoundedRectangle(cornerRadius: 6))
        .overlay(
            RoundedRectangle(cornerRadius: 6)
                .stroke(Color.white.opacity(0.8), lineWidth: 1.5)
        )
    }
}

/// Top-bar pill displaying Gold or Diamonds with clear contrast.
struct CurrencyPillView: View {
    let iconName: String
    let iconHex: UInt32
    let amount: Int

    var body: some View {
        HStack(spacing: 5) {
            Image(systemName: iconName)
                .font(.system(size: 13, weight: .bold))
                .foregroundColor(Color(hex: iconHex))
            Text("\(amount)")
                .font(.system(size: 13, weight: .black, design: .rounded))
                .foregroundColor(.white)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(Capsule().fill(Color(hex: 0x0F_17_2A).opacity(0.75)))
        .overlay(Capsule().stroke(Color.white.opacity(0.35), lineWidth: 1.2))
    }
}

/// Compact metallic badge for any of the 10 Rank Tiers.
struct RankBadgeView: View {
    let tier: RankTier
    var compact: Bool = true

    var body: some View {
        HStack(spacing: 5) {
            Image(systemName: tier.symbolName)
                .font(.system(size: compact ? 13 : 18, weight: .bold))
                .foregroundColor(.white)
            Text(tier.displayName)
                .font(.system(size: compact ? 12 : 16, weight: .black, design: .rounded))
                .foregroundColor(.white)
        }
        .padding(.horizontal, compact ? 10 : 16)
        .padding(.vertical, compact ? 5 : 8)
        .background(
            Capsule().fill(
                LinearGradient(
                    colors: [Color(hex: tier.primaryHex), Color(hex: tier.secondaryHex)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
        )
        .overlay(Capsule().stroke(Color.white.opacity(0.75), lineWidth: 1.5))
    }
}
