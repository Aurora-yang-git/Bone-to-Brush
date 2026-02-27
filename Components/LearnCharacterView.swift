import SwiftUI

struct LearnCharacterView: View {
    @Bindable var gameState: GameState
    let level: WebLevel

    var body: some View {
        if let data = level.learn {
            switch data.interaction {
            case .observe:
                ObserveLearnView(gameState: gameState, level: level, data: data)
            case .trace:
                TraceLearnView(gameState: gameState, level: level, data: data)
            case .drawFromMemory, .memoryDraw:
                DrawFromMemoryLearnView(gameState: gameState, level: level, data: data)
            case .shakeReveal:
                ShakeRevealLearnView(gameState: gameState, level: level, data: data)
            case .tapReveal:
                TapRevealLearnView(gameState: gameState, level: level, data: data)
            case .pulseReveal:
                PulseRevealLearnView(gameState: gameState, level: level, data: data)
            case .silhouetteMatch:
                SilhouetteMatchLearnView(gameState: gameState, level: level, data: data)
            case .swipeReveal:
                SwipeRevealLearnView(gameState: gameState, level: level, data: data)
            }
        }
    }
}

// MARK: - Shared morph + continue footer

private struct LearnFooter: View {
    let level: WebLevel
    let data: LearnCharacterData
    let morphTriggered: Bool
    let continueEnabled: Bool
    let onContinue: () -> Void

    @State private var morphDone = false
    @State private var showContinue = false
    @State private var feedbackToken = 0

    var body: some View {
        VStack(spacing: 16) {
            if morphTriggered {
                OracleToModernMorphView(
                    oracleStrokes: data.oracleStrokes,
                    modernGlyph: data.modernGlyph,
                    meaning: data.meaning,
                    canvasSize: CGSize(width: 300, height: 300),
                    onMorphComplete: {
                        morphDone = true
                        Task {
                            try? await Task.sleep(for: .seconds(level.wowPauseSeconds))
                            withAnimation(.easeOut(duration: 0.4)) {
                                showContinue = true
                            }
                        }
                    }
                )
                .frame(height: 300)
                .sensoryFeedback(.impact(weight: .medium), trigger: morphDone)
            }

            if showContinue && continueEnabled {
                Button {
                    feedbackToken += 1
                    onContinue()
                } label: {
                    Label("Continue", systemImage: "arrow.right.circle.fill")
                        .font(.headline)
                        .padding(.horizontal, 22)
                        .padding(.vertical, 12)
                }
                .buttonStyle(.borderedProminent)
                .transition(.opacity.combined(with: .offset(y: 12)))
                .sensoryFeedback(.impact(weight: .light), trigger: feedbackToken)
                .accessibilityHint("Move to the next chapter")
            }
        }
    }
}

// MARK: - 1. Observe (Level 1 · Sun)
// SF Symbol dissolves into oracle strokes drawing themselves, then morphs to modern character.

private struct ObserveLearnView: View {
    @Bindable var gameState: GameState
    let level: WebLevel
    let data: LearnCharacterData

    @State private var phase = 0 // 0=symbol, 1=drawing strokes, 2=morph
    @State private var symbolScale: CGFloat = 1.0
    @State private var symbolOpacity: CGFloat = 1.0
    @State private var strokeProgress: CGFloat = 0
    @State private var showMorph = false

    var body: some View {
        VStack(spacing: 20) {
            Spacer(minLength: 16)

            Text(level.title)
                .font(.system(.largeTitle, design: .serif, weight: .bold))
                .accessibilityAddTraits(.isHeader)

            Text(data.instruction)
                .font(.title3)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .frame(maxWidth: 600)

            ZStack {
                if phase < 2 {
                    Image(systemName: data.sfSymbol)
                        .font(.system(size: 80, weight: .regular))
                        .foregroundStyle(.orange.opacity(0.85))
                        .scaleEffect(symbolScale)
                        .opacity(symbolOpacity)

                    OracleStrokeView(
                        strokes: data.oracleStrokes,
                        canvasSize: CGSize(width: 280, height: 280),
                        mode: .reveal,
                        progress: strokeProgress
                    )
                    .opacity(phase >= 1 ? 1 : 0)
                }

                if showMorph {
                    LearnFooter(
                        level: level,
                        data: data,
                        morphTriggered: true,
                        continueEnabled: true,
                        onContinue: { gameState.advanceLevel() }
                    )
                }
            }
            .frame(minHeight: 320)

            Spacer(minLength: 20)
        }
        .padding(.horizontal, 24)
        .task(id: level.id) {
            phase = 0; symbolScale = 1; symbolOpacity = 1; strokeProgress = 0; showMorph = false

            try? await Task.sleep(for: .milliseconds(800))
            withAnimation(.easeInOut(duration: 0.6)) { symbolScale = 0.5; symbolOpacity = 0.3 }
            phase = 1
            withAnimation(.easeInOut(duration: 1.2)) { strokeProgress = 1.0 }
            try? await Task.sleep(for: .milliseconds(1400))
            withAnimation(.easeOut(duration: 0.4)) { symbolOpacity = 0 }
            try? await Task.sleep(for: .milliseconds(500))
            phase = 2
            withAnimation(.easeInOut(duration: 0.3)) { showMorph = true }
        }
    }
}

// MARK: - 2. Trace (Level 2 · Moon)
// Oracle strokes as dotted guide; user traces over them.

private struct TraceLearnView: View {
    @Bindable var gameState: GameState
    let level: WebLevel
    let data: LearnCharacterData

    @State private var showMorph = false

    var body: some View {
        VStack(spacing: 20) {
            Text(level.title)
                .font(.system(.largeTitle, design: .serif, weight: .bold))
                .accessibilityAddTraits(.isHeader)
                .padding(.top, 20)

            Text(data.instruction)
                .font(.title3)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .frame(maxWidth: 600)

            if !showMorph {
                ZStack {
                    OracleStrokeView(
                        strokes: data.oracleStrokes,
                        canvasSize: CGSize(width: 340, height: 340),
                        mode: .guide,
                        progress: 1.0
                    )

                    TraceCanvasView(
                        guide: traceGuideFromOracle(data.oracleStrokes),
                        targetGlyph: "",
                        voiceOverModeEnabled: false,
                        resetKey: level.id,
                        progress: gameState.traceProgress,
                        showsGuide: false,
                        canvasSize: CGSize(width: 340, height: 340)
                    ) { points, didEnd in
                        gameState.updateTrace(points: points, didEnd: didEnd, guide: traceGuideFromOracle(data.oracleStrokes))
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

                VStack(spacing: 8) {
                    ProgressView(value: Double(gameState.traceProgress), total: 1.0)
                        .tint(.primary)
                        .frame(maxWidth: 340)

                    HStack(spacing: 8) {
                        Text("\(Int(gameState.traceProgress * 100))%")
                            .font(.callout.monospacedDigit())
                        Button("Confirm") {
                            gameState.confirmTrace()
                        }
                        .buttonStyle(.borderedProminent)
                        .disabled(gameState.traceProgress <= 0.01)
                    }
                }
            } else {
                LearnFooter(
                    level: level,
                    data: data,
                    morphTriggered: true,
                    continueEnabled: true,
                    onContinue: { gameState.advanceLevel() }
                )
            }

            Spacer()
        }
        .padding(.horizontal, 24)
        .onChange(of: gameState.traceCompleted) { _, completed in
            if completed {
                withAnimation(.easeInOut(duration: 0.4)) { showMorph = true }
            }
        }
        .task(id: level.id) {
            showMorph = false
        }
    }
}

// MARK: - 3 & 8. Draw from Memory (Person / Child)
// Flash oracle strokes briefly, then blank canvas for user to draw from memory.

private struct DrawFromMemoryLearnView: View {
    @Bindable var gameState: GameState
    let level: WebLevel
    let data: LearnCharacterData

    @State private var phase = 0 // 0=showing reference, 1=drawing, 2=morph
    @State private var drawProgress: CGFloat = 0
    @State private var resetKey = 0

    var body: some View {
        VStack(spacing: 20) {
            Text(level.title)
                .font(.system(.largeTitle, design: .serif, weight: .bold))
                .accessibilityAddTraits(.isHeader)
                .padding(.top, 20)

            Text(data.instruction)
                .font(.title3)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .frame(maxWidth: 600)

            if phase == 0 {
                VStack(spacing: 12) {
                    OracleStrokeView(
                        strokes: data.oracleStrokes,
                        canvasSize: CGSize(width: 280, height: 280),
                        mode: .full,
                        progress: 1.0
                    )
                    .frame(width: 300, height: 300)
                    .background(
                        RoundedRectangle(cornerRadius: 24, style: .continuous)
                            .fill(Color.white.opacity(0.78))
                    )

                    Text("Memorize this shape...")
                        .font(.callout)
                        .foregroundStyle(.secondary)
                }
                .transition(.opacity.combined(with: .scale))
            } else if phase == 1 {
                TraceCanvasView(
                    guide: traceGuideFromOracle(data.oracleStrokes),
                    targetGlyph: "",
                    voiceOverModeEnabled: false,
                    resetKey: level.id * 1000 + resetKey,
                    progress: drawProgress,
                    showsGuide: false,
                    canvasSize: CGSize(width: 340, height: 340)
                ) { points, _ in
                    let normalized = min(CGFloat(points.count) / 60, 1)
                    if normalized > drawProgress { drawProgress = normalized }
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

                HStack(spacing: 12) {
                    Button("Clear") { resetKey += 1; drawProgress = 0 }
                        .buttonStyle(.bordered)
                    Button("Done") {
                        guard drawProgress > 0.15 else { return }
                        withAnimation(.easeInOut(duration: 0.4)) { phase = 2 }
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(drawProgress <= 0.15)
                }
            } else {
                LearnFooter(
                    level: level,
                    data: data,
                    morphTriggered: true,
                    continueEnabled: true,
                    onContinue: { gameState.advanceLevel() }
                )
            }

            Spacer()
        }
        .padding(.horizontal, 24)
        .task(id: level.id) {
            phase = 0; drawProgress = 0; resetKey = 0
            try? await Task.sleep(for: .milliseconds(2000))
            withAnimation(.easeInOut(duration: 0.4)) { phase = 1 }
        }
    }
}

// MARK: - 4. Shake Reveal (Tree)
// Shows SF Symbol tree; user taps/shakes to reveal oracle strokes underneath.

private struct ShakeRevealLearnView: View {
    @Bindable var gameState: GameState
    let level: WebLevel
    let data: LearnCharacterData

    @State private var revealed = false
    @State private var showMorph = false
    @State private var crackOffset: CGFloat = 0
    @State private var tapCount = 0
    @State private var feedbackToken = 0

    var body: some View {
        VStack(spacing: 20) {
            Spacer(minLength: 16)

            Text(level.title)
                .font(.system(.largeTitle, design: .serif, weight: .bold))
                .accessibilityAddTraits(.isHeader)

            Text(data.instruction)
                .font(.title3)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .frame(maxWidth: 600)

            if !showMorph {
                ZStack {
                    OracleStrokeView(
                        strokes: data.oracleStrokes,
                        canvasSize: CGSize(width: 280, height: 280),
                        mode: .full,
                        progress: revealed ? 1.0 : 0.0
                    )
                    .opacity(revealed ? 1 : 0)

                    Image(systemName: data.sfSymbol)
                        .font(.system(size: 100, weight: .regular))
                        .foregroundStyle(.green.opacity(0.7))
                        .opacity(revealed ? 0 : 1)
                        .offset(x: crackOffset)
                }
                .frame(width: 320, height: 320)
                .contentShape(Rectangle())
                .onTapGesture {
                    tapCount += 1
                    feedbackToken += 1
                    withAnimation(.spring(response: 0.15, dampingFraction: 0.4)) {
                        crackOffset = tapCount.isMultiple(of: 2) ? -6 : 6
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                        withAnimation(.spring(response: 0.1, dampingFraction: 0.5)) { crackOffset = 0 }
                    }
                    if tapCount >= 3 {
                        withAnimation(.easeInOut(duration: 0.6)) { revealed = true }
                        Task {
                            try? await Task.sleep(for: .milliseconds(1200))
                            withAnimation(.easeInOut(duration: 0.3)) { showMorph = true }
                        }
                    }
                }
                .sensoryFeedback(.impact(weight: .light), trigger: feedbackToken)
                .accessibilityHint("Tap multiple times to reveal the oracle bone character")

                if !revealed {
                    Text("Tap to crack open")
                        .font(.callout)
                        .foregroundStyle(.secondary)
                }
            } else {
                LearnFooter(
                    level: level,
                    data: data,
                    morphTriggered: true,
                    continueEnabled: true,
                    onContinue: { gameState.advanceLevel() }
                )
            }

            Spacer(minLength: 20)
        }
        .padding(.horizontal, 24)
        .task(id: level.id) {
            revealed = false; showMorph = false; tapCount = 0; crackOffset = 0
        }
    }
}

// MARK: - 5. Tap Reveal (Mouth)
// Each tap draws one oracle stroke progressively.

private struct TapRevealLearnView: View {
    @Bindable var gameState: GameState
    let level: WebLevel
    let data: LearnCharacterData

    @State private var strokesRevealed = 0
    @State private var showMorph = false
    @State private var feedbackToken = 0

    var body: some View {
        VStack(spacing: 20) {
            Spacer(minLength: 16)

            Text(level.title)
                .font(.system(.largeTitle, design: .serif, weight: .bold))
                .accessibilityAddTraits(.isHeader)

            Text(data.instruction)
                .font(.title3)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .frame(maxWidth: 600)

            if !showMorph {
                OracleStrokeView(
                    strokes: data.oracleStrokes,
                    canvasSize: CGSize(width: 300, height: 300),
                    mode: .reveal,
                    progress: data.oracleStrokes.isEmpty ? 0 : CGFloat(strokesRevealed) / CGFloat(data.oracleStrokes.count)
                )
                .frame(width: 320, height: 320)
                .background(
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .fill(Color.white.opacity(0.6))
                )
                .contentShape(Rectangle())
                .onTapGesture {
                    guard strokesRevealed < data.oracleStrokes.count else { return }
                    feedbackToken += 1
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        strokesRevealed += 1
                    }
                    if strokesRevealed >= data.oracleStrokes.count {
                        Task {
                            try? await Task.sleep(for: .milliseconds(800))
                            withAnimation(.easeInOut(duration: 0.3)) { showMorph = true }
                        }
                    }
                }
                .sensoryFeedback(.impact(weight: .light), trigger: feedbackToken)
                .accessibilityHint("Tap to reveal each stroke")

                Text("\(strokesRevealed) / \(data.oracleStrokes.count) strokes")
                    .font(.callout.monospacedDigit())
                    .foregroundStyle(.secondary)
            } else {
                LearnFooter(
                    level: level,
                    data: data,
                    morphTriggered: true,
                    continueEnabled: true,
                    onContinue: { gameState.advanceLevel() }
                )
            }

            Spacer(minLength: 20)
        }
        .padding(.horizontal, 24)
        .task(id: level.id) {
            strokesRevealed = 0; showMorph = false
        }
    }
}

// MARK: - 6. Pulse Reveal (Heart)
// Pulsing circle with haptics; each pulse reveals a stroke.

private struct PulseRevealLearnView: View {
    @Bindable var gameState: GameState
    let level: WebLevel
    let data: LearnCharacterData

    @State private var strokesRevealed = 0
    @State private var pulseScale: CGFloat = 1.0
    @State private var showMorph = false
    @State private var pulseToken = 0
    @State private var autoRunning = true

    var body: some View {
        VStack(spacing: 20) {
            Spacer(minLength: 16)

            Text(level.title)
                .font(.system(.largeTitle, design: .serif, weight: .bold))
                .accessibilityAddTraits(.isHeader)

            Text(data.instruction)
                .font(.title3)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .frame(maxWidth: 600)

            if !showMorph {
                ZStack {
                    Circle()
                        .fill(Color.red.opacity(0.12))
                        .frame(width: 240, height: 240)
                        .scaleEffect(pulseScale)

                    OracleStrokeView(
                        strokes: data.oracleStrokes,
                        canvasSize: CGSize(width: 260, height: 260),
                        mode: .reveal,
                        progress: data.oracleStrokes.isEmpty ? 0 : CGFloat(strokesRevealed) / CGFloat(data.oracleStrokes.count)
                    )
                }
                .frame(width: 300, height: 300)
                .sensoryFeedback(.impact(weight: .medium), trigger: pulseToken)
            } else {
                LearnFooter(
                    level: level,
                    data: data,
                    morphTriggered: true,
                    continueEnabled: true,
                    onContinue: { gameState.advanceLevel() }
                )
            }

            Spacer(minLength: 20)
        }
        .padding(.horizontal, 24)
        .task(id: level.id) {
            strokesRevealed = 0; showMorph = false; autoRunning = true
            for i in 0..<data.oracleStrokes.count {
                guard autoRunning, !Task.isCancelled else { return }
                try? await Task.sleep(for: .milliseconds(900))
                pulseToken += 1
                withAnimation(.spring(response: 0.2, dampingFraction: 0.5)) { pulseScale = 1.12 }
                try? await Task.sleep(for: .milliseconds(200))
                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                    pulseScale = 1.0
                    strokesRevealed = i + 1
                }
            }
            try? await Task.sleep(for: .milliseconds(600))
            withAnimation(.easeInOut(duration: 0.3)) { showMorph = true }
        }
    }
}

// MARK: - 7. Silhouette Match (Woman)
// Shows 4 oracle shape options; user picks the correct one.

private struct SilhouetteMatchLearnView: View {
    @Bindable var gameState: GameState
    let level: WebLevel
    let data: LearnCharacterData

    @State private var selected: String? = nil
    @State private var showMorph = false
    @State private var feedbackToken = 0

    var body: some View {
        VStack(spacing: 20) {
            Spacer(minLength: 16)

            Text(level.title)
                .font(.system(.largeTitle, design: .serif, weight: .bold))
                .accessibilityAddTraits(.isHeader)

            Text(data.instruction)
                .font(.title3)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .frame(maxWidth: 600)

            if !showMorph {
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                    ForEach(data.distractorShapes) { shape in
                        let isSelected = selected == shape.id
                        let isCorrect = shape.isCorrect
                        Button {
                            guard selected == nil else { return }
                            selected = shape.id
                            feedbackToken += 1
                            if isCorrect {
                                Task {
                                    try? await Task.sleep(for: .milliseconds(800))
                                    withAnimation(.easeInOut(duration: 0.3)) { showMorph = true }
                                }
                            } else {
                                Task {
                                    try? await Task.sleep(for: .milliseconds(600))
                                    selected = nil
                                }
                            }
                        } label: {
                            ZStack {
                                RoundedRectangle(cornerRadius: 18, style: .continuous)
                                    .fill(isSelected ? (isCorrect ? Color.green.opacity(0.2) : Color.red.opacity(0.2)) : Color.white.opacity(0.6))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                                            .strokeBorder(isSelected ? (isCorrect ? Color.green : Color.red) : Color.secondary.opacity(0.2), lineWidth: 2)
                                    )

                                OracleStrokeView(
                                    strokes: shape.strokes,
                                    canvasSize: CGSize(width: 120, height: 120),
                                    mode: .full,
                                    progress: 1.0
                                )
                            }
                            .frame(height: 150)
                        }
                        .buttonStyle(.plain)
                        .accessibilityLabel(shape.label)
                        .accessibilityHint(shape.isCorrect ? "Correct match" : "Incorrect match")
                    }
                }
                .frame(maxWidth: 400)
                .sensoryFeedback(.impact(weight: .medium), trigger: feedbackToken)
            } else {
                LearnFooter(
                    level: level,
                    data: data,
                    morphTriggered: true,
                    continueEnabled: true,
                    onContinue: { gameState.advanceLevel() }
                )
            }

            Spacer(minLength: 20)
        }
        .padding(.horizontal, 24)
        .task(id: level.id) {
            selected = nil; showMorph = false
        }
    }
}

// MARK: - 9. Swipe Reveal (One)
// Single horizontal swipe draws the simplest oracle stroke.

private struct SwipeRevealLearnView: View {
    @Bindable var gameState: GameState
    let level: WebLevel
    let data: LearnCharacterData

    @State private var drawProgress: CGFloat = 0
    @State private var showMorph = false

    var body: some View {
        VStack(spacing: 20) {
            Spacer(minLength: 16)

            Text(level.title)
                .font(.system(.largeTitle, design: .serif, weight: .bold))
                .accessibilityAddTraits(.isHeader)

            Text(data.instruction)
                .font(.title3)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .frame(maxWidth: 600)

            if !showMorph {
                ZStack {
                    OracleStrokeView(
                        strokes: data.oracleStrokes,
                        canvasSize: CGSize(width: 320, height: 200),
                        mode: .reveal,
                        progress: drawProgress
                    )

                    if drawProgress < 0.01 {
                        Image(systemName: "arrow.right")
                            .font(.system(size: 36, weight: .light))
                            .foregroundStyle(.secondary.opacity(0.5))
                            .transition(.opacity)
                    }
                }
                .frame(width: 340, height: 220)
                .background(
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .fill(Color.white.opacity(0.6))
                )
                .contentShape(Rectangle())
                .gesture(
                    DragGesture(minimumDistance: 20)
                        .onChanged { value in
                            let normalized = min(max(value.translation.width / 260, 0), 1)
                            if normalized > drawProgress {
                                drawProgress = normalized
                            }
                        }
                        .onEnded { _ in
                            if drawProgress > 0.6 {
                                withAnimation(.easeOut(duration: 0.2)) { drawProgress = 1.0 }
                                Task {
                                    try? await Task.sleep(for: .milliseconds(600))
                                    withAnimation(.easeInOut(duration: 0.3)) { showMorph = true }
                                }
                            } else {
                                withAnimation(.easeOut(duration: 0.3)) { drawProgress = 0 }
                            }
                        }
                )
                .accessibilityHint("Swipe right to draw the stroke")
            } else {
                LearnFooter(
                    level: level,
                    data: data,
                    morphTriggered: true,
                    continueEnabled: true,
                    onContinue: { gameState.advanceLevel() }
                )
            }

            Spacer(minLength: 20)
        }
        .padding(.horizontal, 24)
        .task(id: level.id) {
            drawProgress = 0; showMorph = false
        }
    }
}

// MARK: - Helper: Convert OracleStroke array to TraceGuide

func traceGuideFromOracle(_ strokes: [OracleStroke]) -> TraceGuide {
    TraceGuide(
        strokes: strokes.map { TraceStroke(points: $0.points) },
        completionThreshold: 0.55
    )
}
