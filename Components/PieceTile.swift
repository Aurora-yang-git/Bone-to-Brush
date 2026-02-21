import SwiftUI

struct PieceTile: View {
    let glyph: String
    let pressed: Bool

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(Color(.tertiarySystemBackground))
                .overlay {
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .strokeBorder(Color.secondary.opacity(0.22), lineWidth: 1)
                }
                .shadow(
                    color: .black.opacity(pressed ? 0.05 : 0.10),
                    radius: pressed ? 1 : 4,
                    x: 0, y: pressed ? 1 : 2
                )

            Text(glyph)
                .font(.system(size: 32, weight: .regular, design: .serif))
                .foregroundStyle(.primary)
        }
        .contentShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        .scaleEffect(pressed ? 0.94 : 1.0)
        .animation(.easeInOut(duration: 0.12), value: pressed)
    }
}
