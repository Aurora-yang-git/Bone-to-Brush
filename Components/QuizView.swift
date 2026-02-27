import Observation
import SwiftUI

struct QuizView: View {
    @Environment(\.colorSchemeContrast) private var colorSchemeContrast
    @Bindable var gameState: GameState
    let level: WebLevel
    @ScaledMetric(relativeTo: .title2) private var quizTitleSize: CGFloat = 34
    @ScaledMetric(relativeTo: .title) private var optionGlyphSize: CGFloat = 44
    @ScaledMetric(relativeTo: .body) private var optionTileSide: CGFloat = 128
    @ScaledMetric(relativeTo: .body) private var optionRowExtra: CGFloat = 14
    @ScaledMetric(relativeTo: .body) private var optionStatusIconSize: CGFloat = 20
    @State private var continueEnabled = false

    private var optionRows: [GridItem] {
        [GridItem(.fixed(optionTileSide + optionRowExtra))]
    }

    var body: some View {
        guard let quiz = level.quiz else {
            return AnyView(EmptyView())
        }
        let scriptMode = gameState.scriptDisplayMode

        return AnyView(
            ZStack {
                VStack(spacing: 20) {
                    Text(level.displayTitle(mode: scriptMode))
                        .font(.system(size: quizTitleSize, weight: .regular, design: .serif))
                        .tracking(0.8)
                        .accessibilityAddTraits(.isHeader)
                    Text(quiz.displayQuestion(mode: scriptMode))
                        .font(.title3)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: 680)

                    ScrollView(.horizontal, showsIndicators: false) {
                        LazyHGrid(rows: optionRows, spacing: 22) {
                            ForEach(quiz.options) { option in
                                Button {
                                    gameState.chooseQuizOption(option.id)
                                } label: {
                                    ZStack(alignment: .topTrailing) {
                                        VStack(spacing: 8) {
                                            Text(option.displayIcon(mode: scriptMode))
                                                .font(.system(size: optionGlyphSize, weight: .regular, design: .serif))
                                                .foregroundStyle(.primary)
                                            Text(option.displayLabel(mode: scriptMode))
                                                .font(.caption)
                                                .foregroundStyle(.secondary)
                                        }
                                        .frame(width: optionTileSide, height: optionTileSide)
                                        .background(
                                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                                .fill(backgroundColor(for: option))
                                        )
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                                .strokeBorder(borderColor(for: option), lineWidth: borderWidth())
                                        )

                                        if gameState.quizSelectedOptionID == option.id {
                                            Image(systemName: option.isCorrect ? "checkmark.circle.fill" : "xmark.circle.fill")
                                                .font(.system(size: optionStatusIconSize, weight: .bold))
                                                .foregroundStyle(option.isCorrect ? Color.green : Color.red)
                                                .symbolEffect(.bounce, value: gameState.quizSelectedOptionID)
                                                .padding(8)
                                                .accessibilityHidden(true)
                                        }
                                    }
                                }
                                .buttonStyle(.bordered)
                                .tint(.clear)
                                .disabled(gameState.quizAnswered)
                                .scaleEffect(gameState.quizSelectedOptionID == option.id ? 1.06 : 1.0)
                                .animation(GameState.MotionContract.standardSpring, value: gameState.quizSelectedOptionID)
                                .accessibilityLabel("\(option.displayLabel(mode: scriptMode)), glyph \(option.displayIcon(mode: scriptMode))")
                                .accessibilityValue(accessibilityValue(for: option))
                                .accessibilityHint(gameState.quizAnswered ? "Selection locked" : "Select this option")
                                .accessibilityAddTraits(gameState.quizSelectedOptionID == option.id ? .isSelected : [])
                                .frame(minWidth: 44, minHeight: 44)
                            }
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                    }
                    .frame(maxWidth: 760)

                    Spacer()
                }
                .padding(.top, 60)

                if gameState.quizShowExplanation {
                    VStack {
                        Spacer()
                        VStack(spacing: 10) {
                            Text(gameState.quizFeedback)
                                .font(.body.weight(.medium))
                                .foregroundStyle(.white)
                                .padding(.horizontal, 26)
                                .padding(.vertical, 12)
                                .background(Color(.label), in: Capsule(style: .continuous))
                                .shadow(color: .black.opacity(0.22), radius: 10, x: 0, y: 4)
                                .contentTransition(.opacity)

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
                        .padding(.bottom, 72)
                        .transition(.opacity.combined(with: .move(edge: .bottom)))
                    }
                }
            }
            .padding(.horizontal, 24)
            .sensoryFeedback(.success, trigger: gameState.quizShowExplanation)
            .sensoryFeedback(.error, trigger: gameState.quizAnswered && !gameState.quizWasCorrect)
            .onChange(of: level.id) { _, _ in
                continueEnabled = false
            }
            .onChange(of: gameState.quizShowExplanation) { _, newValue in
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
        )
    }

    private func backgroundColor(for option: LevelOption) -> Color {
        let increased = colorSchemeContrast == .increased
        guard gameState.quizSelectedOptionID == option.id else {
            return .white.opacity(increased ? 0.88 : 0.72)
        }
        return option.isCorrect
            ? Color.green.opacity(increased ? 0.20 : 0.14)
            : Color.red.opacity(increased ? 0.20 : 0.14)
    }

    private func borderColor(for option: LevelOption) -> Color {
        let increased = colorSchemeContrast == .increased
        guard gameState.quizSelectedOptionID == option.id else {
            return increased ? Color.primary.opacity(0.45) : Color.secondary.opacity(0.22)
        }
        return option.isCorrect
            ? Color.green.opacity(increased ? 0.85 : 0.65)
            : Color.red.opacity(increased ? 0.85 : 0.62)
    }

    private func borderWidth() -> CGFloat {
        colorSchemeContrast == .increased ? 3 : 2
    }

    private func accessibilityValue(for option: LevelOption) -> String {
        guard gameState.quizSelectedOptionID == option.id else { return "" }
        guard gameState.quizAnswered else { return "Selected" }
        return option.isCorrect ? "Selected. Correct." : "Selected. Incorrect."
    }
}
