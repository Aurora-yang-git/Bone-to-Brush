import SwiftUI
#if canImport(UIKit)
import UIKit
#endif

@main
struct MyApp: App {
    @Environment(\.scenePhase) private var scenePhase

    var body: some Scene {
        WindowGroup {
            ContentView()
                .onAppear {
                    // #region agent log
                    AgentRuntimeDebugLogger.log(
                        hypothesisID: "H8",
                        location: "MyApp.swift:10",
                        message: "WindowGroup ContentView onAppear",
                        data: ["scenePhase": "\(scenePhase)"]
                    )
                    // #endregion
                }
                .onChange(of: scenePhase) { _, newValue in
                    // #region agent log
                    AgentRuntimeDebugLogger.log(
                        hypothesisID: "H8",
                        location: "MyApp.swift:18",
                        message: "scenePhase changed",
                        data: ["newScenePhase": "\(newValue)"]
                    )
                    // #endregion
                }
#if canImport(UIKit)
                .onReceive(NotificationCenter.default.publisher(for: UIApplication.didReceiveMemoryWarningNotification)) { _ in
                    // #region agent log
                    AgentRuntimeDebugLogger.log(
                        hypothesisID: "H13",
                        location: "MyApp.swift:34",
                        message: "UIApplication memory warning",
                        data: [:]
                    )
                    // #endregion
                }
                .onReceive(NotificationCenter.default.publisher(for: UIApplication.willResignActiveNotification)) { _ in
                    // #region agent log
                    AgentRuntimeDebugLogger.log(
                        hypothesisID: "H13",
                        location: "MyApp.swift:45",
                        message: "UIApplication will resign active",
                        data: [:]
                    )
                    // #endregion
                }
                .onReceive(NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)) { _ in
                    // #region agent log
                    AgentRuntimeDebugLogger.log(
                        hypothesisID: "H13",
                        location: "MyApp.swift:56",
                        message: "UIApplication did become active",
                        data: [:]
                    )
                    // #endregion
                }
                .onReceive(NotificationCenter.default.publisher(for: UIApplication.didEnterBackgroundNotification)) { _ in
                    // #region agent log
                    AgentRuntimeDebugLogger.log(
                        hypothesisID: "H13",
                        location: "MyApp.swift:67",
                        message: "UIApplication did enter background",
                        data: [:]
                    )
                    // #endregion
                }
#endif
        }
    }
}
