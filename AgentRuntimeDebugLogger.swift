import Foundation

enum AgentRuntimeDebugLogger {
    private static let logPath = "/Users/aurora/Library/Mobile Documents/iCloud~com~apple~Playgrounds/Documents/bone to brush/.cursor/debug-1cf799.log"
    private static let sessionID = "1cf799"
    private static let processID = ProcessInfo.processInfo.processIdentifier
    private static let processBootUptimeMS = Int(ProcessInfo.processInfo.systemUptime * 1000)

    static func log(
        runID: String = "pre-fix",
        hypothesisID: String,
        location: String,
        message: String,
        data: [String: Any] = [:]
    ) {
        let payload: [String: Any] = [
            "sessionId": sessionID,
            "runId": runID,
            "hypothesisId": hypothesisID,
            "location": location,
            "message": message,
            "data": data,
            "processId": processID,
            "processBootUptimeMS": processBootUptimeMS,
            "timestamp": Int(Date().timeIntervalSince1970 * 1000),
        ]

        guard
            let json = try? JSONSerialization.data(withJSONObject: payload),
            var line = String(data: json, encoding: .utf8)
        else { return }

        line.append("\n")
        guard let encoded = line.data(using: .utf8) else { return }

        if let handle = FileHandle(forWritingAtPath: logPath) {
            try? handle.seekToEnd()
            handle.write(encoded)
            try? handle.close()
        } else {
            try? encoded.write(to: URL(fileURLWithPath: logPath))
        }
    }
}
