import Observation
import SwiftUI

struct IntroView: View {
    @Bindable var gameState: GameState
    @State private var didReveal = false
    @State private var startFeedbackToken = 0
    @ScaledMetric(relativeTo: .largeTitle) private var introTitleSize: CGFloat = 72

    var body: some View {
        VStack(spacing: 28) {
            Spacer()

            VStack(spacing: 14) {
                Text("Bone to Brush")
                    .font(.system(size: introTitleSize, weight: .bold, design: .serif))
                    .foregroundStyle(Color(.label))
                    .kerning(1.2)
                    .contentTransition(.opacity)
                    .accessibilityAddTraits(.isHeader)
                Text("3,000 years ago, writing began as pictures. Watch them. Draw them. Combine them. See how they became the characters used by a billion people today.")
                    .font(.title3.weight(.light))
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: 680)
            }
            .padding(.horizontal, 24)
            .opacity(didReveal ? 1 : 0.001)
            .offset(y: didReveal ? 0 : 24)
            .animation(GameState.MotionContract.introTitleRevealEase, value: didReveal)

            Button {
                startFeedbackToken += 1
                gameState.startJourney()
            } label: {
                ZStack {
                    Circle()
                        .fill(Color.orange.opacity(0.18))
                        .frame(width: 160, height: 160)
                        .scaleEffect(didReveal ? 1 : 0.72)
                        .opacity(didReveal ? 1 : 0.001)
                        .animation(GameState.MotionContract.introHaloRevealEase, value: didReveal)
                    Label("Begin 3-Minute Journey", systemImage: "arrow.right")
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
            .scaleEffect(didReveal ? 1 : 0.94)
            .opacity(didReveal ? 1 : 0.001)
            .animation(GameState.MotionContract.introButtonRevealEase, value: didReveal)
            .accessibilityLabel("Start journey")
            .accessibilityHint("Enter the oracle script interactive flow")
            .frame(minWidth: 44, minHeight: 44)

            Spacer()

            Text("A short journey from image to meaning")
                .font(.footnote)
                .foregroundStyle(.tertiary)
                .padding(.bottom, 26)
                .opacity(didReveal ? 1 : 0.001)
                .offset(y: didReveal ? 0 : 6)
                .animation(GameState.MotionContract.introFooterRevealEase, value: didReveal)
        }
        .padding(24)
        .sensoryFeedback(.impact(weight: .light), trigger: startFeedbackToken)
        .task {
            didReveal = true
        }
    }
}
