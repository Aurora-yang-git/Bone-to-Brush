import Observation
import SwiftUI

struct QuizView: View {
    @Bindable var gameState: GameState
    let level: WebLevel
    private let optionRows = [GridItem(.fixed(142))]

    var body: some View {
        guard let quiz = level.quiz else {
            return AnyView(EmptyView())
        }
        let scriptMode = gameState.scriptDisplayMode

        return AnyView(
            ZStack {
                VStack(spacing: 20) {
                    Text(level.displayTitle(mode: scriptMode))
                        .font(.system(size: 34, weight: .regular, design: .serif))
                        .tracking(0.8)
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
                                                .font(.system(size: 44, weight: .regular, design: .serif))
                                                .foregroundStyle(.primary)
                                            Text(option.displayLabel(mode: scriptMode))
                                                .font(.caption)
                                                .foregroundStyle(.secondary)
                                        }
                                        .frame(width: 128, height: 128)
                                        .background(
                                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                                .fill(backgroundColor(for: option))
                                        )
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                                .strokeBorder(borderColor(for: option), lineWidth: 2)
                                        )

                                        if gameState.quizSelectedOptionID == option.id {
                                            Image(systemName: option.isCorrect ? "checkmark.circle.fill" : "xmark.circle.fill")
                                                .font(.system(size: 20, weight: .bold))
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
                                .accessibilityHint("Select this option")
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
                        Text(gameState.quizFeedback)
                            .font(.body.weight(.medium))
                            .foregroundStyle(.white)
                            .padding(.horizontal, 26)
                            .padding(.vertical, 12)
                            .background(Color(.label), in: Capsule(style: .continuous))
                            .shadow(color: .black.opacity(0.22), radius: 10, x: 0, y: 4)
                            .contentTransition(.opacity)
                            .padding(.bottom, 72)
                            .transition(.opacity.combined(with: .move(edge: .bottom)))
                    }
                }
            }
            .padding(.horizontal, 24)
            .sensoryFeedback(.success, trigger: gameState.quizShowExplanation)
            .sensoryFeedback(.error, trigger: gameState.quizAnswered && !gameState.quizWasCorrect)
        )
    }

    private func backgroundColor(for option: LevelOption) -> Color {
        guard gameState.quizSelectedOptionID == option.id else {
            return .white.opacity(0.72)
        }
        return option.isCorrect ? Color.green.opacity(0.14) : Color.red.opacity(0.14)
    }

    private func borderColor(for option: LevelOption) -> Color {
        guard gameState.quizSelectedOptionID == option.id else {
            return Color.secondary.opacity(0.22)
        }
        return option.isCorrect ? Color.green.opacity(0.65) : Color.red.opacity(0.62)
    }
}
