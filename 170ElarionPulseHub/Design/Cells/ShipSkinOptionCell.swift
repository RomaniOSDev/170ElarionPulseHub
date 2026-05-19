import SwiftUI

struct ShipSkinOptionCell: View {
    let skin: ShipSkin
    let unlocked: Bool
    let selected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 10) {
                ZStack {
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color.appBackground.opacity(0.7),
                                    Color.appPrimary.opacity(unlocked ? 0.2 : 0.08)
                                ],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                    SpaceshipView(size: 44, skin: skin, animated: unlocked)
                        .opacity(unlocked ? 1 : 0.35)
                }
                .frame(height: 120)

                Text(skin.title)
                    .font(.caption.weight(.bold))
                    .foregroundColor(.appTextPrimary)
                    .lineLimit(1)

                Text(skin.subtitle)
                    .font(.caption2)
                    .foregroundColor(.appTextSecondary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)

                statusLabel
            }
            .padding(12)
            .frame(width: 118)
            .appCard(accent: selected ? .accent : .primary, highlighted: selected)
        }
        .buttonStyle(.plain)
        .disabled(!unlocked)
        .opacity(unlocked ? 1 : 0.75)
    }

    @ViewBuilder
    private var statusLabel: some View {
        if selected {
            Text("Equipped")
                .font(.caption2.weight(.bold))
                .foregroundColor(.appAccent)
        } else if unlocked {
            Text("Tap to equip")
                .font(.caption2)
                .foregroundColor(.appTextSecondary)
        } else {
            Text("\(skin.starsRequired) ⭐ to unlock")
                .font(.caption2)
                .foregroundColor(.appTextSecondary)
                .lineLimit(2)
                .multilineTextAlignment(.center)
                .minimumScaleFactor(0.7)
        }
    }
}
