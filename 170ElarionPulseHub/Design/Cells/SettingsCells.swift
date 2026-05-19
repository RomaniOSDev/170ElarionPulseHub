import SwiftUI

struct SettingsSectionCard<Content: View>: View {
    let title: String
    var subtitle: String?
    @ViewBuilder let content: () -> Content

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                    .foregroundColor(.appTextPrimary)
                if let subtitle {
                    Text(subtitle)
                        .font(.caption)
                        .foregroundColor(.appTextSecondary)
                }
            }
            content()
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .appCard(accent: .primary)
    }
}

struct StatMetricRow: View {
    let icon: String
    let label: String
    let value: String
    var accent: AppCellAccent = .accent

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.body.weight(.semibold))
                .foregroundColor(accent.color)
                .frame(width: 28)
            Text(label)
                .font(.subheadline)
                .foregroundColor(.appTextSecondary)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
            Spacer(minLength: 8)
            Text(value)
                .font(.headline)
                .foregroundColor(.appAccent)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
        .padding(.vertical, 4)
    }
}

struct ActivityStatRow: View {
    let activity: ActivityItem
    let value: String

    var body: some View {
        HStack(spacing: 12) {
            AppIconBadge(systemName: activity.iconName, accent: activity.cellAccent, size: 36)
            Text(activity.title)
                .font(.caption.weight(.medium))
                .foregroundColor(.appTextPrimary)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
            Spacer()
            Text(value)
                .font(.caption.weight(.bold))
                .foregroundColor(.appAccent)
        }
        .padding(.vertical, 6)
    }
}

struct SettingsToggleRow: View {
    let title: String
    let icon: String
    @Binding var isOn: Bool

    var body: some View {
        Toggle(isOn: $isOn) {
            HStack(spacing: 12) {
                AppIconBadge(systemName: icon, accent: .primary, size: 36)
                Text(title)
                    .font(.subheadline.weight(.medium))
                    .foregroundColor(.appTextPrimary)
            }
        }
        .tint(.appPrimary)
        .onChange(of: isOn) { _ in HapticService.lightTap() }
    }
}

struct SettingsNavigationRow: View {
    let title: String
    let icon: String
    var accent: AppCellAccent = .primary
    let action: () -> Void

    var body: some View {
        Button {
            HapticService.lightTap()
            action()
        } label: {
            HStack(spacing: 12) {
                AppIconBadge(systemName: icon, accent: accent, size: 36)
                Text(title)
                    .font(.subheadline.weight(.medium))
                    .foregroundColor(.appTextPrimary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
                Spacer()
                AppChevronBadge()
            }
            .padding(14)
            .appCard(accent: accent)
        }
        .buttonStyle(.plain)
    }
}

struct SettingsDestructiveRow: View {
    let title: String
    let action: () -> Void

    var body: some View {
        Button {
            HapticService.lightTap()
            action()
        } label: {
            HStack(spacing: 12) {
                Image(systemName: "arrow.counterclockwise")
                    .font(.body.weight(.semibold))
                    .foregroundColor(.red.opacity(0.9))
                    .frame(width: 36, height: 36)
                    .background(Color.red.opacity(0.12))
                    .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                Text(title)
                    .font(.subheadline.weight(.semibold))
                    .foregroundColor(.red.opacity(0.95))
                Spacer()
            }
            .padding(14)
            .appCard(accent: .primary)
        }
        .buttonStyle(.plain)
    }
}

struct PilotProfileCell: View {
    @EnvironmentObject private var progress: GameProgressStore

    var body: some View {
        let rank = progress.pilotRank
        HStack(spacing: 16) {
            AppIconBadge(systemName: rank.iconName, accent: .accent, size: 56)
            VStack(alignment: .leading, spacing: 6) {
                Text("Pilot Profile")
                    .font(.caption.weight(.semibold))
                    .foregroundColor(.appTextSecondary)
                Text(rank.title)
                    .font(.title2.bold())
                    .foregroundColor(.appTextPrimary)
                HStack(spacing: 16) {
                    miniStat(value: "\(progress.totalStarsEarned)", label: "Stars")
                    miniStat(value: "\(progress.dayStreak)", label: "Day streak")
                    miniStat(value: "\(progress.streakCount)", label: "Sessions")
                }
            }
            Spacer(minLength: 0)
        }
        .padding(16)
        .appCard(accent: .accent, highlighted: true)
    }

    private func miniStat(value: String, label: String) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(value)
                .font(.subheadline.bold())
                .foregroundColor(.appAccent)
            Text(label)
                .font(.caption2)
                .foregroundColor(.appTextSecondary)
        }
    }
}
