import Observation
import SwiftUI

struct DragLevelView: View {
    @Environment(\.accessibilityVoiceOverEnabled) private var voiceOverEnabled
    @Bindable var gameState: GameState
    let level: WebLevel
    
    private var a11yVoiceOverModeEnabled: Bool {
        voiceOverEnabled || gameState.a11yPreviewVoiceOverEnabled
    }

    @State private var slotItems: [String?] = [nil, nil]
    @State private var feedback: String?
    @State private var evolvingIngredients: [EvolutionIngredient] = []
    @State private var showEvolution = false
    @State private var solved = false
    @State private var continueEnabled = false
    @State private var errorOffset: CGFloat = 0
    @State private var successFeedbackToken = 0
    @State private var errorFeedbackToken = 0

    var body: some View {
        guard let drag = level.drag else {
            return AnyView(EmptyView())
        }

        return AnyView(
            VStack(spacing: 18) {
                VStack(spacing: 8) {
                    Text(level.displayTitle(mode: gameState.scriptDisplayMode))
                        .font(.system(.largeTitle, design: .serif, weight: .bold))
                        .accessibilityAddTraits(.isHeader)
                    Text(drag.displayInstruction(mode: gameState.scriptDisplayMode))
                        .font(.title3)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                    Text("Target: \(drag.targetChar) · \(drag.displayTargetMeaning(mode: gameState.scriptDisplayMode))")
                        .font(.callout)
                        .foregroundStyle(.secondary)
                }
                .padding(.top, 24)

                HStack(spacing: 26) {
                    dropSlot(index: 0, token: tokenForSlot(index: 0, data: drag))
                    dropSlot(index: 1, token: tokenForSlot(index: 1, data: drag))
                }
                .offset(x: errorOffset)
                .animation(GameState.MotionContract.repelSpring, value: errorOffset)

                if let feedback {
                    Label(feedback, systemImage: solved ? "sparkles" : "exclamationmark.triangle.fill")
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 18)
                        .padding(.vertical, 10)
                        .background((solved ? Color.green : Color.orange).opacity(0.92), in: Capsule(style: .continuous))
                        .transition(.opacity.combined(with: .scale))
                }

                inventoryBar(data: drag)
                    .padding(.top, 4)

                HStack(spacing: 12) {
                    Button("Clear Slots") {
                        withAnimation(GameState.MotionContract.microEase) {
                            slotItems = [nil, nil]
                            feedback = nil
                        }
                    }
                    .buttonStyle(.bordered)
                    .disabled(solved)

                    if solved {
                        Button {
                            gameState.advanceLevel()
                        } label: {
                            Label("Continue", systemImage: "arrow.right.circle.fill")
                                .font(.headline)
                        }
                        .buttonStyle(.borderedProminent)
                        .disabled(!continueEnabled)
                        .opacity(continueEnabled ? 1 : 0.5)
                    }
                }
                .frame(minHeight: 44)

                Spacer()
            }
            .padding(.horizontal, 22)
            .overlay {
                if showEvolution {
                    EvolutionStageView(
                        ingredients: evolvingIngredients,
                        resultGlyph: drag.recipe.resultGlyph,
                        resultMeaning: drag.recipe.displayResultMeaning(mode: gameState.scriptDisplayMode),
                        spatial: drag.recipe.spatial
                    ) {
                        completeSuccess(with: drag)
                    }
                    .transition(.opacity)
                }
            }
            .onChange(of: slotItems) { _, _ in
                evaluate(drag)
            }
            .task(id: level.id) {
                slotItems = [nil, nil]
                feedback = nil
                evolvingIngredients = []
                showEvolution = false
                solved = false
                continueEnabled = false
            }
            .sensoryFeedback(.impact(weight: .medium), trigger: successFeedbackToken)
            .sensoryFeedback(.error, trigger: errorFeedbackToken)
        )
    }

    private func inventoryBar(data: DragLevelData) -> some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 14) {
                ForEach(data.baseInventory) { token in
                    let tile = VStack(spacing: 6) {
                        PieceTile(glyph: token.displayIcon(mode: gameState.scriptDisplayMode), pressed: false)
                            .frame(width: 80, height: 80)
                        Text(token.displayLabel(mode: gameState.scriptDisplayMode))
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }

                    if a11yVoiceOverModeEnabled {
                        Button {
                            placeTokenForA11y(tokenID: token.id)
                        } label: {
                            tile
                        }
                        .buttonStyle(.plain)
                    } else {
                        tile.draggable(token.id)
                    }
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
        }
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Draggable inventory")
    }

    private func dropSlot(index: Int, token: InventoryToken?) -> some View {
        RoundedRectangle(cornerRadius: 18, style: .continuous)
            .fill(Color.white.opacity(0.78))
            .overlay(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .strokeBorder(Color.secondary.opacity(0.24), style: StrokeStyle(lineWidth: 2, dash: [6, 5]))
            )
            .frame(width: 124, height: 124)
            .overlay {
                if let token {
                    PieceTile(glyph: token.displayIcon(mode: gameState.scriptDisplayMode), pressed: false)
                        .frame(width: 86, height: 86)
                } else {
                    Image(systemName: "plus")
                        .font(.title2.weight(.medium))
                        .foregroundStyle(.secondary.opacity(0.8))
                }
            }
            .dropDestination(for: String.self) { dropped, _ in
                guard !solved else { return false }
                guard let first = dropped.first else { return false }
                slotItems[index] = first
                return true
            }
            .accessibilityLabel("Drop slot \(index + 1)")
            .accessibilityValue(token?.displayLabel(mode: gameState.scriptDisplayMode) ?? "Empty")
    }

    private func tokenForSlot(index: Int, data: DragLevelData) -> InventoryToken? {
        guard let id = slotItems[index] else { return nil }
        return data.baseInventory.first(where: { $0.id == id })
    }

    private func placeTokenForA11y(tokenID: String) {
        guard !solved else { return }
        if let emptyIndex = slotItems.firstIndex(where: { $0 == nil }) {
            slotItems[emptyIndex] = tokenID
        }
    }

    private func evaluate(_ drag: DragLevelData) {
        guard !showEvolution else { return }
        guard !solved else { return }
        guard slotItems.allSatisfy({ $0 != nil }) else { return }
        let ids = slotItems.compactMap { $0 }
        let key = ids.sorted().joined(separator: "|")
        let recipeKey = drag.recipe.ingredients.sorted().joined(separator: "|")

        guard key == recipeKey else {
            feedback = "Invalid combination. Return and try again."
            errorFeedbackToken += 1
            withAnimation(GameState.MotionContract.repelSpring) {
                errorOffset = 12
            }
            Task { @MainActor in
                try? await Task.sleep(for: .milliseconds(120))
                errorOffset = -12
                try? await Task.sleep(for: .milliseconds(120))
                withAnimation(GameState.MotionContract.fastEase) {
                    errorOffset = 0
                    slotItems = [nil, nil]
                }
            }
            return
        }

        evolvingIngredients = ids.compactMap { id in
            guard let token = drag.baseInventory.first(where: { $0.id == id }) else { return nil }
            return EvolutionIngredient(id: token.id, icon: token.displayIcon(mode: gameState.scriptDisplayMode))
        }
        showEvolution = true
        feedback = nil
    }

    private func completeSuccess(with drag: DragLevelData) {
        showEvolution = false
        solved = true
        feedback = "Formed \(drag.recipe.resultGlyph) · \(drag.recipe.resultMeaning)"
        successFeedbackToken += 1
        CreationFeedback.playMergeSound(audioEnabled: gameState.audioEnabled)
        Task { @MainActor in
            try? await Task.sleep(for: .seconds(level.wowPauseSeconds))
            continueEnabled = true
        }
    }
}
