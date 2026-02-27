import Observation
import SwiftUI

struct FreeView: View {
    @Environment(\.accessibilityVoiceOverEnabled) private var voiceOverEnabled
    @Bindable var gameState: GameState
    let level: WebLevel
    @State private var baseInventory: [InventoryToken] = []
    @State private var createdInventory: [InventoryToken] = []
    @State private var itemsOnCanvas: [CanvasItem] = []
    @State private var feedback: String? = nil
    @State private var foundRecipes: [String] = []
    @State private var evolvingRecipe: CombinationRecipe? = nil
    @State private var evolvingIngredients: [EvolutionIngredient] = []
    @State private var evolutionCenter: CGPoint? = nil
    @State private var isDropTargeted = false
    @State private var feedbackKind: CombinationErrorKind? = nil
    @State private var successFeedbackToken = 0
    @State private var directionErrorFeedbackToken = 0
    @State private var invalidErrorFeedbackToken = 0
    @State private var finishEnabled = false
    @ScaledMetric(relativeTo: .title2) private var instructionFontSize: CGFloat = 30
    @ScaledMetric(relativeTo: .title3) private var discoveredGlyphSize: CGFloat = 26
    @State private var a11yPairLayout: A11yPairLayout = .horizontal
    @State private var a11ySwapOrder = false
    
    private var a11yVoiceOverModeEnabled: Bool {
        voiceOverEnabled || gameState.a11yPreviewVoiceOverEnabled
    }

    var body: some View {
        guard let free = level.free else {
            return AnyView(EmptyView())
        }

        return AnyView(
            GeometryReader { geo in
                ZStack {
                    VStack(spacing: 4) {
                        Text(free.displayInstruction(mode: gameState.scriptDisplayMode))
                            .font(.system(size: instructionFontSize, weight: .regular, design: .serif))
                            .multilineTextAlignment(.center)
                        Text("Wrong direction repels; invalid combos return to inventory")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.top, 16)
                    .frame(maxHeight: .infinity, alignment: .top)

                    centerZone
                        .frame(width: 350, height: 350)
                        .position(x: geo.size.width * 0.5, y: geo.size.height * 0.5)

                    HStack {
                        Spacer()
                        if a11yVoiceOverModeEnabled {
                            a11yPlacementControls
                        }
                        ControlGroup {
                            Button {
                                _ = itemsOnCanvas.popLast()
                            } label: {
                                Label("Undo", systemImage: "arrow.uturn.backward")
                            }
                            .disabled(itemsOnCanvas.isEmpty)

                            Button {
                                withAnimation(GameState.MotionContract.microEase) {
                                    itemsOnCanvas = []
                                }
                            } label: {
                                Label("Clear", systemImage: "trash")
                            }
                            .disabled(itemsOnCanvas.isEmpty)
                        }
                        .controlGroupStyle(.navigation)
                        .buttonStyle(.bordered)
                        .padding(.trailing, 18)
                    }
                    .padding(.bottom, 188)
                    .frame(maxHeight: .infinity, alignment: .bottom)

                    if let feedback {
                        VStack {
                            Spacer()
                            feedbackBadge(feedback)
                                .padding(.bottom, 194)
                        }
                        .transition(.opacity)
                    }

                    VStack {
                        Spacer()
                        discoveredStrip(targetCount: free.targetCount)
                            .padding(.bottom, 146)

                        if foundRecipes.count >= free.targetCount {
                            Button {
                                gameState.advanceLevel()
                            } label: {
                                Label("Finish Journey", systemImage: "flag.checkered")
                                    .font(.headline)
                                    .padding(.horizontal, 20)
                                    .padding(.vertical, 10)
                            }
                            .buttonStyle(.borderedProminent)
                            .tint(.green)
                            .foregroundStyle(.white)
                            .disabled(!finishEnabled)
                            .opacity(finishEnabled ? 1 : 0.5)
                            .padding(.bottom, 14)
                        }

                        inventoryArea
                    }

                    if let recipe = evolvingRecipe {
                        EvolutionStageView(
                            ingredients: evolvingIngredients,
                            resultGlyph: recipe.resultGlyph,
                            resultMeaning: recipe.displayResultMeaning(mode: gameState.scriptDisplayMode),
                            spatial: recipe.spatial,
                            centerPoint: evolutionCenter
                        ) {
                            completeEvolution(recipe: recipe, targetCount: free.targetCount)
                        }
                    }
                }
            }
            .onAppear {
                resetState(free: free)
            }
            .onChange(of: level.id) { _, _ in
                resetState(free: free)
            }
            .onChange(of: itemsOnCanvas) { _, _ in
                detectAutoCombinations(free: free)
            }
            .onChange(of: a11yPairLayout) { _, _ in
                guard a11yVoiceOverModeEnabled else { return }
                guard itemsOnCanvas.allSatisfy({ $0.status == .idle }) else { return }
                withAnimation(GameState.MotionContract.microEase) {
                    applyA11yPlacementLayout()
                }
            }
            .sensoryFeedback(.impact(weight: .medium), trigger: successFeedbackToken)
            .sensoryFeedback(.error, trigger: directionErrorFeedbackToken)
            .sensoryFeedback(.warning, trigger: invalidErrorFeedbackToken)
        )
    }

    private var centerZone: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 180, style: .continuous)
                .fill(Color.white.opacity(0.34))
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 180, style: .continuous))
            RoundedRectangle(cornerRadius: 180, style: .continuous)
                .strokeBorder(
                    isDropTargeted ? Color.primary.opacity(0.45) : Color.secondary.opacity(0.24),
                    style: StrokeStyle(lineWidth: 3, dash: [9, 8])
                )

            if itemsOnCanvas.isEmpty {
                Text("Free Combination")
                    .font(.headline)
                    .foregroundStyle(.tertiary)
            } else {
                ForEach(itemsOnCanvas) { canvasItem in
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
                        .accessibilityLabel("Canvas piece \(canvasItem.item.displayLabel(mode: gameState.scriptDisplayMode))")
                }
            }
        }
        .dropDestination(for: String.self) { droppedIDs, location in
            guard evolvingRecipe == nil else { return false }
            for id in droppedIDs {
                if let token = allInventory.first(where: { $0.id == id }) {
                    itemsOnCanvas.append(
                        CanvasItem(
                            uniqueID: UUID().uuidString,
                            item: token,
                            position: clampedPoint(location)
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
        .accessibilityLabel("Free creation zone")
        .accessibilityHint(
            a11yVoiceOverModeEnabled
                ? "Add items from the inventory to trigger automatic combinations."
                : "Drop items to trigger automatic combinations"
        )
    }

    private func discoveredStrip(targetCount: Int) -> some View {
        HStack(spacing: 10) {
            Text("Formed:")
                .font(.caption.weight(.semibold))
                .foregroundStyle(.secondary)
            ForEach(foundRecipes, id: \.self) { glyph in
                Text(glyph)
                    .font(.system(size: discoveredGlyphSize, weight: .regular, design: .serif))
            }
            Spacer()
            Text("\(foundRecipes.count)")
                .font(.caption.monospacedDigit())
                .foregroundStyle(.secondary)
            Text("/")
                .font(.caption)
                .foregroundStyle(.secondary)
            Text("\(targetCount)")
                .font(.caption.monospacedDigit())
                .foregroundStyle(.secondary)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 8)
        .background(.ultraThinMaterial, in: Capsule(style: .continuous))
        .frame(maxWidth: 520)
        .padding(.horizontal, 4)
    }

    private var allInventory: [InventoryToken] {
        baseInventory + createdInventory
    }

    private var inventoryArea: some View {
        VStack(spacing: 0) {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(baseInventory) { token in
                        inventoryItem(token)
                    }
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 8)
            }
            .frame(height: 70)
            .background(Color.white.opacity(0.85))

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    if createdInventory.isEmpty {
                        Text("Newly formed characters appear here")
                            .font(.caption)
                            .foregroundStyle(.tertiary)
                            .padding(.horizontal, 8)
                    } else {
                        ForEach(createdInventory) { token in
                            inventoryItem(token)
                        }
                    }
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 8)
            }
            .frame(height: 70)
            .background(Color(.secondarySystemBackground).opacity(0.55))
        }
        .frame(maxWidth: .infinity, minHeight: 140, maxHeight: 140)
        .background(.thinMaterial)
    }

    private var a11yPlacementControls: some View {
        HStack(spacing: 10) {
            Picker("Layout", selection: $a11yPairLayout) {
                Text("Horizontal").tag(A11yPairLayout.horizontal)
                Text("Vertical").tag(A11yPairLayout.vertical)
            }
            .pickerStyle(.segmented)
            .frame(width: 220, height: 44)
            .accessibilityLabel("Piece layout")

            Button {
                a11ySwapOrder.toggle()
                withAnimation(GameState.MotionContract.microEase) {
                    applyA11yPlacementLayout()
                }
            } label: {
                Label("Swap", systemImage: "arrow.left.arrow.right")
            }
            .buttonStyle(.bordered)
            .frame(minWidth: 44, minHeight: 44)
            .disabled(itemsOnCanvas.count != 2)
            .accessibilityHint("Swap left and right, or top and bottom")
        }
        .padding(.trailing, 12)
    }

    private func inventoryItem(_ token: InventoryToken) -> some View {
        let tile = VStack(spacing: 6) {
            PieceTile(glyph: token.displayIcon(mode: gameState.scriptDisplayMode), pressed: false)
                .frame(width: 64, height: 64)
            Text(token.displayLabel(mode: gameState.scriptDisplayMode))
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Inventory \(token.displayLabel(mode: gameState.scriptDisplayMode))")
        .accessibilityHint(
            a11yVoiceOverModeEnabled
                ? "Double tap to add this item to the creation zone"
                : "Drag this item into center zone"
        )

        return Group {
            if a11yVoiceOverModeEnabled {
                Button {
                    addTokenA11y(token)
                } label: {
                    tile
                }
                .buttonStyle(.plain)
            } else {
                tile.draggable(token.id)
            }
        }
    }

    private func clampedPoint(_ point: CGPoint) -> CGPoint {
        CGPoint(
            x: min(max(point.x, 44), 306),
            y: min(max(point.y, 44), 306)
        )
    }

    private func addTokenA11y(_ token: InventoryToken) {
        guard a11yVoiceOverModeEnabled else { return }
        guard evolvingRecipe == nil else { return }
        guard itemsOnCanvas.count < 3 else {
            feedback = "Canvas is full. Clear or undo to add more."
            feedbackKind = nil
            return
        }
        withAnimation(GameState.MotionContract.microEase) {
            itemsOnCanvas.append(
                CanvasItem(
                    uniqueID: UUID().uuidString,
                    item: token,
                    position: CGPoint(x: 175, y: 175)
                )
            )
            applyA11yPlacementLayout()
        }
    }

    private func applyA11yPlacementLayout() {
        let center = CGPoint(x: 175, y: 175)
        guard !itemsOnCanvas.isEmpty else { return }

        if itemsOnCanvas.count == 1 {
            itemsOnCanvas[0].position = center
            return
        }

        if itemsOnCanvas.count == 2 {
            let a = CGPoint(x: center.x - 70, y: center.y)
            let b = CGPoint(x: center.x + 70, y: center.y)
            let c = CGPoint(x: center.x, y: center.y - 70)
            let d = CGPoint(x: center.x, y: center.y + 70)

            let first: CGPoint
            let second: CGPoint
            switch a11yPairLayout {
            case .horizontal:
                first = a
                second = b
            case .vertical:
                first = c
                second = d
            }

            if a11ySwapOrder {
                itemsOnCanvas[0].position = second
                itemsOnCanvas[1].position = first
            } else {
                itemsOnCanvas[0].position = first
                itemsOnCanvas[1].position = second
            }
            return
        }

        let positions: [CGPoint] = [
            CGPoint(x: center.x, y: center.y - 70),
            CGPoint(x: center.x - 60, y: center.y + 40),
            CGPoint(x: center.x + 60, y: center.y + 40),
        ]
        for index in 0..<min(3, itemsOnCanvas.count) {
            itemsOnCanvas[index].position = positions[index]
        }
    }

    private func detectAutoCombinations(free: FreeLevelData) {
        guard evolvingRecipe == nil else { return }
        guard itemsOnCanvas.count >= 2 else { return }
        guard itemsOnCanvas.allSatisfy({ $0.status == .idle }) else { return }

        // Triple recipes (e.g. Crowd / Forest) should resolve before pair checks.
        if itemsOnCanvas.count >= 3 {
            let triples = combinations3(of: itemsOnCanvas)
            for triple in triples {
                let ids = triple.map { $0.item.id }
                let tripleKey = sortedKey(ids)
                let tripleCandidates = free.validRecipes.filter {
                    $0.ingredients.count == 3 && sortedKey($0.ingredients) == tripleKey
                }
                guard let recipe = tripleCandidates.first else { continue }

                let d01 = distance(triple[0].position, triple[1].position)
                let d02 = distance(triple[0].position, triple[2].position)
                let d12 = distance(triple[1].position, triple[2].position)
                if max(d01, d02, d12) <= 175 {
                    startFreeEvolution(recipe: recipe, items: triple)
                    return
                }
            }
        }

        for i in 0..<itemsOnCanvas.count {
            for j in (i + 1)..<itemsOnCanvas.count {
                let a = itemsOnCanvas[i]
                let b = itemsOnCanvas[j]
                if a.status != .idle || b.status != .idle { continue }

                let dx = a.position.x - b.position.x
                let dy = a.position.y - b.position.y
                let dist = sqrt(dx * dx + dy * dy)
                if dist > 150 { continue }

                let pair = [a.item.id, b.item.id]
                let key = sortedKey(pair)
                let candidates = free.validRecipes.filter { sortedKey($0.ingredients) == key }

                if candidates.isEmpty {
                    triggerReturnToCandidate(
                        targetIDs: [a.uniqueID, b.uniqueID],
                        message: "Invalid combination: these pieces cannot form a character."
                    )
                    return
                }

                if let recipe = matchedFreeRecipe(candidates: candidates, first: a, second: b) {
                    startFreeEvolution(recipe: recipe, items: [a, b])
                    return
                } else {
                    triggerDirectionMismatch(
                        targetIDs: [a.uniqueID, b.uniqueID],
                        message: "Wrong direction: adjust piece orientation."
                    )
                    return
                }
            }
        }
    }

    private func combinations3(of items: [CanvasItem]) -> [[CanvasItem]] {
        guard items.count >= 3 else { return [] }
        var result: [[CanvasItem]] = []
        for i in 0..<(items.count - 2) {
            for j in (i + 1)..<(items.count - 1) {
                for k in (j + 1)..<items.count {
                    result.append([items[i], items[j], items[k]])
                }
            }
        }
        return result
    }

    private func distance(_ a: CGPoint, _ b: CGPoint) -> CGFloat {
        let dx = a.x - b.x
        let dy = a.y - b.y
        return sqrt(dx * dx + dy * dy)
    }

    private func matchedFreeRecipe(candidates: [CombinationRecipe], first: CanvasItem, second: CanvasItem) -> CombinationRecipe? {
        let dx = first.position.x - second.position.x
        let dy = first.position.y - second.position.y
        let isHorizontal = abs(dx) > abs(dy)

        for recipe in candidates {
            switch recipe.spatial {
            case .leftRight:
                guard isHorizontal else { continue }

                if recipe.resultPieceID == "hao" {
                    let woman = first.item.id == "nv" ? first : second
                    let child = first.item.id == "zi" ? first : second
                    if woman.position.x < child.position.x { return recipe }
                    continue
                }
                if recipe.resultPieceID == "xin" {
                    let ren = first.item.id == "ren" ? first : second
                    let yan = first.item.id == "yan" ? first : second
                    if ren.position.x < yan.position.x { return recipe }
                    continue
                }
                if recipe.resultPieceID == "xiu" {
                    let ren = first.item.id == "ren" ? first : second
                    let mu = first.item.id == "mu" ? first : second
                    if ren.position.x < mu.position.x { return recipe }
                    continue
                }
                if recipe.resultPieceID == "ming" {
                    let ri = first.item.id == "ri" ? first : second
                    let yue = first.item.id == "yue" ? first : second
                    if ri.position.x < yue.position.x { return recipe }
                    continue
                }
                return recipe
            case .topBottom, .stacked:
                guard !isHorizontal else { continue }

                if recipe.resultPieceID == "ben" {
                    let yi = first.item.id == "yi" ? first : second
                    let mu = first.item.id == "mu" ? first : second
                    if yi.position.y > mu.position.y { return recipe }
                    continue
                }
                if recipe.resultPieceID == "mo" {
                    let yi = first.item.id == "yi" ? first : second
                    let mu = first.item.id == "mu" ? first : second
                    if yi.position.y < mu.position.y { return recipe }
                    continue
                }
                if recipe.resultPieceID == "dai" {
                    let kou = first.item.id == "kou" ? first : second
                    let mu = first.item.id == "mu" ? first : second
                    if kou.position.y < mu.position.y { return recipe }
                    continue
                }
                return recipe
            case .any:
                return recipe
            }
        }
        return nil
    }

    private func startFreeEvolution(recipe: CombinationRecipe, items: [CanvasItem]) {
        let center = CGPoint(
            x: items.map { $0.position.x }.reduce(0, +) / CGFloat(items.count),
            y: items.map { $0.position.y }.reduce(0, +) / CGFloat(items.count)
        )
        evolutionCenter = center
        evolvingRecipe = recipe
        let orderedItems: [CanvasItem]
        switch recipe.spatial {
        case .leftRight:
            orderedItems = items.sorted { $0.position.x < $1.position.x }
        case .topBottom, .stacked:
            orderedItems = items.sorted {
                if abs($0.position.y - $1.position.y) < 1 {
                    return $0.position.x < $1.position.x
                }
                return $0.position.y < $1.position.y
            }
        case .any:
            orderedItems = items
        }
        evolvingIngredients = orderedItems.map { EvolutionIngredient(id: $0.item.id, icon: $0.item.icon) }

        let ids = Set(items.map(\.uniqueID))
        itemsOnCanvas.removeAll { ids.contains($0.uniqueID) }
    }

    private func completeEvolution(recipe: CombinationRecipe, targetCount: Int) {
        if !foundRecipes.contains(recipe.resultGlyph) {
            foundRecipes.append(recipe.resultGlyph)
        }
        if !createdInventory.contains(where: { $0.id == recipe.resultPieceID }) {
            createdInventory.append(
                InventoryToken(
                    id: recipe.resultPieceID,
                    icon: recipe.resultGlyph,
                    label: recipe.resultMeaning,
                    oracleIcon: recipe.resultGlyph,
                    oracleLabel: recipe.displayResultMeaning(mode: gameState.scriptDisplayMode)
                )
            )
        }

        evolvingRecipe = nil
        evolvingIngredients = []
        evolutionCenter = nil
        feedback = "Created \(recipe.resultMeaning)!"
        feedbackKind = nil
        successFeedbackToken += 1
        CreationFeedback.playMergeSound(audioEnabled: gameState.audioEnabled)

        if foundRecipes.count >= targetCount {
            feedback = level.free?.displayFinalMessage(mode: gameState.scriptDisplayMode) ?? feedback
            Task { @MainActor in
                try? await Task.sleep(for: .seconds(level.wowPauseSeconds))
                finishEnabled = true
            }
        } else {
            Task { @MainActor in
                try? await Task.sleep(for: GameState.MotionContract.transientFeedbackClearDelay)
                feedback = nil
            }
        }
    }

    private func triggerReturnToCandidate(targetIDs: [String], message: String) {
        feedback = message
        feedbackKind = .invalidCombination
        invalidErrorFeedbackToken += 1
        withAnimation(GameState.MotionContract.returnSpring) {
            for index in itemsOnCanvas.indices where targetIDs.contains(itemsOnCanvas[index].uniqueID) {
                itemsOnCanvas[index].status = .returning
            }
        }

        Task { @MainActor in
            try? await Task.sleep(for: GameState.MotionContract.returnClearDelay)
            withAnimation(GameState.MotionContract.microEase) {
                itemsOnCanvas.removeAll { targetIDs.contains($0.uniqueID) }
            }
            try? await Task.sleep(for: GameState.MotionContract.feedbackClearDelay)
            if feedback == message {
                feedback = nil
                feedbackKind = nil
            }
        }
    }

    private func triggerDirectionMismatch(targetIDs: [String], message: String) {
        feedback = message
        feedbackKind = .directionMismatch
        directionErrorFeedbackToken += 1
        withAnimation(GameState.MotionContract.repelSpring) {
            for index in itemsOnCanvas.indices where targetIDs.contains(itemsOnCanvas[index].uniqueID) {
                itemsOnCanvas[index].status = .repelling
            }
        }

        Task { @MainActor in
            try? await Task.sleep(for: GameState.MotionContract.repelClearDelay)
            withAnimation(GameState.MotionContract.microEase) {
                itemsOnCanvas.removeAll { targetIDs.contains($0.uniqueID) }
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

    private func resetState(free: FreeLevelData) {
        baseInventory = free.availableItems
        createdInventory = []
        itemsOnCanvas = []
        feedback = nil
        feedbackKind = nil
        foundRecipes = []
        evolvingRecipe = nil
        evolvingIngredients = []
        evolutionCenter = nil
        finishEnabled = false
        a11yPairLayout = .horizontal
        a11ySwapOrder = false
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
            .padding(.horizontal, 18)
            .padding(.vertical, 10)
            .background(isDirection ? Color.orange.opacity(0.94) : Color.indigo.opacity(0.92), in: Capsule(style: .continuous))
            .contentTransition(.opacity)
    }

    private enum A11yPairLayout: Hashable {
        case horizontal
        case vertical
    }
}
