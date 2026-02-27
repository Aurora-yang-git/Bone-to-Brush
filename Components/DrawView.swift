import Observation
import SwiftUI

struct DrawView: View {
    @Bindable var gameState: GameState
    let level: WebLevel

    @State private var referenceVisible = true
    @State private var resetKeySeed = 0
    @State private var drawProgress: CGFloat = 0
    @State private var confirmed = false
    @State private var continueEnabled = false
    @State private var continueFeedbackToken = 0
    @ScaledMetric(relativeTo: .title2) private var glyphSize: CGFloat = 84

    var body: some View {
        guard let draw = level.draw else {
            return AnyView(EmptyView())
        }

        return AnyView(
            VStack(spacing: 20) {
                VStack(spacing: 8) {
                    Text(level.displayTitle(mode: gameState.scriptDisplayMode))
                        .font(.system(.largeTitle, design: .serif, weight: .bold))
                        .accessibilityAddTraits(.isHeader)
                    Text(draw.displayInstruction(mode: gameState.scriptDisplayMode))
                        .font(.title3)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: 680)
                }
                .padding(.top, 22)

                ZStack {
                    if referenceVisible {
                        VStack(spacing: 8) {
                            Text(draw.displayCharacter(mode: gameState.scriptDisplayMode))
                                .font(.system(size: glyphSize, weight: .regular, design: .serif))
                            Text(draw.displayMeaning(mode: gameState.scriptDisplayMode))
                                .font(.headline)
                                .foregroundStyle(.secondary)
                        }
                        .padding(.horizontal, 26)
                        .padding(.vertical, 20)
                        .background(Color.white.opacity(0.82), in: RoundedRectangle(cornerRadius: 20, style: .continuous))
                        .transition(.opacity.combined(with: .scale))
                    } else {
                        TraceCanvasView(
                            guide: draw.guide,
                            targetGlyph: "",
                            voiceOverModeEnabled: gameState.a11yPreviewVoiceOverEnabled,
                            resetKey: level.id * 1000 + resetKeySeed,
                            progress: drawProgress,
                            showsGuide: false,
                            canvasSize: CGSize(width: 360, height: 360)
                        ) { points, _ in
                            let normalized = min(CGFloat(points.count) / 70, 1)
                            if normalized > drawProgress {
                                drawProgress = normalized
                            }
                        }
                        .frame(width: 360, height: 360)
                        .background(
                            RoundedRectangle(cornerRadius: 24, style: .continuous)
                                .fill(Color.white.opacity(0.72))
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 24, style: .continuous)
                                .strokeBorder(Color.secondary.opacity(0.18), lineWidth: 1)
                        )
                        .transition(.opacity)
                    }
                }
                .frame(height: 372)

                if confirmed {
                    VStack(spacing: 12) {
                        Label(draw.displayExplanation(mode: gameState.scriptDisplayMode), systemImage: "sparkles")
                            .font(.headline)
                            .foregroundStyle(.primary)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 10)
                            .background(Color.white.opacity(0.84), in: Capsule(style: .continuous))

                        Button {
                            continueFeedbackToken += 1
                            gameState.advanceLevel()
                        } label: {
                            Label("Continue", systemImage: "arrow.right.circle.fill")
                                .font(.headline)
                                .padding(.horizontal, 20)
                                .padding(.vertical, 11)
                        }
                        .buttonStyle(.borderedProminent)
                        .disabled(!continueEnabled)
                        .opacity(continueEnabled ? 1 : 0.5)
                    }
                    .transition(.opacity.combined(with: .scale))
                } else {
                    VStack(spacing: 10) {
                        ProgressView(value: drawProgress, total: 1)
                            .tint(.primary)
                            .frame(maxWidth: 360)
                        Text("Draw from memory, then confirm")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        ControlGroup {
                            Button("Clear") {
                                resetKeySeed += 1
                                drawProgress = 0
                            }
                            Button("Confirm") {
                                guard drawProgress > 0.2 else { return }
                                withAnimation(GameState.MotionContract.fastEase) {
                                    confirmed = true
                                }
                                Task {
                                    try? await Task.sleep(for: .seconds(level.wowPauseSeconds))
                                    continueEnabled = true
                                }
                            }
                            .disabled(drawProgress <= 0.2)
                        }
                        .controlGroupStyle(.navigation)
                    }
                }

                Spacer()
            }
            .padding(.horizontal, 20)
            .task(id: level.id) {
                drawProgress = 0
                confirmed = false
                continueEnabled = false
                referenceVisible = true
                try? await Task.sleep(for: .milliseconds(1200))
                withAnimation(GameState.MotionContract.fastEase) {
                    referenceVisible = false
                }
            }
            .sensoryFeedback(.impact(weight: .light), trigger: continueFeedbackToken)
        )
    }
}
