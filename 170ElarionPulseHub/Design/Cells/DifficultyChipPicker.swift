import SwiftUI

struct DifficultyChipPicker: View {
    @Binding var selection: Difficulty

    var body: some View {
        HStack(spacing: 10) {
            ForEach(Difficulty.allCases) { difficulty in
                chip(for: difficulty)
            }
        }
    }

    private func chip(for difficulty: Difficulty) -> some View {
        let selected = selection == difficulty
        return Button {
            guard selection != difficulty else { return }
            HapticService.lightTap()
            withAnimation(.easeInOut(duration: 0.2)) {
                selection = difficulty
            }
        } label: {
            Text(difficulty.title)
                .font(.subheadline.weight(selected ? .bold : .medium))
                .foregroundColor(selected ? .appTextPrimary : .appTextSecondary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 11)
                .background {
                    if selected {
                        LinearGradient(
                            colors: [.appPrimary, .appAccent.opacity(0.8)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    } else {
                        Color.appBackground.opacity(0.45)
                    }
                }
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                .overlay {
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .stroke(
                            selected ? AppGradients.cardBorder : LinearGradient(
                                colors: [Color.appTextSecondary.opacity(0.25), Color.clear],
                                startPoint: .top,
                                endPoint: .bottom
                            ),
                            lineWidth: 1
                        )
                }
                .overlay(alignment: .top) {
                    if selected {
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .fill(AppGradients.cardTopSheen)
                            .frame(height: 10)
                            .allowsHitTesting(false)
                    }
                }
        }
        .buttonStyle(.plain)
        .appDepthShadow(accent: .accent, elevated: selected)
    }
}
