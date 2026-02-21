import SwiftUI

struct TraceCanvasView: View {
    let guide: TraceGuide
    let targetGlyph: String
    let resetKey: Int
    let progress: CGFloat
    let onTraceChanged: (_ points: [CGPoint], _ didEnd: Bool) -> Void
    let onClear: () -> Void

    @State private var userStrokes: [[CGPoint]] = []
    @State private var isDrawing = false

    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Text("Trace the character")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)

                Spacer()

                Text("\(Int(progress * 100))%")
                    .font(.caption.monospacedDigit())
                    .foregroundStyle(.secondary)
                    .accessibilityLabel("Tracing progress \(Int(progress * 100)) percent")
            }

            GeometryReader { geo in
                ZStack {
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .fill(Color(.tertiarySystemBackground))

                    if !targetGlyph.isEmpty {
                        Text(targetGlyph)
                            .font(.system(size: min(geo.size.width, geo.size.height) * 0.56, design: .serif))
                            .foregroundStyle(.secondary.opacity(0.16))
                            .accessibilityHidden(true)
                    }

                    Canvas { context, size in
                        drawGuide(in: &context, size: size)
                        drawUserStrokes(in: &context, size: size)
                    }
                }
                .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                .contentShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                .gesture(traceGesture(in: geo.size))
                .accessibilityElement(children: .ignore)
                .accessibilityLabel("Tracing canvas")
                .accessibilityHint("Use your finger or Pencil to trace the character shape")
            }
            .frame(height: 220)

            HStack {
                Spacer()
                Button {
                    userStrokes = []
                    onClear()
                } label: {
                    Label("Clear", systemImage: "arrow.counterclockwise")
                        .font(.subheadline.weight(.semibold))
                        .padding(.horizontal, 14)
                        .padding(.vertical, 10)
                }
                .buttonStyle(.bordered)
                .accessibilityLabel("Clear tracing")
                .accessibilityHint("Removes your strokes and lets you retry")
                .frame(minWidth: 44, minHeight: 44)
            }
        }
        .onChange(of: targetGlyph) { _, _ in
            // Ensure strokes do not leak into the next level's canvas.
            userStrokes = []
            isDrawing = false
        }
        .onChange(of: resetKey) { _, _ in
            // Extra guard: level switch always wipes previous traces.
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
                    lineWidth: 12,
                    lineCap: .round,
                    lineJoin: .round,
                    dash: [4, 6]
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
                    lineWidth: 10,
                    lineCap: .round,
                    lineJoin: .round
                )
            )
        }
    }
}
