import SwiftUI

struct ContentView: View {
    @Environment(\.scenePhase) private var scenePhase
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
            // #region agent log
            AgentRuntimeDebugLogger.log(
                hypothesisID: "H2",
                location: "ContentView.swift:34",
                message: "ContentView onAppear",
                data: [
                    "flowState": "\(gameState.flowState)",
                    "routePathCount": routePath.count,
                    "gameStateID": ObjectIdentifier(gameState).hashValue,
                ]
            )
            // #endregion
            syncRoute(for: gameState.flowState)
        }
        .onChange(of: gameState.flowState) { _, newValue in
            // #region agent log
            AgentRuntimeDebugLogger.log(
                hypothesisID: "H2",
                location: "ContentView.swift:37",
                message: "flowState changed",
                data: [
                    "newFlowState": "\(newValue)",
                    "routePathBefore": routePath.map { "\($0)" }.joined(separator: ","),
                    "gameStateID": ObjectIdentifier(gameState).hashValue,
                ]
            )
            // #endregion
            syncRoute(for: newValue)
        }
        .onChange(of: scenePhase) { _, newValue in
            // #region agent log
            AgentRuntimeDebugLogger.log(
                hypothesisID: "H15",
                location: "ContentView.swift:66",
                message: "ContentView scenePhase changed",
                data: [
                    "scenePhase": "\(newValue)",
                    "flowState": "\(gameState.flowState)",
                    "routePath": routePath.map { "\($0)" }.joined(separator: ","),
                    "routePathCount": routePath.count,
                    "gameStateID": ObjectIdentifier(gameState).hashValue,
                ]
            )
            // #endregion
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
        // #region agent log
        AgentRuntimeDebugLogger.log(
            hypothesisID: "H2",
            location: "ContentView.swift:56",
            message: "syncRoute applied",
            data: [
                "flowState": "\(flowState)",
                "routePathAfter": routePath.map { "\($0)" }.joined(separator: ","),
                "routePathCount": routePath.count,
                "gameStateID": ObjectIdentifier(gameState).hashValue,
            ]
        )
        // #endregion
    }
}

private enum AppRoute: Hashable {
    case playing
    case ending
}
