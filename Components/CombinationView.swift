import Observation
import SwiftUI

struct CombinationView: View {
    @Bindable var gameState: GameState
    let level: WebLevel
    @State private var inventory: [InventoryToken] = []
    @State private var placedItems: [CanvasItem] = []
    @State private var feedback: String? = nil
    @State private var evolvingRecipe: CombinationRecipe? = nil
    @State private var evolvingIngredients: [EvolutionIngredient] = []
    @State private var showResultStatic = false
    @State private var staticResultGlyph = ""
    @State private var isDropTargeted = false
    @State private var feedbackKind: CombinationErrorKind? = nil
    @State private var successFeedbackToken = 0
    @State private var directionErrorFeedbackToken = 0
    @State private var invalidErrorFeedbackToken = 0

    var body: some View {
        guard let combination = level.combination else {
            return AnyView(EmptyView())
        }

        return AnyView(
            GeometryReader { geo in
                ZStack {
                    VStack(spacing: 4) {
                        Text(combination.displayInstruction(mode: gameState.scriptDisplayMode))
                            .font(.system(size: 30, weight: .regular, design: .serif))
                            .foregroundStyle(.primary.opacity(0.92))
                            .multilineTextAlignment(.center)
                        Text("Target: \(combination.targetChar) · \(combination.displayTargetMeaning(mode: gameState.scriptDisplayMode))")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.top, 16)
                    .frame(maxHeight: .infinity, alignment: .top)

                    centerZone
                        .frame(width: 350, height: 350)
                        .position(x: geo.size.width * 0.5, y: geo.size.height * 0.5)

                    HStack(alignment: .bottom) {
                        Spacer()
                        ControlGroup {
                            Button {
                                _ = placedItems.popLast()
                            } label: {
                                Label("Undo", systemImage: "arrow.uturn.backward")
                            }
                            .disabled(placedItems.isEmpty)

                            Button {
                                withAnimation(GameState.MotionContract.microEase) {
                                    placedItems = []
                                    feedback = nil
                                }
                            } label: {
                                Label("Clear", systemImage: "trash")
                            }
                            .disabled(placedItems.isEmpty)
                        }
                        .controlGroupStyle(.navigation)
                        .buttonStyle(.bordered)
                        .padding(.trailing, 18)
                    }
                    .padding(.bottom, 140)
                    .frame(maxHeight: .infinity, alignment: .bottom)

                    if let feedback {
                        VStack {
                            Spacer()
                            feedbackBadge(feedback)
                                .padding(.bottom, 140)
                        }
                        .transition(.opacity)
                    }

                    VStack {
                        Spacer()
                        inventoryBar
                    }

                    if let recipe = evolvingRecipe {
                        EvolutionStageView(
                            ingredients: evolvingIngredients,
                            resultGlyph: recipe.resultGlyph,
                            resultMeaning: recipe.displayResultMeaning(mode: gameState.scriptDisplayMode),
                            spatial: recipe.spatial
                        ) {
                            completeEvolution(recipe: recipe, targetGlyph: combination.targetChar)
                        }
                        .transition(.opacity)
                    }
                }
            }
            .onAppear {
                resetState(combination: combination)
            }
            .onChange(of: level.id) { _, _ in
                resetState(combination: combination)
            }
            .onChange(of: placedItems) { _, _ in
                evaluateCombinationRules(combination: combination)
            }
            .sensoryFeedback(.success, trigger: successFeedbackToken)
            .sensoryFeedback(.error, trigger: directionErrorFeedbackToken)
            .sensoryFeedback(.warning, trigger: invalidErrorFeedbackToken)
        )
    }

    private var centerZone: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 180, style: .continuous)
                .fill(Color.white.opacity(0.36))
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 180, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 180, style: .continuous)
                        .strokeBorder(
                            isDropTargeted ? Color.primary.opacity(0.42) : Color.secondary.opacity(0.24),
                            style: StrokeStyle(lineWidth: 4, dash: [8, 8])
                        )
                )

            if showResultStatic, !staticResultGlyph.isEmpty {
                VStack(spacing: 8) {
                    Text(staticResultGlyph)
                        .font(.system(size: 98, weight: .regular, design: .serif))
                    Text("Character Formed")
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(.secondary)
                }
                .accessibilityLabel("Result \(staticResultGlyph)")
            } else {
                if placedItems.isEmpty {
                    Text("Drag pieces here to form a character")
                        .font(.headline)
                        .foregroundStyle(.tertiary)
                } else {
                    ForEach(placedItems) { canvasItem in
                        PieceTile(glyph: canvasItem.item.displayIcon(mode: gameState.scriptDisplayMode), pressed: false)
                            .frame(width: 80, height: 80)
                            .position(canvasItem.position)
                            .opacity(canvasItem.status == .destroying || canvasItem.status == .returning ? 0 : 1)
                            .scaleEffect(canvasItem.status == .returning ? GameState.MotionContract.returningScale : 1.0)
                            .offset(
                                x: canvasItem.status == .repelling ? GameState.MotionContract.repelOffsetX : 0,
                                y: canvasItem.status == .returning ? GameState.MotionContract.returnOffsetY : 0
                            )
                            .animation(statusAnimation(for: canvasItem.status), value: canvasItem.status)
                            .accessibilityLabel("Placed \(canvasItem.item.displayLabel(mode: gameState.scriptDisplayMode))")
                    }
                }
            }
        }
        .dropDestination(for: String.self) { droppedIDs, location in
            guard evolvingRecipe == nil else { return false }
            for id in droppedIDs {
                if let token = inventory.first(where: { $0.id == id }) {
                    let clamped = clampedPoint(location)
                    placedItems.append(
                        CanvasItem(
                            uniqueID: UUID().uuidString,
                            item: token,
                            position: clamped
                        )
                    )
                }
            }
            return true
        } isTargeted: { targeted in
            withAnimation(GameState.MotionContract.microEase) {
                isDropTargeted = targeted
            }
        }
        .accessibilityLabel("Combination zone")
        .accessibilityHint("Drop pieces here. Combination happens automatically.")
    }

    private var inventoryBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 14) {
                ForEach(inventory) { token in
                    VStack(spacing: 6) {
                        PieceTile(glyph: token.displayIcon(mode: gameState.scriptDisplayMode), pressed: false)
                            .frame(width: 80, height: 80)
                        Text(token.displayLabel(mode: gameState.scriptDisplayMode))
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                    .draggable(token.id)
                    .accessibilityLabel("Inventory \(token.displayLabel(mode: gameState.scriptDisplayMode))")
                    .accessibilityHint("Drag this piece into center zone")
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
        }
        .frame(maxWidth: .infinity, minHeight: 128, maxHeight: 128)
        .background(.thinMaterial)
    }

    private func clampedPoint(_ point: CGPoint) -> CGPoint {
        CGPoint(
            x: min(max(point.x, 44), 306),
            y: min(max(point.y, 44), 306)
        )
    }

    private func evaluateCombinationRules(combination: CombinationLevelData) {
        guard evolvingRecipe == nil else { return }
        guard placedItems.count >= 2 else { return }
        guard placedItems.allSatisfy({ $0.status == .idle }) else { return }

        let ids = placedItems.map(\.item.id)

        if level.id == 14 && Set(ids) == Set(["ren", "mu", "yi"]) && ids.count == 3 {
            triggerReturnToCandidate(message: "Invalid combination: form the root piece first from tree + one.")
            return
        }

        if level.id == 11 && Set(ids) == Set(["ren", "kou"]) && !inventory.contains(where: { $0.id == "yan" }) {
            triggerReturnToCandidate(message: "Invalid combination: form speech first, then combine with person.")
            return
        }

        let idsKey = sortedKey(ids)
        let candidates = combination.recipes.filter { sortedKey($0.ingredients) == idsKey }

        if candidates.isEmpty {
            if let distractor = combination.distractors.first(where: { sortedKey($0.ingredients) == idsKey }) {
                triggerReturnToCandidate(message: "Invalid combination: \(distractor.message)")
            } else if placedItems.count > 3 {
                triggerReturnToCandidate(message: "Invalid combination: too many pieces on canvas.")
            } else {
                triggerReturnToCandidate(message: "Invalid combination: no matching character found.")
            }
            return
        }

        if let recipe = spatialMatchedRecipe(from: candidates) {
            startEvolution(recipe: recipe)
        } else {
            triggerDirectionMismatch(message: "Wrong direction: piece orientation does not match.")
        }
    }

    private func spatialMatchedRecipe(from candidates: [CombinationRecipe]) -> CombinationRecipe? {
        guard placedItems.count >= 2 else { return nil }
        let xs = placedItems.map(\.position.x)
        let ys = placedItems.map(\.position.y)
        let xSpan = (xs.max() ?? 0) - (xs.min() ?? 0)
        let ySpan = (ys.max() ?? 0) - (ys.min() ?? 0)
        let isHorizontal = xSpan >= ySpan

        for recipe in candidates {
            switch recipe.spatial {
            case .any:
                return recipe
            case .leftRight:
                if isHorizontal { return recipe }
            case .topBottom:
                if !isHorizontal {
                    if level.id == 13 {
                        let yi = placedItems.first(where: { $0.item.id == "yi" })
                        let mu = placedItems.first(where: { $0.item.id == "mu" })
                        if let yi, let mu {
                            if yi.position.y > mu.position.y && recipe.resultPieceID == "ben" {
                                return recipe
                            }
                            if yi.position.y < mu.position.y && recipe.resultPieceID == "mo" {
                                return recipe
                            }
                        }
                    } else {
                        return recipe
                    }
                }
            case .stacked:
                if placedItems.count == 3 {
                    // For stacked recipes, require a clearer vertical spread than horizontal.
                    if ySpan > xSpan * 0.9 { return recipe }
                } else if !isHorizontal {
                    return recipe
                }
            }
        }
        return nil
    }

    private func startEvolution(recipe: CombinationRecipe) {
        let sortedItems: [CanvasItem]
        switch recipe.spatial {
        case .leftRight:
            sortedItems = placedItems.sorted { $0.position.x < $1.position.x }
        case .topBottom, .stacked:
            sortedItems = placedItems.sorted { $0.position.y < $1.position.y }
        case .any:
            sortedItems = placedItems
        }

        evolvingRecipe = recipe
        evolvingIngredients = sortedItems.map { EvolutionIngredient(id: $0.item.id, icon: $0.item.icon) }
        withAnimation(GameState.MotionContract.microEase) {
            placedItems = []
        }
    }

    private func completeEvolution(recipe: CombinationRecipe, targetGlyph: String) {
        if !inventory.contains(where: { $0.id == recipe.resultPieceID }) {
            inventory.append(
                InventoryToken(
                    id: recipe.resultPieceID,
                    icon: recipe.resultGlyph,
                    label: recipe.resultMeaning,
                    oracleIcon: recipe.resultGlyph,
                    oracleLabel: recipe.displayResultMeaning(mode: gameState.scriptDisplayMode)
                )
            )
        }

        withAnimation(GameState.MotionContract.resultRevealEase) {
            staticResultGlyph = recipe.resultGlyph
            showResultStatic = true
            feedback = "Formed \(recipe.resultGlyph)"
            feedbackKind = nil
            evolvingRecipe = nil
            evolvingIngredients = []
        }
        successFeedbackToken += 1

        if recipe.resultGlyph == targetGlyph {
            gameState.scheduleAdvance(delaySeconds: GameState.MotionContract.combinationAdvanceDelaySeconds)
        } else {
            Task { @MainActor in
                try? await Task.sleep(for: GameState.MotionContract.secondaryResultHoldDelay)
                withAnimation(GameState.MotionContract.microEase) {
                    showResultStatic = false
                }
            }
        }
    }

    private func triggerDirectionMismatch(message: String) {
        feedback = message
        feedbackKind = .directionMismatch
        directionErrorFeedbackToken += 1
        withAnimation(GameState.MotionContract.repelSpring) {
            for index in placedItems.indices {
                placedItems[index].status = .repelling
            }
        }

        Task { @MainActor in
            try? await Task.sleep(for: GameState.MotionContract.repelClearDelay)
            withAnimation(GameState.MotionContract.microEase) {
                placedItems = []
            }
            try? await Task.sleep(for: GameState.MotionContract.feedbackClearDelay)
            if feedback == message {
                feedback = nil
                feedbackKind = nil
            }
        }
    }

    private func triggerReturnToCandidate(message: String) {
        feedback = message
        feedbackKind = .invalidCombination
        invalidErrorFeedbackToken += 1
        withAnimation(GameState.MotionContract.returnSpring) {
            for index in placedItems.indices {
                placedItems[index].status = .returning
            }
        }

        Task { @MainActor in
            try? await Task.sleep(for: GameState.MotionContract.returnClearDelay)
            withAnimation(GameState.MotionContract.microEase) {
                placedItems = []
            }
            try? await Task.sleep(for: GameState.MotionContract.feedbackClearDelay)
            if feedback == message {
                feedback = nil
                feedbackKind = nil
            }
        }
    }

    private func sortedKey(_ ids: [String]) -> String {
        ids.sorted().joined(separator: "|")
    }

    private func resetState(combination: CombinationLevelData) {
        inventory = combination.baseInventory
        placedItems = []
        feedback = nil
        feedbackKind = nil
        evolvingRecipe = nil
        evolvingIngredients = []
        showResultStatic = false
        staticResultGlyph = ""
    }

    private func statusAnimation(for status: CanvasItemStatus) -> Animation {
        switch status {
        case .repelling:
            return GameState.MotionContract.repelSpring
        case .returning:
            return GameState.MotionContract.returnSpring
        default:
            return GameState.MotionContract.microEase
        }
    }

    @ViewBuilder
    private func feedbackBadge(_ text: String) -> some View {
        let isDirection = feedbackKind == .directionMismatch
        Label(text, systemImage: isDirection ? "arrow.left.and.right.circle.fill" : "tray.and.arrow.down.fill")
            .font(.subheadline.weight(.medium))
            .foregroundStyle(.white)
            .padding(.horizontal, 20)
            .padding(.vertical, 10)
            .background(isDirection ? Color.orange.opacity(0.95) : Color.indigo.opacity(0.92), in: Capsule(style: .continuous))
            .shadow(color: .black.opacity(0.25), radius: 10, x: 0, y: 4)
            .contentTransition(.opacity)
    }
}
