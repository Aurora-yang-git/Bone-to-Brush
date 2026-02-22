import Observation
import SwiftUI

struct IntroView: View {
    @Bindable var gameState: GameState
    @State private var revealTrigger = 0
    @State private var startFeedbackToken = 0

    var body: some View {
        VStack(spacing: 28) {
            Spacer()

            VStack(spacing: 14) {
                Text("Oracle Script")
                    .font(.system(size: 72, weight: .bold, design: .serif))
                    .foregroundStyle(Color(.label))
                    .kerning(1.2)
                    .contentTransition(.opacity)
                Text("Follow the shapes of the world to see where writing begins.")
                    .font(.title3.weight(.light))
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: 520)
            }
            .padding(.horizontal, 24)
            .phaseAnimator([0, 1], trigger: revealTrigger) { content, phase in
                content
                    .opacity(phase == 0 ? 0 : 1)
                    .offset(y: phase == 0 ? 24 : 0)
            } animation: { _ in
                GameState.MotionContract.introTitleRevealEase
            }

            Button {
                startFeedbackToken += 1
                gameState.startJourney()
            } label: {
                ZStack {
                    Circle()
                        .fill(Color.orange.opacity(0.18))
                        .frame(width: 160, height: 160)
                        .blur(radius: 28)
                        .phaseAnimator([0, 1], trigger: revealTrigger) { content, phase in
                            content
                                .scaleEffect(phase == 0 ? 0.65 : 1)
                                .opacity(phase == 0 ? 0 : 1)
                        } animation: { _ in
                            GameState.MotionContract.introHaloRevealEase
                        }
                    Label("Start Journey", systemImage: "arrow.right")
                        .font(.title3.weight(.semibold))
                        .padding(.horizontal, 28)
                        .padding(.vertical, 14)
                        .background(
                            Capsule(style: .continuous).fill(Color(.label))
                        )
                        .foregroundStyle(Color(red: 0.99, green: 0.98, blue: 0.96))
                        .symbolEffect(.bounce, value: startFeedbackToken)
                        .contentTransition(.opacity)
                }
            }
            .buttonStyle(.plain)
            .phaseAnimator([0, 1], trigger: revealTrigger) { content, phase in
                content
                    .scaleEffect(phase == 0 ? 0.92 : 1)
                    .opacity(phase == 0 ? 0 : 1)
            } animation: { _ in
                GameState.MotionContract.introButtonRevealEase
            }
            .accessibilityLabel("Start journey")
            .accessibilityHint("Enter the oracle script interactive flow")
            .frame(minWidth: 44, minHeight: 44)

            Spacer()

            Text("Oracle Script Interactive Exploration")
                .font(.footnote)
                .foregroundStyle(.tertiary)
                .padding(.bottom, 26)
                .phaseAnimator([0, 1], trigger: revealTrigger) { content, phase in
                    content
                        .opacity(phase == 0 ? 0 : 1)
                        .offset(y: phase == 0 ? 6 : 0)
                } animation: { _ in
                    GameState.MotionContract.introFooterRevealEase
                }
        }
        .padding(24)
        .sensoryFeedback(.impact(weight: .light), trigger: startFeedbackToken)
        .task {
            revealTrigger += 1
        }
    }
}
