import Observation
import SwiftUI

struct StageManagerView: View {
    @Environment(\.scenePhase) private var scenePhase
    @Environment(\.accessibilityVoiceOverEnabled) private var voiceOverEnabled
    @Bindable var gameState: GameState
    @State private var audioFeedbackToken = 0

    var body: some View {
        Group {
            if let level = gameState.currentLevel {
                switch level.type {
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
                    // #region agent log
                    AgentRuntimeDebugLogger.log(
                        hypothesisID: "H9",
                        location: "StageManagerView.swift:39",
                        message: "Chapter menu button tapped",
                        data: [
                            "flowState": "\(gameState.flowState)",
                            "currentLevelIndex": gameState.currentLevelIndex,
                            "showLevelMenuBefore": gameState.showLevelMenu,
                        ]
                    )
                    // #endregion
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
            HStack(spacing: 12) {
                voiceOverPreviewToggle
                Spacer()
                audioControl
            }
            .padding(.horizontal, 18)
            .padding(.vertical, 12)
        }
        .fullScreenCover(isPresented: $gameState.showLevelMenu) {
            StageMenuFullScreen(gameState: gameState)
        }
        .sensoryFeedback(.selection, trigger: audioFeedbackToken)
        .task(id: gameState.currentLevelIndex) {
            // #region agent log
            AgentRuntimeDebugLogger.log(
                hypothesisID: "H3",
                location: "StageManagerView.swift:72",
                message: "StageManager level task fired",
                data: [
                    "flowState": "\(gameState.flowState)",
                    "currentLevelIndex": gameState.currentLevelIndex,
                    "currentLevelExists": gameState.currentLevel != nil,
                    "currentLevelType": "\(String(describing: gameState.currentLevel?.type))",
                    "hasObserveData": gameState.currentLevel?.observe != nil,
                    "showLevelMenu": gameState.showLevelMenu,
                ]
            )
            // #endregion
        }
        .onChange(of: gameState.showLevelMenu) { _, newValue in
            // #region agent log
            AgentRuntimeDebugLogger.log(
                hypothesisID: "H5",
                location: "StageManagerView.swift:88",
                message: "showLevelMenu changed",
                data: [
                    "showLevelMenu": newValue,
                    "flowState": "\(gameState.flowState)",
                    "currentLevelIndex": gameState.currentLevelIndex,
                ]
            )
            // #endregion
        }
        .onAppear {
            // #region agent log
            AgentRuntimeDebugLogger.log(
                hypothesisID: "H10",
                location: "StageManagerView.swift:97",
                message: "StageManager onAppear",
                data: [
                    "flowState": "\(gameState.flowState)",
                    "currentLevelIndex": gameState.currentLevelIndex,
                    "showLevelMenu": gameState.showLevelMenu,
                ]
            )
            // #endregion
        }
        .onDisappear {
            // #region agent log
            AgentRuntimeDebugLogger.log(
                hypothesisID: "H10",
                location: "StageManagerView.swift:110",
                message: "StageManager onDisappear",
                data: [
                    "flowState": "\(gameState.flowState)",
                    "currentLevelIndex": gameState.currentLevelIndex,
                    "showLevelMenu": gameState.showLevelMenu,
                ]
            )
            // #endregion
        }
        .task(id: "\(gameState.currentLevelIndex)-\(gameState.flowState)") {
            for tick in 1...8 {
                try? await Task.sleep(for: .seconds(1))
                guard !Task.isCancelled else { return }
                // #region agent log
                AgentRuntimeDebugLogger.log(
                    hypothesisID: "H16",
                    location: "StageManagerView.swift:130",
                    message: "StageManager heartbeat",
                    data: [
                        "tick": tick,
                        "scenePhase": "\(scenePhase)",
                        "flowState": "\(gameState.flowState)",
                        "currentLevelIndex": gameState.currentLevelIndex,
                        "showLevelMenu": gameState.showLevelMenu,
                    ]
                )
                // #endregion
            }
        }
    }

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
            .onAppear {
                // #region agent log
                AgentRuntimeDebugLogger.log(
                    hypothesisID: "H9",
                    location: "StageManagerView.swift:190",
                    message: "StageMenuFullScreen onAppear",
                    data: [
                        "flowState": "\(gameState.flowState)",
                        "currentLevelIndex": gameState.currentLevelIndex,
                    ]
                )
                // #endregion
            }
            .onDisappear {
                // #region agent log
                AgentRuntimeDebugLogger.log(
                    hypothesisID: "H9",
                    location: "StageManagerView.swift:203",
                    message: "StageMenuFullScreen onDisappear",
                    data: [
                        "flowState": "\(gameState.flowState)",
                        "currentLevelIndex": gameState.currentLevelIndex,
                    ]
                )
                // #endregion
            }
        }
    }

}
