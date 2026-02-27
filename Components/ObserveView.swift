import Observation
import SwiftUI

struct ObserveView: View {
    @Bindable var gameState: GameState
    let level: WebLevel

    @State private var phase = 0
    @State private var continueEnabled = false
    @State private var continueFeedbackToken = 0
    @ScaledMetric(relativeTo: .largeTitle) private var glyphSize: CGFloat = 130

    var body: some View {
        guard let observe = level.observe else {
            return AnyView(EmptyView())
        }

        return AnyView(
            VStack(spacing: 24) {
                Spacer(minLength: 20)

                VStack(spacing: 10) {
                    Text(level.displayTitle(mode: gameState.scriptDisplayMode))
                        .font(.system(.largeTitle, design: .serif, weight: .bold))
                        .accessibilityAddTraits(.isHeader)
                    Text(observe.instruction)
                        .font(.title3)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: 640)
                }

                ZStack {
                    Circle()
                        .fill(Color.orange.opacity(0.16))
                        .frame(width: 260, height: 260)
                        .blur(radius: 18)
                        .scaleEffect(phase == 0 ? 0.7 : 1)
                        .opacity(phase == 0 ? 0 : 1)

                    Image(systemName: observe.worldSymbol)
                        .font(.system(size: 70, weight: .regular))
                        .foregroundStyle(.orange.opacity(0.85))
                        .scaleEffect(phase == 0 ? 0.6 : 1.0)
                        .opacity(phase == 2 ? 0 : 1)
                        .animation(GameState.MotionContract.fastEase, value: phase)
                        .accessibilityHidden(true)

                    Text(observe.oracleGlyph)
                        .font(.system(size: glyphSize, weight: .regular, design: .serif))
                        .scaleEffect(phase < 1 ? 0.8 : 1.0)
                        .opacity(phase == 0 ? 0 : (phase == 1 ? 1 : 0.22))
                        .animation(GameState.MotionContract.standardSpring, value: phase)
                        .accessibilityHidden(true)

                    Text(observe.modernGlyph)
                        .font(.system(size: glyphSize, weight: .regular, design: .serif))
                        .opacity(phase < 2 ? 0 : 1)
                        .scaleEffect(phase < 2 ? 0.8 : 1.05)
                        .contentTransition(.opacity)
                        .accessibilityHidden(true)
                }
                .frame(width: 300, height: 300)
                .accessibilityElement(children: .ignore)
                .accessibilityLabel("Oracle to modern character transition")

                Text(observe.detail)
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: 680)
                    .padding(.horizontal, 18)

                Button {
                    continueFeedbackToken += 1
                    gameState.advanceLevel()
                } label: {
                    Label("Continue", systemImage: "arrow.right.circle.fill")
                        .font(.headline)
                        .padding(.horizontal, 22)
                        .padding(.vertical, 12)
                }
                .buttonStyle(.borderedProminent)
                .disabled(!continueEnabled)
                .opacity(continueEnabled ? 1 : 0.52)
                .padding(.top, 8)
                .accessibilityHint("Move to the next chapter")

                Spacer(minLength: 24)
            }
            .padding(.horizontal, 24)
            .task(id: level.id) {
                // #region agent log
                AgentRuntimeDebugLogger.log(
                    hypothesisID: "H4",
                    location: "ObserveView.swift:92",
                    message: "Observe task started",
                    data: [
                        "levelID": level.id,
                        "wowPauseSeconds": level.wowPauseSeconds,
                        "hasObserveData": level.observe != nil,
                    ]
                )
                // #endregion
                phase = 0
                continueEnabled = false
                withAnimation(GameState.MotionContract.fastEase) {
                    phase = 1
                }
                try? await Task.sleep(for: .milliseconds(360))
                withAnimation(GameState.MotionContract.successSpring) {
                    phase = 2
                }
                // #region agent log
                AgentRuntimeDebugLogger.log(
                    hypothesisID: "H4",
                    location: "ObserveView.swift:101",
                    message: "Observe reached morph phase 2",
                    data: [
                        "levelID": level.id,
                        "phase": phase,
                    ]
                )
                // #endregion
                try? await Task.sleep(for: .seconds(level.wowPauseSeconds))
                continueEnabled = true
                // #region agent log
                AgentRuntimeDebugLogger.log(
                    hypothesisID: "H4",
                    location: "ObserveView.swift:110",
                    message: "Observe continue enabled",
                    data: [
                        "levelID": level.id,
                        "continueEnabled": continueEnabled,
                    ]
                )
                // #endregion
            }
            .sensoryFeedback(.impact(weight: .light), trigger: continueFeedbackToken)
        )
    }
}
