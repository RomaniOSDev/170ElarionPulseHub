import SwiftUI

extension ActivityItem {
    var cellAccent: AppCellAccent {
        switch id {
        case "meteor_tap": return .primary
        case "asteroid_evasion": return .accent
        default: return .warm
        }
    }

    var modeTag: String {
        switch id {
        case "meteor_tap": return "Tap & Shoot"
        case "asteroid_evasion": return "Dodge"
        default: return "Glide"
        }
    }
}

struct ActivityMissionCell: View {
    let activity: ActivityItem
    @EnvironmentObject private var progress: GameProgressStore

    private var stats: ActivitySessionStats {
        progress.activityStat(for: activity.id)
    }

    private var starsEarned: Int {
        progress.totalStars(for: activity.id)
    }

    private var maxStars: Int {
        GameProgressStore.maxStarsPerActivity
    }

    var body: some View {
        HStack(spacing: 14) {
            AppIconBadge(systemName: activity.iconName, accent: activity.cellAccent)

            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 6) {
                    Text(activity.modeTag.uppercased())
                        .font(.caption2.weight(.bold))
                        .foregroundColor(activity.cellAccent.color)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(activity.cellAccent.color.opacity(0.15))
                        .clipShape(Capsule())

                    if stats.sessionsPlayed > 0 {
                        Text("\(stats.sessionsPlayed) runs")
                            .font(.caption2)
                            .foregroundColor(.appTextSecondary)
                    }
                }

                Text(activity.title)
                    .font(.headline)
                    .foregroundColor(.appTextPrimary)
                    .lineLimit(2)
                    .minimumScaleFactor(0.75)

                Text(activity.subtitle)
                    .font(.caption)
                    .foregroundColor(.appTextSecondary)
                    .lineLimit(2)
                    .minimumScaleFactor(0.7)

                starProgressRow

                if let best = bestLine {
                    Label(best, systemImage: "trophy.fill")
                        .font(.caption2.weight(.semibold))
                        .foregroundColor(.appAccent)
                        .labelStyle(.titleAndIcon)
                }
            }

            AppChevronBadge()
        }
        .padding(16)
        .appCard(accent: activity.cellAccent, highlighted: stats.sessionsPlayed > 0)
    }

    private var starProgressRow: some View {
        HStack(spacing: 8) {
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color.appBackground.opacity(0.5))
                    Capsule()
                        .fill(activity.cellAccent.color.opacity(0.85))
                        .frame(width: geo.size.width * progressFraction)
                }
            }
            .frame(height: 5)

            Text("\(starsEarned)/\(maxStars)")
                .font(.caption2.weight(.semibold))
                .foregroundColor(.appTextSecondary)
                .lineLimit(1)
        }
    }

    private var progressFraction: CGFloat {
        guard maxStars > 0 else { return 0 }
        return CGFloat(min(starsEarned, maxStars)) / CGFloat(maxStars)
    }

    private var bestLine: String? {
        guard stats.sessionsPlayed > 0 else { return nil }
        if activity.id == "meteor_tap", stats.bestScore > 0 {
            return "Best \(stats.bestScore) pts"
        }
        if stats.bestSurvivalSeconds > 0 {
            return String(format: "Best %.1fs survive", stats.bestSurvivalSeconds)
        }
        return nil
    }
}
