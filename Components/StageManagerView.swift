import Observation
import SwiftUI

struct StageManagerView: View {
    @Bindable var gameState: GameState
    @State private var audioFeedbackToken = 0

    var body: some View {
        Group {
            if let level = gameState.currentLevel {
                switch level.type {
                case .tracing:
                    TracingView(gameState: gameState, level: level)
                case .quiz:
                    QuizView(gameState: gameState, level: level)
                case .combination:
                    CombinationView(gameState: gameState, level: level)
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
                Text("Chapter \(gameState.currentLevel?.id ?? 0) / \(gameState.levels.count)")
                    .font(.footnote.monospacedDigit())
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(.thinMaterial, in: Capsule(style: .continuous))
                    .accessibilityLabel("Current chapter \(gameState.currentLevel?.id ?? 0) of \(gameState.levels.count)")
            }
        }
        .safeAreaInset(edge: .bottom) {
            HStack {
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
}

private struct StageMenuFullScreen: View {
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

                        LazyVGrid(columns: Array(repeating: GridItem(.flexible(minimum: 58)), count: 5), spacing: 12) {
                            ForEach(Array(gameState.levels.enumerated()), id: \.element.id) { index, level in
                                Button {
                                    gameState.jumpToLevel(index)
                                } label: {
                                    VStack(spacing: 4) {
                                        Text("\(level.id)")
                                            .font(.headline)
                                        Text(level.displayTitle(mode: gameState.scriptDisplayMode))
                                            .font(.caption2)
                                            .lineLimit(1)
                                    }
                                    .frame(maxWidth: .infinity, minHeight: 58)
                                    .padding(.vertical, 8)
                                }
                                .buttonStyle(.borderedProminent)
                                .tint(index == gameState.currentLevelIndex ? .orange : .white.opacity(0.14))
                                .foregroundStyle(index == gameState.currentLevelIndex ? .black : .white)
                                .accessibilityLabel("Jump to chapter \(level.id)")
                                .accessibilityHint("Open chapter \(level.id)")
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
