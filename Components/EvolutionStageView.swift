import SwiftUI

struct EvolutionStageView: View {
    let ingredients: [EvolutionIngredient]
    let resultGlyph: String
    let resultMeaning: String
    let spatial: SpatialRule
    var centerPoint: CGPoint? = nil
    let onAnimationComplete: () -> Void

    @State private var phaseTrigger = 0

    var body: some View {
        GeometryReader { geo in
            stage(for: 0, size: geo.size)
                .phaseAnimator([0, 1, 2], trigger: phaseTrigger) { _, phase in
                    stage(for: phase, size: geo.size)
                } animation: { phase in
                    switch phase {
                    case 0:
                        return GameState.MotionContract.fastEase
                    case 1:
                        return GameState.MotionContract.successSpring
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
            Color.black.opacity(0.20)
                .ignoresSafeArea()

            ZStack {
                ForEach(Array(ingredients.enumerated()), id: \.offset) { index, ingredient in
                    Text(ingredient.icon)
                        .font(.system(size: 62, weight: .regular, design: .serif))
                        .position(ingredientPosition(index: index, in: size))
                        .opacity(phase < 2 ? 1 : 0)
                        .scaleEffect(phase == 0 ? 1 : 0.82)
                }

                Text(resultGlyph)
                    .font(.system(size: 120, weight: .regular, design: .serif))
                    .foregroundStyle(.primary)
                    .position(baseCenter(in: size))
                    .opacity(phase == 0 ? 0 : (phase == 1 ? 0.32 : 1))
                    .scaleEffect(phase == 0 ? 0.72 : (phase == 1 ? 0.9 : 1.08))
                    .contentTransition(.opacity)

                if phase == 2 {
                    Text(resultMeaning)
                        .font(.title3.weight(.medium))
                        .padding(.horizontal, 18)
                        .padding(.vertical, 10)
                        .background(Color.white.opacity(0.85), in: Capsule(style: .continuous))
                        .position(x: baseCenter(in: size).x, y: baseCenter(in: size).y + 104)
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
