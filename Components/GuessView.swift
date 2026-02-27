import Observation
import SwiftUI

struct GuessView: View {
    @Bindable var gameState: GameState
    let level: WebLevel

    @State private var showEvolution = true
    @State private var selectedOptionID: String?
    @State private var answeredCorrectly = false
    @State private var feedback = ""
    @State private var continueEnabled = false
    @State private var successFeedbackToken = 0
    @State private var errorFeedbackToken = 0

    var body: some View {
        guard let guess = level.guess else {
            return AnyView(EmptyView())
        }

        return AnyView(
            ZStack {
                VStack(spacing: 18) {
                    Text(level.displayTitle(mode: gameState.scriptDisplayMode))
                        .font(.system(.largeTitle, design: .serif, weight: .bold))
                        .padding(.top, 24)
                        .accessibilityAddTraits(.isHeader)

                    Text(guess.displayInstruction(mode: gameState.scriptDisplayMode))
                        .font(.title3)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: 640)

                    Text("Result: \(guess.resultGlyph)")
                        .font(.system(.largeTitle, design: .serif, weight: .regular))
                        .padding(.top, 6)
                        .accessibilityLabel("New character formed: \(guess.resultGlyph)")

                    LazyVGrid(columns: Array(repeating: GridItem(.flexible(minimum: 130), spacing: 12), count: 2), spacing: 12) {
                        ForEach(guess.options) { option in
                            let icon  = option.displayIcon(mode: gameState.scriptDisplayMode)
                            let label = option.displayLabel(mode: gameState.scriptDisplayMode)
                            let a11yValue: String = {
                                guard let sel = selectedOptionID, sel == option.id else { return "" }
                                return answeredCorrectly ? "Correct." : "Incorrect."
                            }()
                            Button {
                                choose(option: option, with: guess)
                            } label: {
                                VStack(spacing: 6) {
                                    Text(icon)
                                        .font(.system(size: 42, weight: .regular, design: .serif))
                                        .accessibilityHidden(true)
                                    Text(label)
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                                .frame(maxWidth: .infinity, minHeight: 110)
                                .background(tileBackground(for: option), in: RoundedRectangle(cornerRadius: 14, style: .continuous))
                            }
                            .buttonStyle(.plain)
                            .disabled(answeredCorrectly || showEvolution)
                            .accessibilityLabel("\(label), glyph \(icon)")
                            .accessibilityValue(a11yValue)
                            .accessibilityHint(answeredCorrectly || showEvolution ? "Selection locked" : "Select this meaning")
                            .accessibilityAddTraits(selectedOptionID == option.id ? .isSelected : [])
                        }
                    }
                    .frame(maxWidth: 520)
                    .opacity(showEvolution ? 0.5 : 1)
                    .animation(GameState.MotionContract.fastEase, value: showEvolution)

                    if !feedback.isEmpty {
                        Label(feedback, systemImage: answeredCorrectly ? "checkmark.seal.fill" : "xmark.circle.fill")
                            .font(.headline)
                            .foregroundStyle(.white)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 10)
                            .background((answeredCorrectly ? Color.green : Color.red).opacity(0.92), in: Capsule(style: .continuous))
                            .transition(.opacity)
                    }

                    if answeredCorrectly {
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

                    Spacer()
                }
                .padding(.horizontal, 20)

                if showEvolution {
                    EvolutionStageView(
                        ingredients: guess.ingredients,
                        resultGlyph: guess.resultGlyph,
                        resultMeaning: "New character",
                        spatial: .leftRight
                    ) {
                        showEvolution = false
                    }
                    .transition(.opacity)
                }
            }
            .task(id: level.id) {
                showEvolution = true
                selectedOptionID = nil
                answeredCorrectly = false
                feedback = ""
                continueEnabled = false
            }
            .sensoryFeedback(.success, trigger: successFeedbackToken)
            .sensoryFeedback(.error, trigger: errorFeedbackToken)
        )
    }

    private func choose(option: LevelOption, with guess: GuessLevelData) {
        selectedOptionID = option.id
        if option.isCorrect {
            answeredCorrectly = true
            feedback = guess.displayExplanation(mode: gameState.scriptDisplayMode)
            successFeedbackToken += 1
            Task { @MainActor in
                try? await Task.sleep(for: .seconds(level.wowPauseSeconds))
                continueEnabled = true
            }
        } else {
            feedback = "Not yet. Try another meaning."
            errorFeedbackToken += 1
            Task { @MainActor in
                try? await Task.sleep(for: .milliseconds(720))
                if !answeredCorrectly {
                    selectedOptionID = nil
                    feedback = ""
                }
            }
        }
    }

    private func tileBackground(for option: LevelOption) -> Color {
        if let selectedOptionID, selectedOptionID == option.id {
            return option.isCorrect ? Color.green.opacity(0.22) : Color.red.opacity(0.18)
        }
        return Color.white.opacity(0.72)
    }
}
