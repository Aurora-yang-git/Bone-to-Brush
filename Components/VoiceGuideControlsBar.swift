import SwiftUI

// MARK: - VoiceGuideControlsBar
// A compact, accessible horizontal control bar for the in-app VoiceGuide.
// Shown only when VoiceGuide is enabled and the system VoiceOver is NOT active.

struct VoiceGuideControlsBar: View {
    @Bindable var player: VoiceGuidePlayer

    var body: some View {
        VStack(spacing: 0) {
            // ── Current item preview ─────────────────────────────────────
            if let item = player.currentItem, player.hasItems {
                Text(item.text)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 14)
                    .padding(.top, 8)
                    .padding(.bottom, 4)
                    .transition(.opacity)
                    .id(item.id)
                    .accessibilityLabel("Currently reading: \(item.text)")
            }

            // ── Control row ──────────────────────────────────────────────
            HStack(spacing: 6) {
                // Previous
                controlButton(
                    icon: "backward.fill",
                    label: "Previous",
                    hint: "Go to previous narration segment"
                ) {
                    player.previous()
                }
                .disabled(!player.hasPrevious)

                // Play / Pause
                controlButton(
                    icon: player.isSpeaking ? "pause.fill" : "play.fill",
                    label: player.isSpeaking ? "Pause" : "Play",
                    hint: player.isSpeaking ? "Pause narration" : "Play narration"
                ) {
                    if player.isSpeaking {
                        player.pause()
                    } else {
                        player.play()
                    }
                }
                .symbolEffect(.bounce, value: player.isSpeaking)

                // Next
                controlButton(
                    icon: "forward.fill",
                    label: "Next",
                    hint: "Go to next narration segment"
                ) {
                    player.next()
                }
                .disabled(!player.hasNext)

                // Repeat
                controlButton(
                    icon: "repeat.1",
                    label: "Repeat",
                    hint: "Repeat current segment"
                ) {
                    player.repeatCurrent()
                }

                Spacer()

                // Progress label
                if player.hasItems {
                    Text(player.currentIndexDisplay)
                        .font(.caption2.monospacedDigit())
                        .foregroundStyle(.secondary)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(.thinMaterial, in: Capsule(style: .continuous))
                        .accessibilityLabel("Segment \(player.currentIndexDisplay)")
                }

                // Speech rate picker
                Menu {
                    ForEach(VoiceGuideSpeechRate.allCases) { rate in
                        Button {
                            player.speechRate = rate
                        } label: {
                            HStack {
                                Text(rate.label)
                                if player.speechRate == rate {
                                    Image(systemName: "checkmark")
                                }
                            }
                        }
                    }
                } label: {
                    Image(systemName: "gauge.medium")
                        .font(.callout.weight(.semibold))
                        .frame(width: 44, height: 44)
                }
                .buttonStyle(.bordered)
                .accessibilityLabel("Speech rate: \(player.speechRate.label)")
                .accessibilityHint("Change narration speed")
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
        }
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .strokeBorder(Color.secondary.opacity(0.18), lineWidth: 1)
        )
        .animation(GameState.MotionContract.microEase, value: player.currentIndex)
        .animation(GameState.MotionContract.microEase, value: player.isSpeaking)
    }

    // MARK: - Helper

    @ViewBuilder
    private func controlButton(
        icon: String,
        label: String,
        hint: String,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.callout.weight(.semibold))
                .frame(width: 44, height: 44)
                .accessibilityHidden(true)
        }
        .buttonStyle(.bordered)
        .accessibilityLabel(label)
        .accessibilityHint(hint)
    }
}
