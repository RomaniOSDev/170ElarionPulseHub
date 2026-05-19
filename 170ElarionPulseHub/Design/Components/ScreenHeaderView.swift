import SwiftUI

struct ScreenHeaderView: View {
    let title: String
    let subtitle: String
    var badgeText: String?
    var badgeIcon: String?

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            VStack(alignment: .leading, spacing: 8) {
                Text(title)
                    .font(.largeTitle.bold())
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.appTextPrimary, .appTextPrimary.opacity(0.88)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .lineLimit(2)
                    .minimumScaleFactor(0.8)
                    .shadow(color: .appPrimary.opacity(0.25), radius: 6, y: 2)

                Text(subtitle)
                    .font(.subheadline)
                    .foregroundColor(.appTextSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            Spacer(minLength: 8)
            if let badgeText {
                headerBadge(text: badgeText, icon: badgeIcon)
            }
        }
        .padding(16)
        .background {
            AppCardBackground(accent: .accent, highlighted: false, cornerRadius: 20)
        }
        .appDepthShadow(accent: .accent)
    }

    private func headerBadge(text: String, icon: String?) -> some View {
        HStack(spacing: 4) {
            if let icon {
                Image(systemName: icon)
                    .font(.caption2.weight(.bold))
            }
            Text(text)
                .font(.caption.weight(.bold))
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
        .foregroundColor(.appTextPrimary)
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(
            LinearGradient(
                colors: [.appPrimary.opacity(0.55), .appAccent.opacity(0.35)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .clipShape(Capsule())
        .overlay(Capsule().stroke(Color.appTextPrimary.opacity(0.2), lineWidth: 1))
        .shadow(color: .appPrimary.opacity(0.2), radius: 4, y: 2)
    }
}
