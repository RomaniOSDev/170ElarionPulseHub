import SwiftUI

struct AchievementBadgeCell: View {
    let achievement: AchievementDefinition
    let unlocked: Bool
    var progressHint: String?
    var isAnimating: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                ZStack {
                    Circle()
                        .fill(unlocked ? Color.appPrimary.opacity(0.25) : Color.appBackground.opacity(0.5))
                        .frame(width: 48, height: 48)
                    Image(systemName: achievement.iconName)
                        .font(.title2)
                        .foregroundColor(unlocked ? .appPrimary : .appTextSecondary.opacity(0.6))
                        .scaleEffect(isAnimating ? 1.15 : 1)
                }
                Spacer()
                if unlocked {
                    Image(systemName: "checkmark.seal.fill")
                        .foregroundColor(.appAccent)
                } else {
                    Image(systemName: "lock.fill")
                        .font(.caption)
                        .foregroundColor(.appTextSecondary.opacity(0.5))
                }
            }

            Text(achievement.title)
                .font(.subheadline.weight(.bold))
                .foregroundColor(unlocked ? .appTextPrimary : .appTextSecondary)
                .lineLimit(2)
                .minimumScaleFactor(0.75)

            Text(achievement.description)
                .font(.caption2)
                .foregroundColor(.appTextSecondary)
                .lineLimit(3)
                .minimumScaleFactor(0.7)

            if let progressHint, !unlocked {
                Text(progressHint)
                    .font(.caption2.weight(.semibold))
                    .foregroundColor(.appAccent)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
            }
        }
        .padding(14)
        .frame(maxWidth: .infinity, minHeight: 156, alignment: .topLeading)
        .appCard(accent: unlocked ? .accent : .primary, highlighted: unlocked)
        .opacity(unlocked ? 1 : 0.82)
    }
}
