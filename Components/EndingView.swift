import Observation
import SwiftUI

struct EndingView: View {
    @Bindable var gameState: GameState
    @State private var revealTrigger = 0
    @State private var restartFeedbackToken = 0
    @ScaledMetric(relativeTo: .largeTitle) private var endingTitleSize: CGFloat = 52
    @ScaledMetric(relativeTo: .title2) private var showcaseGlyphSize: CGFloat = 38

    private let showcaseGlyphs = ["\u{4F11}", "\u{4ECE}", "\u{4F17}", "\u{660E}", "\u{8A00}", "\u{4FE1}"]

    var body: some View {
        ZStack {
            Color(red: 0.11, green: 0.10, blue: 0.09)
                .ignoresSafeArea()

            VStack(spacing: 24) {
                Spacer()

                VStack(spacing: 12) {
                    Text("You Made Meaning")
                        .font(.system(size: endingTitleSize, weight: .bold, design: .serif))
                        .multilineTextAlignment(.center)
                        .foregroundStyle(Color(red: 0.98, green: 0.95, blue: 0.88))
                        .contentTransition(.opacity)
                        .accessibilityAddTraits(.isHeader)
                    Text("You started by watching. Then tracing. Then drawing from memory. Then choosing, dragging, guessing, and finally creating your own characters. You just replayed a small piece of how civilization wrote the world down.")
                        .font(.title3.weight(.light))
                        .foregroundStyle(Color.white.opacity(0.72))
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: 680)
                }
                .phaseAnimator([0, 1], trigger: revealTrigger) { content, phase in
                    content
                        .opacity(phase == 0 ? 0 : 1)
                        .scaleEffect(phase == 0 ? 0.92 : 1)
                } animation: { _ in
                    GameState.MotionContract.endingTitleRevealEase
                }

                LazyVGrid(columns: Array(repeating: GridItem(.flexible(minimum: 44)), count: 4), spacing: 14) {
                    ForEach(Array(showcaseGlyphs.enumerated()), id: \.offset) { index, glyph in
                        Text(glyph)
                            .font(.system(size: showcaseGlyphSize, weight: .regular, design: .serif))
                            .frame(maxWidth: .infinity, minHeight: 58)
                            .background(
                                RoundedRectangle(cornerRadius: 14, style: .continuous)
                                    .fill(Color.white.opacity(0.06))
                            )
                            .phaseAnimator([0, 1], trigger: revealTrigger) { content, phase in
                                content
                                    .opacity(phase == 0 ? 0 : 1)
                                    .offset(y: phase == 0 ? 8 : 0)
                            } animation: { _ in
                                GameState.MotionContract.endingGlyphRevealSpring
                                    .delay(Double(index) * 0.08)
                            }
                    }
                }
                .frame(maxWidth: 420)
                .padding(.top, 8)

                Button {
                    restartFeedbackToken += 1
                    gameState.restartJourney()
                } label: {
                    Label("Restart Journey", systemImage: "arrow.counterclockwise")
                        .font(.headline)
                        .padding(.horizontal, 22)
                        .padding(.vertical, 12)
                        .symbolEffect(.rotate.byLayer, value: restartFeedbackToken)
                }
                .buttonStyle(.bordered)
                .tint(Color.white.opacity(0.25))
                .foregroundStyle(.white)
                .accessibilityLabel("Restart journey")
                .accessibilityHint("Return to intro")
                .frame(minWidth: 44, minHeight: 44)
                .phaseAnimator([0, 1], trigger: revealTrigger) { content, phase in
                    content.opacity(phase == 0 ? 0 : 1)
                } animation: { _ in
                    GameState.MotionContract.endingButtonRevealEase
                }

                Spacer()
            }
        }
        .padding(28)
        .sensoryFeedback(.success, trigger: revealTrigger)
        .sensoryFeedback(.impact(weight: .medium), trigger: restartFeedbackToken)
        .task {
            revealTrigger += 1
        }
    }
}
