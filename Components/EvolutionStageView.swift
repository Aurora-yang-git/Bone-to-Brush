import SwiftUI

struct EvolutionStageView: View {
    let ingredients: [EvolutionIngredient]
    let resultGlyph: String
    let resultMeaning: String
    let spatial: SpatialRule
    var centerPoint: CGPoint? = nil
    let onAnimationComplete: () -> Void

    @State private var phaseTrigger = 0
    @ScaledMetric(relativeTo: .title) private var ingredientGlyphSize: CGFloat = 62
    @ScaledMetric(relativeTo: .largeTitle) private var resultGlyphSize: CGFloat = 120
    @ScaledMetric(relativeTo: .title3) private var meaningOffsetY: CGFloat = 104

    var body: some View {
        GeometryReader { geo in
            stage(for: 0, size: geo.size)
                .phaseAnimator([0, 1, 2, 3], trigger: phaseTrigger) { _, phase in
                    stage(for: phase, size: geo.size)
                } animation: { phase in
                    switch phase {
                    case 0:
                        return GameState.MotionContract.fastEase
                    case 1:
                        return GameState.MotionContract.successSpring
                    case 2:
                        return GameState.MotionContract.fastEase
                    default:
                        return GameState.MotionContract.microEase
                    }
                }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Evolution animation, result \(resultGlyph)")
        .task {
            phaseTrigger += 1
            try? await Task.sleep(for: GameState.MotionContract.evolutionStageDuration)
            onAnimationComplete()
        }
    }

    private func stage(for phase: Int, size: CGSize) -> some View {
        ZStack {
            Color.black.opacity(0.16)
                .ignoresSafeArea()

            ZStack {
                let center = baseCenter(in: size)

                if phase >= 2 {
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [Color.white.opacity(0.30), Color.clear],
                                center: .center,
                                startRadius: 8,
                                endRadius: 170
                            )
                        )
                        .frame(width: phase == 2 ? 210 : 270, height: phase == 2 ? 210 : 270)
                        .position(center)
                        .opacity(phase == 2 ? 1 : 0.45)
                        .blendMode(.screen)

                    Circle()
                        .strokeBorder(Color.white.opacity(0.42), lineWidth: 2)
                        .frame(width: phase == 2 ? 120 : 220, height: phase == 2 ? 120 : 220)
                        .position(center)
                        .opacity(phase == 2 ? 0.9 : 0.1)
                        .blendMode(.screen)
                }

                ForEach(Array(ingredients.enumerated()), id: \.offset) { index, ingredient in
                    Text(ingredient.icon)
                        .font(.system(size: ingredientGlyphSize, weight: .regular, design: .serif))
                        .position(ingredientPosition(index: index, in: size))
                        .opacity(phase == 3 ? 0 : (phase == 2 ? 0.25 : 1))
                        .scaleEffect(phase == 0 ? 1 : (phase == 1 ? 0.86 : 0.72))
                }

                Text(resultGlyph)
                    .font(.system(size: resultGlyphSize, weight: .regular, design: .serif))
                    .foregroundStyle(.primary)
                    .position(center)
                    .opacity(
                        phase == 0 ? 0
                            : (phase == 1 ? 0.24
                                : (phase == 2 ? 0.70 : 1))
                    )
                    .scaleEffect(
                        phase == 0 ? 0.70
                            : (phase == 1 ? 0.88
                                : (phase == 2 ? 0.98 : 1.06))
                    )
                    .contentTransition(.opacity)

                if phase == 3 {
                    Text(resultMeaning)
                        .font(.title3.weight(.medium))
                        .padding(.horizontal, 18)
                        .padding(.vertical, 10)
                        .background(Color.white.opacity(0.85), in: Capsule(style: .continuous))
                        .position(x: center.x, y: center.y + meaningOffsetY)
                        .transition(.opacity.combined(with: .scale))
                }
            }
        }
    }

    private func baseCenter(in size: CGSize) -> CGPoint {
        if let centerPoint {
            return centerPoint
        }
        return CGPoint(x: size.width * 0.5, y: size.height * 0.5)
    }

    private func ingredientPosition(index: Int, in size: CGSize) -> CGPoint {
        let center = baseCenter(in: size)
        if ingredients.count == 2 {
            switch spatial {
            case .leftRight:
                return CGPoint(x: center.x + (index == 0 ? -72 : 72), y: center.y)
            case .topBottom, .stacked:
                return CGPoint(x: center.x, y: center.y + (index == 0 ? -72 : 72))
            case .any:
                return CGPoint(x: center.x + (index == 0 ? -60 : 60), y: center.y)
            }
        }

        if ingredients.count == 3 {
            switch index {
            case 0:
                return CGPoint(x: center.x, y: center.y - 82)
            case 1:
                return CGPoint(x: center.x - 68, y: center.y + 48)
            default:
                return CGPoint(x: center.x + 68, y: center.y + 48)
            }
        }

        let radius: CGFloat = 82
        let angle = (Double(index) / Double(max(ingredients.count, 1))) * .pi * 2
        return CGPoint(
            x: center.x + CGFloat(cos(angle)) * radius,
            y: center.y + CGFloat(sin(angle)) * radius
        )
    }
}
