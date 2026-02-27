import SwiftUI

struct TraceCanvasView: View {
    @Environment(\.accessibilityVoiceOverEnabled) private var voiceOverEnabled
    let guide: TraceGuide
    let targetGlyph: String
    let voiceOverModeEnabled: Bool
    let resetKey: Int
    let progress: CGFloat
    var showsGuide: Bool = true
    var canvasSize: CGSize = CGSize(width: 400, height: 400)
    let onTraceChanged: (_ points: [CGPoint], _ didEnd: Bool) -> Void

    @State private var userStrokes: [[CGPoint]] = []
    @State private var isDrawing = false
    @State private var a11yPointCount = 0
    @ScaledMetric(relativeTo: .largeTitle) private var overlayGlyphSize: CGFloat = 190

    var body: some View {
        let isVoiceOverMode = voiceOverEnabled || voiceOverModeEnabled
        let content = ZStack {
            if !targetGlyph.isEmpty {
                Text(targetGlyph)
                    .font(.system(size: overlayGlyphSize, weight: .regular, design: .serif))
                    .foregroundStyle(.secondary.opacity(max(0.06, 0.14 - progress * 0.08)))
                    .contentTransition(.opacity)
                    .accessibilityHidden(true)
            }

            Canvas { context, size in
                if showsGuide {
                    drawGuide(in: &context, size: size)
                }
                drawUserStrokes(in: &context, size: size)
            }
        }
        .contentShape(Rectangle())
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Tracing canvas")
        .accessibilityHint(
            isVoiceOverMode
                ? "Swipe up or down to adjust tracing progress. Then use the Confirm button to continue."
                : "Use your finger or stylus to trace along the guide strokes"
        )
        .accessibilityValue("\(Int(progress * 100)) percent complete")

        return Group {
            if isVoiceOverMode {
                content
                    .accessibilityAdjustableAction { direction in
                        switch direction {
                        case .increment:
                            advanceA11yProgress(direction: 1)
                        case .decrement:
                            advanceA11yProgress(direction: -1)
                        @unknown default:
                            break
                        }
                    }
                    .overlay(alignment: .bottomTrailing) {
                        Button {
                            setA11yPointCount(guidePointCount)
                        } label: {
                            Label("Auto trace", systemImage: "wand.and.stars")
                                .labelStyle(.iconOnly)
                                .font(.title3.weight(.semibold))
                                .frame(width: 44, height: 44)
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(.primary.opacity(0.12))
                        .foregroundStyle(.primary)
                        .accessibilityLabel("Auto trace")
                        .accessibilityHint("Fill the tracing progress without drawing gestures")
                        .padding(12)
                    }
            } else {
                content
                    .gesture(traceGesture(in: canvasSize))
            }
        }
        .onChange(of: targetGlyph) { _, _ in
            userStrokes = []
            isDrawing = false
            a11yPointCount = 0
        }
        .onChange(of: resetKey) { _, _ in
            userStrokes = []
            isDrawing = false
            a11yPointCount = 0
        }
        .onAppear {
            userStrokes = []
            isDrawing = false
            a11yPointCount = 0
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

    private var guidePointCount: Int {
        guide.strokes.reduce(into: 0) { count, stroke in
            count += stroke.points.count
        }
    }

    private func advanceA11yProgress(direction: Int) {
        let step = max(1, guidePointCount / 12)
        setA11yPointCount(a11yPointCount + step * direction)
    }

    private func setA11yPointCount(_ newValue: Int) {
        let clamped = min(max(newValue, 0), guidePointCount)
        a11yPointCount = clamped
        userStrokes = a11yStrokes(for: clamped)
        isDrawing = false
        onTraceChanged(flattenedPoints, false)
    }

    private func a11yStrokes(for pointCount: Int) -> [[CGPoint]] {
        guard pointCount > 0 else { return [] }
        var remaining = pointCount
        var result: [[CGPoint]] = []

        for stroke in guide.strokes {
            guard remaining > 0 else { break }
            let take = min(remaining, stroke.points.count)
            if take > 0 {
                result.append(Array(stroke.points.prefix(take)))
            }
            remaining -= take
        }
        return result
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
        guard showsGuide else { return }
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
