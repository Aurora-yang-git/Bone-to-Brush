import SwiftUI

struct OracleStrokeView: View {
    let strokes: [OracleStroke]
    let canvasSize: CGSize
    var mode: Mode = .full
    var progress: CGFloat = 1.0

    enum Mode {
        case full
        case guide
        case reveal
    }

    var body: some View {
        ZStack {
            ForEach(Array(strokes.enumerated()), id: \.offset) { index, stroke in
                StrokePath(points: stroke.points, size: canvasSize)
                    .trim(from: 0, to: strokeProgress(for: index))
                    .stroke(
                        strokeStyle(for: stroke),
                        style: SwiftUI.StrokeStyle(
                            lineWidth: stroke.lineWidth,
                            lineCap: .round,
                            lineJoin: .round,
                            dash: mode == .guide ? [6, 8] : []
                        )
                    )
            }
        }
        .frame(width: canvasSize.width, height: canvasSize.height)
    }

    private func strokeProgress(for index: Int) -> CGFloat {
        guard !strokes.isEmpty else { return 0 }
        let count = CGFloat(strokes.count)
        let perStroke = 1.0 / count
        let strokeStart = CGFloat(index) * perStroke
        let local = (progress - strokeStart) / perStroke
        return min(max(local, 0), 1)
    }

    private func strokeStyle(for stroke: OracleStroke) -> some ShapeStyle {
        switch mode {
        case .guide:
            return AnyShapeStyle(Color.secondary.opacity(0.35))
        case .full, .reveal:
            return AnyShapeStyle(Color.primary.opacity(0.88))
        }
    }
}

private struct StrokePath: Shape {
    let points: [CGPoint]
    let size: CGSize

    func path(in rect: CGRect) -> Path {
        var path = Path()
        guard points.count >= 2 else {
            if let p = points.first {
                let pt = CGPoint(x: p.x * size.width, y: p.y * size.height)
                path.addEllipse(in: CGRect(x: pt.x - 2, y: pt.y - 2, width: 4, height: 4))
            }
            return path
        }

        let scaled = points.map { CGPoint(x: $0.x * size.width, y: $0.y * size.height) }

        if scaled.count == 2 {
            path.move(to: scaled[0])
            path.addLine(to: scaled[1])
            return path
        }

        path.move(to: scaled[0])
        for i in 1..<scaled.count {
            if i < scaled.count - 1 {
                let mid = CGPoint(
                    x: (scaled[i].x + scaled[i + 1].x) / 2,
                    y: (scaled[i].y + scaled[i + 1].y) / 2
                )
                path.addQuadCurve(to: mid, control: scaled[i])
            } else {
                path.addLine(to: scaled[i])
            }
        }
        return path
    }
}

struct AnimatedOracleStrokeView: View {
    let strokes: [OracleStroke]
    let canvasSize: CGSize
    let totalDuration: Double
    var onComplete: (() -> Void)? = nil

    @State private var drawProgress: CGFloat = 0

    var body: some View {
        OracleStrokeView(
            strokes: strokes,
            canvasSize: canvasSize,
            mode: .reveal,
            progress: drawProgress
        )
        .task {
            withAnimation(.easeInOut(duration: totalDuration)) {
                drawProgress = 1.0
            }
            try? await Task.sleep(for: .seconds(totalDuration + 0.1))
            onComplete?()
        }
    }
}
