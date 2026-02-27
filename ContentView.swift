import SwiftUI

struct ContentView: View {
    @State private var gameState = GameState()
    @State private var routePath: [AppRoute] = []

    var body: some View {
        NavigationStack(path: $routePath) {
            IntroView(gameState: gameState)
                .navigationBarBackButtonHidden(true)
                .navigationDestination(for: AppRoute.self) { route in
                    switch route {
                    case .playing:
                        StageManagerView(gameState: gameState)
                            .navigationBarBackButtonHidden(true)
                    case .ending:
                        EndingView(gameState: gameState)
                            .navigationBarBackButtonHidden(true)
                    }
                }
        }
        .background {
            LinearGradient(
                colors: [
                    Color(red: 0.99, green: 0.98, blue: 0.96),
                    Color(red: 0.95, green: 0.93, blue: 0.88),
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
                .ignoresSafeArea()
        }
        .onAppear {
            syncRoute(for: gameState.flowState)
        }
        .onChange(of: gameState.flowState) { _, newValue in
            syncRoute(for: newValue)
        }
    }

    private func syncRoute(for flowState: AppFlowState) {
        switch flowState {
        case .intro:
            if !routePath.isEmpty {
                routePath.removeAll()
            }
        case .playing:
            if routePath != [.playing] {
                routePath = [.playing]
            }
        case .ending:
            if routePath != [.playing, .ending] {
                routePath = [.playing, .ending]
            }
        }
    }
}

private enum AppRoute: Hashable {
    case playing
    case ending
}
