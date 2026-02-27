import AVFoundation
import Observation
import SwiftUI

// MARK: - VoiceGuideItem

struct VoiceGuideItem: Identifiable {
    enum Kind {
        case header
        case body
        case image
        case state
        case control
    }

    let id: String
    let text: String
    let kind: Kind

    init(id: String = UUID().uuidString, text: String, kind: Kind = .body) {
        self.id = id
        self.text = text
        self.kind = kind
    }
}

// MARK: - Speech Rate Preset

enum VoiceGuideSpeechRate: CaseIterable, Identifiable {
    case slow
    case normal
    case fast

    var id: Self { self }

    var label: String {
        switch self {
        case .slow:   return "Slow"
        case .normal: return "Normal"
        case .fast:   return "Fast"
        }
    }

    var avRate: Float {
        switch self {
        case .slow:   return AVSpeechUtteranceMinimumSpeechRate + (AVSpeechUtteranceDefaultSpeechRate - AVSpeechUtteranceMinimumSpeechRate) * 0.4
        case .normal: return AVSpeechUtteranceDefaultSpeechRate
        case .fast:   return AVSpeechUtteranceDefaultSpeechRate + (AVSpeechUtteranceMaximumSpeechRate - AVSpeechUtteranceDefaultSpeechRate) * 0.35
        }
    }
}

// MARK: - VoiceGuidePlayer

@Observable @MainActor
final class VoiceGuidePlayer: NSObject {

    // MARK: Settings (persisted via GameState)
    var isEnabled: Bool = false
    var speechRate: VoiceGuideSpeechRate = .normal
    var autoReadOnScreenChange: Bool = true

    // MARK: Playback state
    private(set) var isSpeaking: Bool = false
    private(set) var items: [VoiceGuideItem] = []
    private(set) var currentIndex: Int = 0

    var hasItems: Bool { !items.isEmpty }
    var hasPrevious: Bool { currentIndex > 0 }
    var hasNext: Bool { currentIndex < items.count - 1 }

    var currentItem: VoiceGuideItem? {
        guard items.indices.contains(currentIndex) else { return nil }
        return items[currentIndex]
    }

    var currentIndexDisplay: String {
        guard hasItems else { return "" }
        return "\(currentIndex + 1) / \(items.count)"
    }

    // MARK: Private
    private let synthesizer = AVSpeechSynthesizer()
    // Whether system VoiceOver is currently active (set from the view layer).
    var systemVoiceOverActive: Bool = false

    override init() {
        super.init()
        synthesizer.delegate = self
    }

    // MARK: - Public API

    func load(items: [VoiceGuideItem], playImmediately: Bool = true) {
        stopInternal()
        self.items = items
        self.currentIndex = 0
        if playImmediately && isEnabled && !systemVoiceOverActive {
            playFromCurrent()
        }
    }

    func play() {
        guard isEnabled, !systemVoiceOverActive else { return }
        if isSpeaking {
            synthesizer.continueSpeaking()
        } else {
            playFromCurrent()
        }
    }

    func pause() {
        synthesizer.pauseSpeaking(at: .word)
        isSpeaking = false
    }

    func stop() {
        stopInternal()
    }

    func next() {
        guard hasNext else { return }
        stopInternal()
        currentIndex += 1
        if isEnabled && !systemVoiceOverActive {
            playFromCurrent()
        }
    }

    func previous() {
        guard hasPrevious else { return }
        stopInternal()
        currentIndex -= 1
        if isEnabled && !systemVoiceOverActive {
            playFromCurrent()
        }
    }

    func repeatCurrent() {
        stopInternal()
        if isEnabled && !systemVoiceOverActive {
            playFromCurrent()
        }
    }

    func speakImmediate(_ text: String) {
        guard isEnabled && !systemVoiceOverActive else { return }
        stopInternal()
        speak(text: text)
    }

    // MARK: - Private helpers

    private func playFromCurrent() {
        guard let item = currentItem else { return }
        speak(text: item.text)
    }

    private func speak(text: String) {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            advanceAutomatically()
            return
        }
        let utterance = AVSpeechUtterance(string: trimmed)
        utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        utterance.rate = speechRate.avRate
        utterance.pitchMultiplier = 1.0
        utterance.postUtteranceDelay = 0.12
        isSpeaking = true
        synthesizer.speak(utterance)
    }

    private func stopInternal() {
        if synthesizer.isSpeaking || synthesizer.isPaused {
            synthesizer.stopSpeaking(at: .immediate)
        }
        isSpeaking = false
    }

    private func advanceAutomatically() {
        guard hasNext else {
            isSpeaking = false
            return
        }
        currentIndex += 1
        playFromCurrent()
    }
}

// MARK: - AVSpeechSynthesizerDelegate

extension VoiceGuidePlayer: AVSpeechSynthesizerDelegate {
    nonisolated func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        Task { @MainActor [weak self] in
            guard let self else { return }
            self.advanceAutomatically()
        }
    }

    nonisolated func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didCancel utterance: AVSpeechUtterance) {
        Task { @MainActor [weak self] in
            self?.isSpeaking = false
        }
    }
}
