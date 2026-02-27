import Observation
import SwiftUI

struct TracingView: View {
    @Environment(\.accessibilityVoiceOverEnabled) private var voiceOverEnabled
    @Bindable var gameState: GameState
    let level: WebLevel
    @Namespace private var statusNamespace
    @State private var confirmFeedbackToken = 0
    @State private var continueEnabled = false
    @ScaledMetric(relativeTo: .title2) private var traceTitleLarge: CGFloat = 36
    @ScaledMetric(relativeTo: .title2) private var traceTitleSmall: CGFloat = 30
    @ScaledMetric(relativeTo: .title2) private var traceCharacterOffset: CGFloat = 8
    @ScaledMetric(relativeTo: .title3) private var traceHintIconSize: CGFloat = 28
    @ScaledMetric(relativeTo: .body) private var traceCompletionBadgeSize: CGFloat = 20

    var body: some View {
        let voiceOverModeEnabled = voiceOverEnabled || gameState.a11yPreviewVoiceOverEnabled
        Group {
            if let tracing = level.tracing {
                GeometryReader { geo in
                    let canvasSide = adaptiveCanvasSide(in: geo.size)
                    let containerSide = canvasSide + 40
                    let titleFont: CGFloat = canvasSide >= 360 ? traceTitleLarge : traceTitleSmall
                    let displayCharacter = tracing.displayCharacter(mode: gameState.scriptDisplayMode)
                    let displayMeaning = tracing.displayMeaning(mode: gameState.scriptDisplayMode)
                    let displayExplanation = tracing.displayExplanation(mode: gameState.scriptDisplayMode)
                    let displayImage = tracing.displayImageAsset(mode: gameState.scriptDisplayMode)
                    let canvasOverlayGlyph = gameState.scriptDisplayMode == .oraclePreferred ? "" : tracing.character

                    ZStack(alignment: .center) {
                        Color(red: 0.94, green: 0.92, blue: 0.88)
                            .ignoresSafeArea()
                            .overlay {
                                // Keep tracing illustration visual-only; it must not affect container layout width.
                                Image(displayImage)
                                    .resizable()
                                    .scaledToFill()
                                    .opacity(gameState.traceCompleted ? 1 : 0.40)
                                    .ignoresSafeArea()
                                    .animation(GameState.MotionContract.traceRevealEase, value: gameState.traceCompleted)
                                    .accessibilityLabel("Pictograph illustration: \(displayMeaning)")
                                    .accessibilityAddTraits(.isImage)
                            }

                        VStack(spacing: 16) {
                            VStack(spacing: 6) {
                                Text(displayCharacter)
                                    .font(.system(size: titleFont + traceCharacterOffset, weight: .regular, design: .serif))
                                    .foregroundStyle(.primary)
                                Text(displayMeaning)
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            }
                                .font(.system(size: titleFont, weight: .regular, design: .serif))
                                .tracking(1.2)
                                .shadow(color: .black.opacity(0.10), radius: 8, x: 0, y: 3)

                            ZStack {
                                RoundedRectangle(cornerRadius: 26, style: .continuous)
                                    .fill(Color.white.opacity(0.62))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 26, style: .continuous)
                                            .strokeBorder(Color.white.opacity(0.50), lineWidth: 1)
                                    )

                                TraceCanvasView(
                                    guide: tracing.guide,
                                    targetGlyph: canvasOverlayGlyph,
                                    voiceOverModeEnabled: voiceOverModeEnabled,
                                    resetKey: level.id,
                                    progress: gameState.traceProgress,
                                    canvasSize: CGSize(width: canvasSide, height: canvasSide),
                                    onTraceChanged: { points, didEnd in
                                        gameState.updateTrace(points: points, didEnd: didEnd, guide: tracing.guide)
                                    }
                                )
                                .frame(width: canvasSide, height: canvasSide)
                                .clipped()
                                .overlay(alignment: .bottomTrailing) {
                                    if !voiceOverModeEnabled, gameState.traceProgress < 0.01 && !gameState.traceCompleted {
                                        Image(systemName: "pencil")
                                            .font(.system(size: traceHintIconSize, weight: .medium))
                                            .rotationEffect(.degrees(-45))
                                            .offset(x: 10, y: 10)
                                            .opacity(0.55)
                                            .padding(24)
                                            .accessibilityLabel("Tracing hint")
                                            .accessibilityHint("Start tracing from the beginning of the stroke")
                                    }
                                }
                            }
                            .frame(width: containerSide, height: containerSide)
                            .shadow(color: .black.opacity(0.18), radius: 18, x: 0, y: 8)

                            if gameState.traceCompleted {
                                VStack(spacing: 10) {
                                    Label(displayExplanation, systemImage: "checkmark.seal.fill")
                                        .font(.system(size: traceCompletionBadgeSize, weight: .regular, design: .serif))
                                        .foregroundStyle(.primary)
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 9)
                                        .background(Color.white.opacity(0.82), in: Capsule(style: .continuous))
                                        .accessibilityHint("Tracing is complete for this level")

                                    Button {
                                        gameState.advanceLevel()
                                    } label: {
                                        Label("Continue", systemImage: "arrow.right.circle.fill")
                                            .font(.headline)
                                    }
                                    .buttonStyle(.borderedProminent)
                                    .disabled(!continueEnabled)
                                    .opacity(continueEnabled ? 1 : 0.52)
                                }
                                .matchedGeometryEffect(id: "trace-status", in: statusNamespace)
                                .transition(.opacity.combined(with: .scale))
                            } else {
                                VStack(spacing: 10) {
                                    ProgressView(value: Double(gameState.traceProgress), total: 1.0)
                                        .progressViewStyle(.linear)
                                        .tint(.primary)
                                        .frame(width: min(canvasSide + 36, 480))
                                        .accessibilityLabel("Tracing progress")
                                        .accessibilityValue("\(Int(gameState.traceProgress * 100)) percent")

                                    HStack(spacing: 8) {
                                        Text("\(Int(gameState.traceProgress * 100))%")
                                            .font(.callout.monospacedDigit())
                                            .contentTransition(.numericText(value: Double(gameState.traceProgress * 100)))
                                        Text("Trace the strokes, then confirm")
                                            .font(.caption)
                                            .foregroundStyle(.secondary)
                                    }

                                    ControlGroup {
                                        Button {
                                            gameState.clearTrace()
                                        } label: {
                                            Label("Clear", systemImage: "arrow.counterclockwise")
                                        }
                                        .accessibilityHint("Clear the current trace")

                                        Button {
                                            confirmFeedbackToken += 1
                                            gameState.confirmTrace()
                                        } label: {
                                            Label("Confirm", systemImage: "checkmark")
                                        }
                                        .disabled(gameState.traceProgress <= 0.01)
                                        .accessibilityHint("Submit tracing result")
                                    }
                                    .controlGroupStyle(.navigation)
                                }
                                .padding(.horizontal, 14)
                                .padding(.vertical, 12)
                                .background(Color.white.opacity(0.78), in: RoundedRectangle(cornerRadius: 18, style: .continuous))
                                .matchedGeometryEffect(id: "trace-status", in: statusNamespace)
                            }
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 28)
                    }
                    .frame(width: geo.size.width, height: geo.size.height, alignment: .center)
                    .clipped()
                }
            } else {
                EmptyView()
            }
        }
        .sensoryFeedback(.success, trigger: gameState.traceCompleted)
        .sensoryFeedback(.impact(weight: .light), trigger: confirmFeedbackToken)
        .onChange(of: level.id) { _, _ in
            continueEnabled = false
        }
        .onChange(of: gameState.traceCompleted) { _, newValue in
            if newValue {
                continueEnabled = false
                Task { @MainActor in
                    try? await Task.sleep(for: .seconds(level.wowPauseSeconds))
                    continueEnabled = true
                }
            } else {
                continueEnabled = false
            }
        }
    }

    private func adaptiveCanvasSide(in size: CGSize) -> CGFloat {
        let maxSide: CGFloat = 400
        let minSide: CGFloat = 260
        let byWidth = size.width - 80
        let byHeight = size.height - 240
        return max(min(min(byWidth, byHeight), maxSide), minSide)
    }
}
