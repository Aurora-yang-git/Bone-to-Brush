import SwiftUI

struct OracleToModernMorphView: View {
    let oracleStrokes: [OracleStroke]
    let modernGlyph: String
    let meaning: String
    let canvasSize: CGSize
    var onMorphComplete: (() -> Void)? = nil

    @State private var phase = 0
    @ScaledMetric(relativeTo: .largeTitle) private var glyphSize: CGFloat = 120

    var body: some View {
        ZStack {
            if phase < 3 {
                OracleStrokeView(
                    strokes: oracleStrokes,
                    canvasSize: canvasSize,
                    mode: .full,
                    progress: 1.0
                )
                .scaleEffect(phase == 0 ? 1.0 : (phase == 1 ? 0.7 : 0.3))
                .opacity(phase == 0 ? 1.0 : (phase == 1 ? 0.7 : 0.0))
            }

            Circle()
                .fill(
                    RadialGradient(
                        colors: [Color.orange.opacity(0.4), Color.clear],
                        center: .center,
                        startRadius: 4,
                        endRadius: 140
                    )
                )
                .frame(width: phase >= 2 ? 280 : 0, height: phase >= 2 ? 280 : 0)
                .opacity(phase == 2 ? 1 : (phase == 3 ? 0.2 : 0))
                .blendMode(.screen)

            Text(modernGlyph)
                .font(.system(size: glyphSize, weight: .regular, design: .serif))
                .foregroundStyle(.primary)
                .scaleEffect(phase < 2 ? 0.5 : (phase == 2 ? 1.08 : 1.0))
                .opacity(phase < 2 ? 0 : 1)

            if phase >= 3 {
                Text(meaning)
                    .font(.title3.weight(.medium))
                    .padding(.horizontal, 18)
                    .padding(.vertical, 10)
                    .background(Color.white.opacity(0.85), in: Capsule(style: .continuous))
                    .offset(y: glyphSize * 0.6 + 20)
                    .transition(.opacity.combined(with: .offset(y: 12)))
            }
        }
        .frame(width: canvasSize.width, height: canvasSize.height)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Character morph: oracle script becomes \(modernGlyph), meaning \(meaning)")
        .task {
            try? await Task.sleep(for: .milliseconds(200))
            withAnimation(.easeInOut(duration: 0.6)) { phase = 1 }
            try? await Task.sleep(for: .milliseconds(650))
            withAnimation(.spring(response: 0.5, dampingFraction: 0.75)) { phase = 2 }
            try? await Task.sleep(for: .milliseconds(600))
            withAnimation(.easeOut(duration: 0.5)) { phase = 3 }
            try? await Task.sleep(for: .milliseconds(550))
            onMorphComplete?()
        }
    }
}
