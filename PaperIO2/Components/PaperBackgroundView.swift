import SwiftUI

/// Iconic Paper.io sky-blue background gradient with subtle infinity-cube watermarks.
struct PaperBackgroundView: View {
    var topColor: Color = Color(hex: "3AC2FF")
    var bottomColor: Color = Color(hex: "0E82EC")
    var showPerspectiveFloor: Bool = false

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [topColor, bottomColor],
                startPoint: .top,
                endPoint: .bottom
            )

            // Subtle diagonal ∞ cube watermarks seen across menus
            Canvas { context, size in
                let cols = Int(size.width / 110) + 2
                let rows = Int(size.height / 110) + 2
                for row in 0..<rows {
                    for col in 0..<cols {
                        let offsetX = CGFloat(col) * 115 + (row.isMultiple(of: 2) ? 0 : 56) - 20
                        let offsetY = CGFloat(row) * 110 - 20
                        drawInfinityMark(context: context, center: CGPoint(x: offsetX, y: offsetY))
                    }
                }
            }
            .opacity(0.11)

            if showPerspectiveFloor {
                PerspectiveGridFloor()
                    .frame(height: 360)
                    .frame(maxHeight: .infinity, alignment: .bottom)
            }
        }
        .ignoresSafeArea()
    }

    private func drawInfinityMark(context: GraphicsContext, center: CGPoint) {
        var ctx = context
        ctx.translateBy(x: center.x, y: center.y)
        ctx.rotate(by: .degrees(-18))

        let leftLoop = RoundedRectangle(cornerRadius: 8)
            .path(in: CGRect(x: -24, y: -11, width: 22, height: 22))
        let rightLoop = RoundedRectangle(cornerRadius: 8)
            .path(in: CGRect(x: 2, y: -11, width: 22, height: 22))

        let style = StrokeStyle(lineWidth: 5, lineCap: .round, lineJoin: .round)
        ctx.stroke(leftLoop, with: .color(.white), style: style)
        ctx.stroke(rightLoop, with: .color(.white), style: style)
    }
}

/// Perspective cyan grid floor matching the 3D Skin Showcase screen.
private struct PerspectiveGridFloor: View {
    var body: some View {
        Canvas { context, size in
            let horizonY: CGFloat = 0
            let centerX = size.width * 0.5
            let lineColor = Color.white.opacity(0.28)

            let rect = CGRect(origin: .zero, size: size)
            context.fill(
                Path(rect),
                with: .linearGradient(
                    Gradient(colors: [Color(hex: "2BAEFF").opacity(0.2), Color(hex: "0872D8").opacity(0.85)]),
                    startPoint: CGPoint(x: 0, y: 0),
                    endPoint: CGPoint(x: 0, y: size.height)
                )
            )

            // Converging perspective rays
            for i in -8...8 {
                var p = Path()
                p.move(to: CGPoint(x: centerX + CGFloat(i) * 42, y: horizonY))
                p.addLine(to: CGPoint(x: centerX + CGFloat(i) * 140, y: size.height))
                context.stroke(p, with: .color(lineColor), lineWidth: 1.5)
            }

            // Horizontal depth lines
            let rows = 8
            for r in 0...rows {
                let t = CGFloat(r) / CGFloat(rows)
                let y = pow(t, 1.55) * size.height
                var p = Path()
                p.move(to: CGPoint(x: 0, y: y))
                p.addLine(to: CGPoint(x: size.width, y: y))
                context.stroke(p, with: .color(lineColor), lineWidth: 1.5)
            }
        }
        .allowsHitTesting(false)
    }
}
