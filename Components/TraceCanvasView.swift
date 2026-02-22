import SwiftUI

struct TraceCanvasView: View {
    let guide: TraceGuide
    let targetGlyph: String
    let resetKey: Int
    let progress: CGFloat
    var canvasSize: CGSize = CGSize(width: 400, height: 400)
    let onTraceChanged: (_ points: [CGPoint], _ didEnd: Bool) -> Void

    @State private var userStrokes: [[CGPoint]] = []
    @State private var isDrawing = false

    var body: some View {
        ZStack {
            if !targetGlyph.isEmpty {
                Text(targetGlyph)
                    .font(.system(size: 190, weight: .regular, design: .serif))
                    .foregroundStyle(.secondary.opacity(max(0.06, 0.14 - progress * 0.08)))
                    .contentTransition(.opacity)
                    .accessibilityHidden(true)
            }

            Canvas { context, size in
                drawGuide(in: &context, size: size)
                drawUserStrokes(in: &context, size: size)
            }
        }
        .contentShape(Rectangle())
        .gesture(traceGesture(in: canvasSize))
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Tracing canvas")
        .accessibilityHint("Use your finger or stylus to trace along the guide strokes")
        .accessibilityValue("\(Int(progress * 100)) percent complete")
        .onChange(of: targetGlyph) { _, _ in
            userStrokes = []
            isDrawing = false
        }
        .onChange(of: resetKey) { _, _ in
            userStrokes = []
            isDrawing = false
        }
        .onAppear {
            userStrokes = []
            isDrawing = false
        }
    }

    private func traceGesture(in size: CGSize) -> some Gesture {
        DragGesture(minimumDistance: 0)
            .onChanged { value in
                let point = normalizedPoint(value.location, size: size)
                if !isDrawing {
                    isDrawing = true
                    userStrokes.append([point])
                } else if !userStrokes.isEmpty {
                    userStrokes[userStrokes.count - 1].append(point)
                }
                onTraceChanged(flattenedPoints, false)
            }
            .onEnded { _ in
                isDrawing = false
                onTraceChanged(flattenedPoints, true)
            }
    }

    private var flattenedPoints: [CGPoint] {
        userStrokes.flatMap { $0 }
    }

    private func normalizedPoint(_ point: CGPoint, size: CGSize) -> CGPoint {
        guard size.width > 1, size.height > 1 else { return .zero }
        return CGPoint(
            x: min(max(point.x / size.width, 0), 1),
            y: min(max(point.y / size.height, 0), 1)
        )
    }

    private func denormalized(_ point: CGPoint, size: CGSize) -> CGPoint {
        CGPoint(x: point.x * size.width, y: point.y * size.height)
    }

    private func drawGuide(in context: inout GraphicsContext, size: CGSize) {
        for stroke in guide.strokes where stroke.points.count > 1 {
            var path = Path()
            path.addLines(stroke.points.map { denormalized($0, size: size) })
            context.stroke(
                path,
                with: .color(.secondary.opacity(0.26)),
                style: StrokeStyle(
                    lineWidth: 20,
                    lineCap: .round,
                    lineJoin: .round,
                    dash: [7, 8]
                )
            )
        }
    }

    private func drawUserStrokes(in context: inout GraphicsContext, size: CGSize) {
        for stroke in userStrokes where stroke.count > 1 {
            var path = Path()
            path.addLines(stroke.map { denormalized($0, size: size) })
            context.stroke(
                path,
                with: .color(.primary.opacity(0.92)),
                style: StrokeStyle(
                    lineWidth: 12,
                    lineCap: .round,
                    lineJoin: .round
                )
            )
        }
    }
}
