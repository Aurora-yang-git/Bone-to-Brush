import AudioToolbox

enum CreationFeedback {
    static func playMergeSound(audioEnabled: Bool) {
        guard audioEnabled else { return }
        // System click keeps package size small while still adding tactile rhythm.
        AudioServicesPlaySystemSound(1113)
    }
}
