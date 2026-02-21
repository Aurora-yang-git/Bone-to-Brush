import SwiftUI

struct ContentView: View {
    @State private var gameState = GameState()
    @State private var stageIsTargeted = false

    var body: some View {
        ZStack {
            mainContent

            if gameState.showPhaseTransition {
                phaseTransitionOverlay
                    .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.25), value: gameState.showPhaseTransition)
        .task { gameState.resetForCurrentLevel() }
    }

    // MARK: Main layout

    private var mainContent: some View {
        GeometryReader { geo in
            VStack(spacing: 20) {
                promptSection
                stageSection(size: geo.size)
                traySection
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .padding(.horizontal, 24)
            .padding(.top, 16)
            .padding(.bottom, 14)
        }
        .background(Color(.systemBackground))
    }

    // MARK: Prompt

    private var promptSection: some View {
        VStack(spacing: 8) {
            Image(systemName: phaseIcon)
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(.tertiary)
                .accessibilityLabel("Phase indicator")

            Text(promptText)
                .font(.title3.weight(.semibold))
                .foregroundStyle(.primary)
                .multilineTextAlignment(.center)
                .lineSpacing(3)
                .frame(maxWidth: 600)
                .minimumScaleFactor(0.82)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 8)
        .animation(.easeInOut(duration: 0.22), value: gameState.currentLevelIndex)
    }

    private var phaseIcon: String {
        guard let level = gameState.currentLevel else { return "sparkles" }
        switch level.phase {
        case .pictograph: return "eye"
        case .ideograph: return "hand.point.up"
        case .compound: return "plus.diamond"
        case .phonoSemantic: return "waveform"
        }
    }

    private var promptText: String {
        if gameState.finishedAllLevels {
            return "Every character carries a civilization's way of seeing the world."
        }
        return gameState.currentLevel?.prompt ?? ""
    }

    // MARK: Stage

    @ViewBuilder
    private func stageSection(size: CGSize) -> some View {
        let height = stageHeight(in: size)
        GeometryReader { stageGeo in
            ZStack {
                stageBackground

                if let level = gameState.currentLevel, !gameState.finishedAllLevels {

                    // Phase-specific interactive content (fades out during evolution)
                    Group {
                        if gameState.isTraceMode {
                            traceStage(level: level, size: stageGeo.size)
                        } else {
                            switch level.phase {
                            case .pictograph:
                                pictographStage(level: level, size: stageGeo.size)
                            case .ideograph:
                                ideographStage(level: level, size: stageGeo.size)
                            case .compound:
                                compoundStage(level: level, size: stageGeo.size)
                            case .phonoSemantic:
                                phonoSemanticStage(level: level, size: stageGeo.size)
                            }
                        }
                    }
                    .opacity(gameState.evolutionIndex == nil ? 1 : 0)

                    // Render Free-floating pieces
                    if !gameState.isTraceMode {
                        ForEach(gameState.freePositions.keys.sorted(), id: \.self) { pieceID in
                            if let pos = gameState.freePositions[pieceID] {
                                if pieceID == "pictograph", let image = level.pictographImage {
                                    Image(image)
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .padding(9)
                                        .frame(width: 66, height: 66)
                                        .background {
                                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                                .fill(Color(.systemBackground))
                                                .overlay {
                                                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                                                        .strokeBorder(
                                                            Color.primary.opacity(0.24),
                                                            lineWidth: 1.2
                                                        )
                                                }
                                        }
                                        .overlay {
                                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                                .strokeBorder(
                                                    Color.accentColor.opacity(
                                                        gameState.draggingPieceID == pieceID ? 0.44 : 0.26
                                                    ),
                                                    lineWidth: gameState.draggingPieceID == pieceID ? 2 : 1
                                                )
                                        }
                                        .position(pos)
                                        .shadow(
                                            color: .black.opacity(gameState.draggingPieceID == pieceID ? 0.2 : 0.14),
                                            radius: gameState.draggingPieceID == pieceID ? 10 : 6,
                                            x: 0,
                                            y: gameState.draggingPieceID == pieceID ? 6 : 4
                                        )
                                        .zIndex(gameState.draggingPieceID == pieceID ? 2 : 1)
                                        .draggable(pieceID) {
                                            Image(image)
                                                .resizable()
                                                .aspectRatio(contentMode: .fit)
                                                .padding(9)
                                                .frame(width: 66, height: 66)
                                                .background {
                                                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                                                        .fill(Color(.systemBackground))
                                                }
                                                .onAppear { gameState.draggingPieceID = pieceID }
                                        }
                                        .simultaneousGesture(
                                            DragGesture(coordinateSpace: .global)
                                                .onChanged { _ in gameState.draggingPieceID = pieceID }
                                                .onEnded { _ in
                                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                                        if gameState.draggingPieceID == pieceID {
                                                            gameState.draggingPieceID = nil
                                                        }
                                                    }
                                                }
                                        )
                                        .transition(.opacity)
                                        .accessibilityLabel("Placed pictograph image")
                                } else if let piece = level.components.first(where: { $0.id == pieceID }) {
                                    PieceTile(glyph: piece.glyph, pressed: gameState.draggingPieceID == pieceID)
                                        .frame(width: 66, height: 66)
                                        .overlay {
                                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                                .strokeBorder(
                                                    Color.accentColor.opacity(
                                                        gameState.draggingPieceID == pieceID ? 0.44 : 0.26
                                                    ),
                                                    lineWidth: gameState.draggingPieceID == pieceID ? 2 : 1
                                                )
                                        }
                                        .position(pos)
                                        .shadow(
                                            color: .black.opacity(gameState.draggingPieceID == pieceID ? 0.2 : 0.14),
                                            radius: gameState.draggingPieceID == pieceID ? 10 : 6,
                                            x: 0,
                                            y: gameState.draggingPieceID == pieceID ? 6 : 4
                                        )
                                        .zIndex(gameState.draggingPieceID == pieceID ? 2 : 1)
                                        .draggable(pieceID) {
                                            PieceTile(glyph: piece.glyph, pressed: true)
                                                .frame(width: 66, height: 66)
                                                .onAppear { gameState.draggingPieceID = pieceID }
                                        }
                                        .simultaneousGesture(
                                            DragGesture(coordinateSpace: .global)
                                                .onChanged { _ in gameState.draggingPieceID = pieceID }
                                                .onEnded { _ in
                                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                                        if gameState.draggingPieceID == pieceID {
                                                            gameState.draggingPieceID = nil
                                                        }
                                                    }
                                                }
                                        )
                                        .transition(.opacity)
                                }
                            }
                        }
                    }

                    // Evolution overlay
                    if let idx = gameState.evolutionIndex, idx < level.evolutionFrames.count {
                        Text(level.evolutionFrames[idx])
                            .font(.system(size: 92, weight: .regular, design: .serif))
                            .foregroundStyle(.primary)
                            .transition(.opacity.combined(with: .scale(scale: 0.95)))
                            .id("evo_\(idx)")
                            .accessibilityLabel("Evolving character: \(level.evolutionFrames[idx])")
                    }

                    // Bottom: reflection + continue
                    VStack(spacing: 10) {
                        Spacer()
                        if gameState.showReflection {
                            Text(level.reflection)
                                .font(.callout)
                                .foregroundStyle(.secondary)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 28)
                                .transition(.opacity)
                        }
                        if gameState.showContinue {
                            continueButton
                        }
                    }

                    // Hint
                    if gameState.hintVisible, let hint = GameState.levelHints[level.id] {
                        VStack {
                            Spacer()
                            Text(hint)
                                .font(.footnote)
                                .foregroundStyle(.tertiary)
                                .padding(.bottom, 48)
                                .transition(.opacity)
                        }
                    }

                } else if gameState.finishedAllLevels {
                    completionContent
                }
            }
            .animation(.easeInOut(duration: 0.22), value: gameState.evolutionIndex)
            .animation(.easeInOut(duration: 0.22), value: gameState.showReflection)
            .animation(.easeInOut(duration: 0.22), value: gameState.showContinue)
            .animation(.easeInOut(duration: 0.18), value: gameState.snappedPositions.count)
            .dropDestination(for: String.self) { droppedIDs, location in
                guard !gameState.isTraceMode else { return false }
                guard let pieceID = droppedIDs.first else { return false }
                return gameState.placePiece(pieceID, near: location, stageSize: stageGeo.size)
            } isTargeted: { targeted in
                withAnimation(.easeInOut(duration: 0.12)) {
                    stageIsTargeted = gameState.isTraceMode ? false : targeted
                }
            }
            .accessibilityLabel("Construction stage")
            .accessibilityHint(stageAccessibilityHint)
        }
        .frame(height: height)
        .task(id: gameState.hintVisible) {
            if gameState.hintVisible {
                try? await Task.sleep(for: .seconds(3))
                withAnimation(.easeInOut(duration: 0.35)) { gameState.hintVisible = false }
            }
        }
    }

    private var stageAccessibilityHint: String {
        if gameState.isTraceMode {
            return "Trace the guide shape in the canvas to complete this character"
        }
        guard let level = gameState.currentLevel else { return "" }
        switch level.phase {
        case .pictograph: return "Look at the ancient form above and tap the matching character below"
        case .ideograph: return "Drag the marker to the correct position on the character"
        case .compound: return "Drag components here to combine them"
        case .phonoSemantic: return "Drag the meaning radical and sound component to their slots"
        }
    }

    private var stageBackground: some View {
        RoundedRectangle(cornerRadius: 24, style: .continuous)
            .fill(Color(.secondarySystemBackground))
            .overlay {
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .strokeBorder(
                        stageIsTargeted
                            ? Color.primary.opacity(0.35)
                            : Color.secondary.opacity(0.16),
                        lineWidth: 1
                    )
            }
    }

    // MARK: Pictograph stage (Phase 1)

    @ViewBuilder
    private func traceStage(level: Level, size: CGSize) -> some View {
        VStack(spacing: 14) {
            if level.phase == .pictograph {
                pictographFusionReference(level: level)
                    .frame(maxWidth: min(size.width * 0.75, 420))
                    .accessibilityElement(children: .combine)
                    .accessibilityLabel("Real-world image and ancient character fusion")
                    .accessibilityHint("Observe how a real object gradually becomes an ancient character")
            }

            if level.phase != .pictograph, let ancient = level.ancientForm {
                Text(ancient)
                    .font(.system(size: 74, weight: .regular, design: .serif))
                    .foregroundStyle(.secondary.opacity(0.48))
                    .accessibilityLabel("Ancient form: \(ancient)")
            }

            if let guide = level.traceGuide {
                TraceCanvasView(
                    guide: guide,
                    targetGlyph: "",
                    resetKey: level.id,
                    progress: gameState.traceProgress,
                    onTraceChanged: { points, didEnd in
                        gameState.updateTrace(points: points, didEnd: didEnd)
                    },
                    onClear: {
                        gameState.clearTrace()
                    }
                )
                .frame(maxWidth: min(size.width * 0.75, 420))
                .id("trace-canvas-\(level.id)")
            }
        }
    }

    @ViewBuilder
    private func pictographFusionReference(level: Level) -> some View {
        let fusionProgress = min(max(gameState.traceProgress, 0), 1)
        ZStack {
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(Color(.tertiarySystemBackground))

            if let symbol = level.referenceSymbol {
                Image(systemName: symbol)
                    .font(.system(size: 48, weight: .regular))
                    .foregroundStyle(.secondary.opacity(0.45 * (1 - fusionProgress)))
                    .opacity(max(0.08, 1 - fusionProgress))
                    .accessibilityHidden(true)
            }

            if let imageName = level.referenceImage {
                Image(imageName)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .padding(22)
                    .opacity(max(0.05, 1 - fusionProgress))
                    .accessibilityHidden(true)
            }

            if let ancient = level.ancientForm {
                Text(ancient)
                    .font(.system(size: 88, weight: .regular, design: .serif))
                    .foregroundStyle(.primary.opacity(fusionProgress * 0.92))
                    .scaleEffect(0.98 + fusionProgress * 0.04)
                    .animation(.easeInOut(duration: 0.16), value: fusionProgress)
                    .accessibilityHidden(true)
            }
        }
        .frame(height: 170)
        .overlay(alignment: .bottomLeading) {
            Text("Object -> Oracle form")
                .font(.caption2.weight(.medium))
                .foregroundStyle(.tertiary)
                .padding(.horizontal, 10)
                .padding(.vertical, 8)
        }
    }

    @ViewBuilder
    private func pictographStage(level: Level, size: CGSize) -> some View {
        if let ancient = level.ancientForm {
            Text(ancient)
                .font(.system(size: 104, weight: .ultraLight, design: .serif))
                .foregroundStyle(.primary)
                .opacity(gameState.pictographMerging ? 1.0 : 0.12)
                .scaleEffect(gameState.pictographMerging ? 1.0 : 0.95)
                .animation(.easeInOut(duration: 0.5), value: gameState.pictographMerging)
                .accessibilityLabel("Ancient pictographic form")
        }

        if let image = level.pictographImage, let pos = gameState.snappedPositions["pictograph"] {
            Image(image)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 140, height: 140)
                .position(pos)
                .opacity(gameState.pictographMerging ? 0.0 : 1.0)
                .transition(.opacity)
                .accessibilityLabel("Placed pictograph image")
        }
    }

    // MARK: Ideograph stage (Phase 2)

    @ViewBuilder
    private func ideographStage(level: Level, size: CGSize) -> some View {
        if let base = level.ancientForm {
            Text(base)
                .font(.system(size: 88, weight: .regular, design: .serif))
                .foregroundStyle(.primary)
                .accessibilityLabel("Base character: \(base)")
        }

        let topPos = CGPoint(x: 0.5, y: 0.28)
        let bottomPos = CGPoint(x: 0.5, y: 0.72)

        ForEach([(topPos, "top"), (bottomPos, "bottom")], id: \.1) { pos, label in
            if gameState.draggingPieceID == "marker" {
                Circle()
                    .fill(Color.yellow.opacity(0.3))
                    .frame(width: 60, height: 60)
                    .position(x: pos.x * size.width, y: pos.y * size.height)
                    .blur(radius: 10)
                    .transition(.opacity)
            }

            RoundedRectangle(cornerRadius: 6, style: .continuous)
                .strokeBorder(
                    Color.secondary.opacity(0.28),
                    style: StrokeStyle(lineWidth: 1.5, dash: [5, 4])
                )
                .frame(width: 52, height: 10)
                .position(x: pos.x * size.width, y: pos.y * size.height)
                .accessibilityLabel("\(label) drop zone")
                .accessibilityHidden(true)
        }

        ForEach(level.components) { piece in
            if let pos = gameState.snappedPositions[piece.id] {
                PieceTile(glyph: piece.glyph, pressed: false)
                    .frame(width: 56, height: 34)
                    .position(pos)
                    .transition(.scale(scale: 0.94).combined(with: .opacity))
                    .accessibilityLabel("Placed \(piece.accessibilityName)")
            }
        }
    }

    // MARK: Compound stage (Phase 3)

    @ViewBuilder
    private func compoundStage(level: Level, size: CGSize) -> some View {
        ForEach(level.solution, id: \.self) { pieceID in
            if let slot = level.targetSlots[pieceID] {
                if gameState.draggingPieceID == pieceID {
                    Circle()
                        .fill(Color.blue.opacity(0.3))
                        .frame(width: 70, height: 70)
                        .position(x: slot.x * size.width, y: slot.y * size.height)
                        .blur(radius: 10)
                        .transition(.opacity)
                }

                Circle()
                    .strokeBorder(
                        Color.secondary.opacity(0.22),
                        style: StrokeStyle(lineWidth: 1, dash: [4, 5])
                    )
                    .frame(width: 52, height: 52)
                    .position(x: slot.x * size.width, y: slot.y * size.height)
                    .accessibilityHidden(true)
            }
        }

        ForEach(level.components) { piece in
            if let pos = gameState.snappedPositions[piece.id] {
                PieceTile(glyph: piece.glyph, pressed: false)
                    .frame(width: 64, height: 64)
                    .position(pos)
                    .transition(.scale(scale: 0.94).combined(with: .opacity))
                    .accessibilityLabel("Placed \(piece.accessibilityName)")
            }
        }
    }

    // MARK: Phono-semantic stage (Phase 4)

    @ViewBuilder
    private func phonoSemanticStage(level: Level, size: CGSize) -> some View {
        VStack(spacing: 3) {
            Image(systemName: "lightbulb")
                .font(.system(size: 12))
            Text("meaning")
                .font(.caption2.weight(.medium))
        }
        .foregroundStyle(.secondary)
        .position(x: 0.35 * size.width, y: 0.26 * size.height)
        .accessibilityHidden(true)

        VStack(spacing: 3) {
            Image(systemName: "speaker.wave.2")
                .font(.system(size: 12))
            Text("sound")
                .font(.caption2.weight(.medium))
        }
        .foregroundStyle(.secondary)
        .position(x: 0.63 * size.width, y: 0.26 * size.height)
        .accessibilityHidden(true)

        ForEach(level.solution, id: \.self) { pieceID in
            if let slot = level.targetSlots[pieceID] {
                if gameState.draggingPieceID == pieceID {
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(Color.purple.opacity(0.3))
                        .frame(width: 80, height: 80)
                        .position(x: slot.x * size.width, y: slot.y * size.height)
                        .blur(radius: 10)
                        .transition(.opacity)
                }

                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .strokeBorder(
                        Color.secondary.opacity(0.22),
                        style: StrokeStyle(lineWidth: 1.5, dash: [5, 4])
                    )
                    .frame(width: 60, height: 60)
                    .position(x: slot.x * size.width, y: slot.y * size.height)
                    .accessibilityHidden(true)
            }
        }

        ForEach(level.components) { piece in
            if let pos = gameState.snappedPositions[piece.id] {
                PieceTile(glyph: piece.glyph, pressed: false)
                    .frame(width: 64, height: 64)
                    .position(pos)
                    .transition(.scale(scale: 0.94).combined(with: .opacity))
                    .accessibilityLabel("Placed \(piece.accessibilityName)")
            }
        }
    }

    // MARK: Continue button

    private var continueButton: some View {
        Button {
            withAnimation(.easeInOut(duration: 0.22)) { gameState.advanceLevel() }
        } label: {
            Label("Continue", systemImage: "arrow.right")
                .font(.subheadline.weight(.semibold))
                .padding(.horizontal, 18)
                .padding(.vertical, 9)
        }
        .buttonStyle(.borderedProminent)
        .tint(Color(.systemGray4))
        .foregroundStyle(.primary)
        .accessibilityLabel("Continue to next level")
        .accessibilityHint("Moves to the next character puzzle")
        .padding(.bottom, 12)
    }

    // MARK: Completion

    private var completionContent: some View {
        VStack(spacing: 12) {
            Image(systemName: "seal")
                .font(.system(size: 28))
                .foregroundStyle(.secondary)
                .accessibilityHidden(true)
            Text("You have reached the final character.")
                .font(.title3.weight(.semibold))
            Text("Every stroke carries a civilization's way of seeing.")
                .font(.callout)
                .foregroundStyle(.secondary)
        }
        .multilineTextAlignment(.center)
        .padding(.horizontal, 28)
    }

    // MARK: Phase transition overlay

    private var phaseTransitionOverlay: some View {
        ZStack {
            Color(.systemBackground).opacity(0.94)
                .ignoresSafeArea()

            VStack(spacing: 24) {
                Text(gameState.phaseTransitionText)
                    .font(.title2.weight(.semibold))
                    .foregroundStyle(.primary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(6)

                Button {
                    withAnimation(.easeInOut(duration: 0.22)) {
                        gameState.dismissPhaseTransition()
                    }
                } label: {
                    Label("Continue", systemImage: "arrow.right")
                        .font(.subheadline.weight(.semibold))
                        .padding(.horizontal, 18)
                        .padding(.vertical, 9)
                }
                .buttonStyle(.borderedProminent)
                .tint(Color(.systemGray4))
                .foregroundStyle(.primary)
                .accessibilityLabel("Continue to next phase")
                .accessibilityHint("Advances to the next stage of character evolution")
            }
            .padding(36)
        }
    }

    // MARK: Tray

    @ViewBuilder
    private var traySection: some View {
        if let level = gameState.currentLevel,
           !gameState.finishedAllLevels,
           !gameState.showPhaseTransition,
           !gameState.isTraceMode
        {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 14) {
                    if level.phase == .pictograph {
                        pictographTray(level: level)
                    } else {
                        dragTray(level: level)
                    }
                }
                .padding(.horizontal, 6)
                .padding(.vertical, 8)
            }
            .frame(maxWidth: .infinity, minHeight: 88)
        }
    }

    // Phase 1: draggable image
    @ViewBuilder
    private func pictographTray(level: Level) -> some View {
        if let image = level.pictographImage, gameState.canUsePiece("pictograph") {
            Image(image)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 80, height: 80)
                .padding(12)
                .background {
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(Color(.tertiarySystemBackground))
                        .shadow(color: .black.opacity(0.08), radius: 4, x: 0, y: 2)
                }
                .draggable("pictograph") {
                    Image(image)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 80, height: 80)
                        .padding(8)
                        .background {
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .fill(Color(.tertiarySystemBackground))
                        }
                }
                .accessibilityLabel("Pictograph image")
                .accessibilityHint("Drag this image to the ancient form on the stage")
        }
    }

    // Phase 2, 3, 4: draggable pieces
    @ViewBuilder
    private func dragTray(level: Level) -> some View {
        ForEach(level.components) { piece in
            let usable = gameState.canUsePiece(piece.id)

            PieceTile(
                glyph: piece.glyph,
                pressed: gameState.draggingPieceID == piece.id && usable
            )
            .frame(width: 66, height: 66)
            .opacity(usable ? 1.0 : 0.26)
            .hoverEffect(.lift)
            .onLongPressGesture(
                minimumDuration: 0,
                maximumDistance: 50,
                pressing: { pressing in
                    if pressing && usable {
                        withAnimation(.easeInOut(duration: 0.12)) {
                            gameState.draggingPieceID = piece.id
                        }
                    }
                },
                perform: {}
            )
            .draggable(piece.id) {
                PieceTile(glyph: piece.glyph, pressed: true)
                    .frame(width: 66, height: 66)
                    .onAppear {
                        gameState.draggingPieceID = piece.id
                    }
            }
            .simultaneousGesture(
                DragGesture(coordinateSpace: .global)
                    .onChanged { _ in
                        if usable { gameState.draggingPieceID = piece.id }
                    }
                    .onEnded { _ in
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            if gameState.draggingPieceID == piece.id {
                                gameState.draggingPieceID = nil
                            }
                        }
                    }
            )
            .allowsHitTesting(usable)
            .accessibilityLabel("Component: \(piece.accessibilityName)")
            .accessibilityHint(
                usable
                    ? "Drag this component to the construction stage"
                    : "This component is already placed"
            )
        }
    }

    // MARK: Helpers

    private func stageHeight(in size: CGSize) -> CGFloat {
        min(max(size.height * 0.48, 250), 420)
    }
}
