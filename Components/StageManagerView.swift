import Observation
import SwiftUI

struct StageManagerView: View {
    @Environment(\.accessibilityVoiceOverEnabled) private var voiceOverEnabled
    @Bindable var gameState: GameState
    @State private var audioFeedbackToken = 0

    // Convenience shorthand
    private var guide: VoiceGuidePlayer { gameState.voiceGuide }

    var body: some View {
        Group {
            if let level = gameState.currentLevel {
                switch level.type {
                case .learn:
                    LearnCharacterView(gameState: gameState, level: level)
                case .observe:
                    ObserveView(gameState: gameState, level: level)
                case .tracing:
                    TracingView(gameState: gameState, level: level)
                case .draw:
                    DrawView(gameState: gameState, level: level)
                case .quiz:
                    QuizView(gameState: gameState, level: level)
                case .drag:
                    DragLevelView(gameState: gameState, level: level)
                case .combination:
                    CombinationView(gameState: gameState, level: level)
                case .guess:
                    GuessView(gameState: gameState, level: level)
                case .free:
                    FreeView(gameState: gameState, level: level)
                }
            } else {
                fallbackView
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .navigationTitle("Oracle Journey")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    gameState.showLevelMenu = true
                } label: {
                    Label("Chapter Menu", systemImage: "square.grid.2x2")
                        .labelStyle(.iconOnly)
                }
                .accessibilityLabel("Open chapter menu")
                .accessibilityHint("Show all game chapters")
                .frame(minWidth: 44, minHeight: 44)
            }

            ToolbarItem(placement: .topBarTrailing) {
                Text("Chapter \(gameState.currentLevel?.id ?? 0) / \(gameState.levels.count) · \((gameState.currentLevel?.emotion.rawValue ?? "").capitalized)")
                    .font(.footnote.monospacedDigit())
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(.thinMaterial, in: Capsule(style: .continuous))
                    .accessibilityLabel("Current chapter \(gameState.currentLevel?.id ?? 0) of \(gameState.levels.count)")
            }
        }
        .safeAreaInset(edge: .bottom) {
            VStack(spacing: 8) {
                // ── VoiceGuide control bar (only visible when enabled & system VO is off) ──
                if guide.isEnabled && !voiceOverEnabled {
                    VoiceGuideControlsBar(player: guide)
                        .padding(.horizontal, 14)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                }
                // ── Bottom icon strip ─────────────────────────────────────────────────────
                HStack(spacing: 12) {
                    voiceGuideToggle
                    voiceOverPreviewToggle
                    Spacer()
                    audioControl
                }
                .padding(.horizontal, 18)
                .padding(.vertical, 8)
            }
            .padding(.bottom, 2)
        }
        .fullScreenCover(isPresented: $gameState.showLevelMenu) {
            StageMenuFullScreen(gameState: gameState)
        }
        .sensoryFeedback(.selection, trigger: audioFeedbackToken)
        // Keep systemVoiceOverActive in sync so VoiceGuidePlayer skips AVSpeech when VO is on.
        .onChange(of: voiceOverEnabled, initial: true) { _, newValue in
            guide.systemVoiceOverActive = newValue
            if newValue {
                guide.isEnabled = true
            }
        }
        // Auto-reload script when the chapter changes.
        .onChange(of: gameState.currentLevelIndex, initial: true) { _, _ in
            if guide.isEnabled && !voiceOverEnabled {
                reloadAndPlay()
            }
        }
    }

    // MARK: - Script loading helper

    private func reloadAndPlay() {
        let script = VoiceGuideScriptBuilder.build(from: gameState)
        guide.load(items: script, playImmediately: guide.autoReadOnScreenChange)
    }

    // MARK: - Sub-views

    private var fallbackView: some View {
        VStack(spacing: 12) {
            ProgressView()
            Text("Loading chapter...")
                .font(.callout)
                .foregroundStyle(.secondary)
            Button("Back to Intro") {
                gameState.restartJourney()
            }
            .buttonStyle(.bordered)
        }
    }

    private var audioControl: some View {
        Button {
            withAnimation(GameState.MotionContract.standardSpring) {
                gameState.audioEnabled.toggle()
            }
            audioFeedbackToken += 1
        } label: {
            Image(systemName: gameState.audioEnabled ? "speaker.wave.2.fill" : "speaker.slash.fill")
                .symbolEffect(.bounce, value: gameState.audioEnabled)
                .font(.title3.weight(.semibold))
                .frame(width: 44, height: 44)
                .accessibilityHidden(true)
        }
        .buttonStyle(.borderedProminent)
        .tint(.black.opacity(0.74))
        .foregroundStyle(.white)
        .accessibilityLabel(gameState.audioEnabled ? "Turn audio off" : "Turn audio on")
        .accessibilityHint("Toggle icon-only sound state")
    }

    // MARK: - VoiceGuide toggle

    private var voiceGuideToggle: some View {
        Toggle(isOn: Binding(
            get: { guide.isEnabled },
            set: { newValue in
                withAnimation(GameState.MotionContract.microEase) {
                    guide.isEnabled = newValue
                }
                if newValue && !voiceOverEnabled {
                    reloadAndPlay()
                } else if !newValue {
                    guide.stop()
                }
            }
        )) {
            Label("Voice Guide", systemImage: "ear")
                .font(.footnote.weight(.semibold))
                .labelStyle(.titleAndIcon)
        }
        .toggleStyle(.switch)
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(.thinMaterial, in: Capsule(style: .continuous))
        .accessibilityLabel("Voice Guide")
        .accessibilityHint(
            guide.isEnabled
                ? "In-app narration is on. Toggle to turn off."
                : "Turn on in-app narration that reads each screen aloud."
        )
    }

    // MARK: - VoiceOver preview binding / toggle

    private var voiceOverPreviewBinding: Binding<Bool> {
        Binding(
            get: { voiceOverEnabled || gameState.a11yPreviewVoiceOverEnabled },
            set: { newValue in
                guard !voiceOverEnabled else { return }
                withAnimation(GameState.MotionContract.microEase) {
                    gameState.a11yPreviewVoiceOverEnabled = newValue
                }
            }
        )
    }

    private var voiceOverPreviewToggle: some View {
        Toggle(isOn: voiceOverPreviewBinding) {
            Text("VoiceOver Preview")
                .font(.footnote.weight(.semibold))
        }
        .toggleStyle(.switch)
        .disabled(voiceOverEnabled)
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(.thinMaterial, in: Capsule(style: .continuous))
        .accessibilityLabel("VoiceOver preview")
        .accessibilityHint(
            voiceOverEnabled
                ? "System VoiceOver is enabled."
                : "Show VoiceOver-friendly controls without turning on system VoiceOver."
        )
    }

    private var readScreenButton: some View {
        Button {
            A11yNarrator.speak(a11yNarrationText)
        } label: {
            Image(systemName: "speaker.wave.2.fill")
                .font(.title3.weight(.semibold))
                .frame(width: 44, height: 44)
                .accessibilityHidden(true)
        }
        .buttonStyle(.bordered)
        .accessibilityLabel("Read screen")
        .accessibilityHint("Speak the current screen summary")
    }

    private var a11yNarrationText: String {
        guard let level = gameState.currentLevel else {
            return "Loading chapter."
        }
        let title = level.displayTitle(mode: gameState.scriptDisplayMode)
        let header = "Chapter \(level.id) of \(gameState.levels.count). \(title)."

        switch level.type {
        case .learn:
            if let learn = level.learn {
                return "\(header) \(learn.instruction) Character: \(learn.modernGlyph). Meaning: \(learn.meaning)."
            }
        case .observe:
            if let observe = level.observe {
                return "\(header) \(observe.instruction) \(observe.detail) World symbol: \(observe.worldSymbol). Oracle glyph: \(observe.oracleGlyph). Modern glyph: \(observe.modernGlyph)."
            }
        case .tracing:
            if let tracing = level.tracing {
                let meaning = tracing.displayMeaning(mode: gameState.scriptDisplayMode)
                let character = tracing.displayCharacter(mode: gameState.scriptDisplayMode)
                let explanation = tracing.displayExplanation(mode: gameState.scriptDisplayMode)
                return "\(header) Trace \(character). Meaning: \(meaning). \(explanation)"
            }
        case .draw:
            if let draw = level.draw {
                let meaning = draw.displayMeaning(mode: gameState.scriptDisplayMode)
                let character = draw.displayCharacter(mode: gameState.scriptDisplayMode)
                let instruction = draw.displayInstruction(mode: gameState.scriptDisplayMode)
                return "\(header) \(instruction) Draw \(character). Meaning: \(meaning)."
            }
        case .quiz:
            if let quiz = level.quiz {
                let question = quiz.displayQuestion(mode: gameState.scriptDisplayMode)
                return "\(header) \(question)"
            }
        case .drag:
            if let drag = level.drag {
                let instruction = drag.displayInstruction(mode: gameState.scriptDisplayMode)
                let targetMeaning = drag.displayTargetMeaning(mode: gameState.scriptDisplayMode)
                return "\(header) \(instruction) Target: \(drag.targetChar). \(targetMeaning)."
            }
        case .combination:
            if let combination = level.combination {
                let instruction = combination.displayInstruction(mode: gameState.scriptDisplayMode)
                let targetMeaning = combination.displayTargetMeaning(mode: gameState.scriptDisplayMode)
                return "\(header) \(instruction) Target: \(combination.targetChar). \(targetMeaning)."
            }
        case .guess:
            if let guess = level.guess {
                let instruction = guess.displayInstruction(mode: gameState.scriptDisplayMode)
                return "\(header) \(instruction) Result: \(guess.resultGlyph)."
            }
        case .free:
            if let free = level.free {
                let instruction = free.displayInstruction(mode: gameState.scriptDisplayMode)
                return "\(header) \(instruction) Form \(free.targetCount) characters."
            }
        }

        return header
    }
}

private struct StageMenuFullScreen: View {
    @Environment(\.colorSchemeContrast) private var colorSchemeContrast
    @Bindable var gameState: GameState

    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.opacity(0.78)
                    .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 18) {
                        Text("Select Chapter")
                            .font(.largeTitle.bold())
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .accessibilityAddTraits(.isHeader)

                        LazyVGrid(columns: Array(repeating: GridItem(.flexible(minimum: 58)), count: 5), spacing: 12) {
                            ForEach(Array(gameState.levels.enumerated()), id: \.element.id) { index, level in
                                let isCurrent = index == gameState.currentLevelIndex
                                let isCompleted = index < gameState.currentLevelIndex
                                let unselectedTint = colorSchemeContrast == .increased ? Color.white.opacity(0.22) : Color.white.opacity(0.14)
                                Button {
                                    gameState.jumpToLevel(index)
                                } label: {
                                    ZStack(alignment: .topTrailing) {
                                        VStack(spacing: 6) {
                                            Text("\(level.id)")
                                                .font(.headline)
                                            Text("Chapter")
                                                .font(.caption2.smallCaps())
                                                .opacity(0.78)
                                        }
                                        if isCurrent {
                                            Image(systemName: "checkmark.circle.fill")
                                                .font(.caption.weight(.bold))
                                                .foregroundStyle(.black.opacity(0.85))
                                                .padding(6)
                                                .accessibilityHidden(true)
                                        } else if isCompleted {
                                            Image(systemName: "smallcircle.filled.circle.fill")
                                                .font(.caption2.weight(.bold))
                                                .foregroundStyle(.white.opacity(0.86))
                                                .padding(6)
                                                .accessibilityHidden(true)
                                        }
                                    }
                                    .frame(maxWidth: .infinity, minHeight: 58)
                                    .padding(.vertical, 8)
                                }
                                .buttonStyle(.borderedProminent)
                                .tint(isCurrent ? .orange : unselectedTint)
                                .foregroundStyle(isCurrent ? .black : .white)
                                .accessibilityLabel("Jump to chapter \(level.id)")
                                .accessibilityValue(isCurrent ? "Current chapter" : "")
                                .accessibilityHint("Open chapter \(level.id)")
                                .accessibilityAddTraits(isCurrent ? .isSelected : [])
                            }
                        }
                    }
                    .padding(22)
                    .frame(maxWidth: 620)
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Close") {
                        gameState.showLevelMenu = false
                    }
                    .foregroundStyle(.white)
                    .frame(minWidth: 44, minHeight: 44)
                }
            }
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarBackground(Color.black.opacity(0.35), for: .navigationBar)
        }
    }

}
