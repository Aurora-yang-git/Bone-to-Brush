import Observation
import SwiftUI

struct IntroView: View {
    @Bindable var gameState: GameState
    @State private var revealTrigger = 0
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
            .phaseAnimator([0, 1], trigger: revealTrigger) { content, phase in
                content
                    .opacity(phase == 0 ? 0 : 1)
                    .offset(y: phase == 0 ? 24 : 0)
            } animation: { _ in
                GameState.MotionContract.introTitleRevealEase
            }

            Button {
                startFeedbackToken += 1
                // #region agent log
                AgentRuntimeDebugLogger.log(
                    hypothesisID: "H1",
                    location: "IntroView.swift:37",
                    message: "Start button tapped",
                    data: [
                        "flowState": "\(gameState.flowState)",
                        "currentLevelIndex": gameState.currentLevelIndex,
                    ]
                )
                // #endregion
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
            .onAppear {
                // #region agent log
                AgentRuntimeDebugLogger.log(
                    hypothesisID: "H14",
                    location: "IntroView.swift:86",
                    message: "Start button appeared",
                    data: [
                        "flowState": "\(gameState.flowState)",
                        "revealTrigger": revealTrigger,
                    ]
                )
                // #endregion
            }

            Spacer()

            Text("A short journey from image to meaning")
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
        .onAppear {
            // #region agent log
            AgentRuntimeDebugLogger.log(
                hypothesisID: "H7",
                location: "IntroView.swift:92",
                message: "IntroView onAppear",
                data: [
                    "flowState": "\(gameState.flowState)",
                    "currentLevelIndex": gameState.currentLevelIndex,
                ]
            )
            // #endregion
        }
        .onDisappear {
            // #region agent log
            AgentRuntimeDebugLogger.log(
                hypothesisID: "H7",
                location: "IntroView.swift:104",
                message: "IntroView onDisappear",
                data: [
                    "flowState": "\(gameState.flowState)",
                    "currentLevelIndex": gameState.currentLevelIndex,
                ]
            )
            // #endregion
        }
        .task {
            // #region agent log
            AgentRuntimeDebugLogger.log(
                hypothesisID: "H7",
                location: "IntroView.swift:111",
                message: "Intro reveal task fired",
                data: [
                    "flowState": "\(gameState.flowState)",
                    "revealTriggerBefore": revealTrigger,
                ]
            )
            // #endregion
            revealTrigger += 1
            // #region agent log
            AgentRuntimeDebugLogger.log(
                hypothesisID: "H14",
                location: "IntroView.swift:152",
                message: "Intro revealTrigger incremented",
                data: [
                    "revealTriggerAfter": revealTrigger,
                    "flowState": "\(gameState.flowState)",
                ]
            )
            // #endregion
        }
        .onChange(of: revealTrigger) { _, newValue in
            // #region agent log
            AgentRuntimeDebugLogger.log(
                hypothesisID: "H14",
                location: "IntroView.swift:163",
                message: "revealTrigger changed",
                data: [
                    "newRevealTrigger": newValue,
                    "flowState": "\(gameState.flowState)",
                ]
            )
            // #endregion
        }
    }
}
