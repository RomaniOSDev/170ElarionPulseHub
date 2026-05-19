import SwiftUI

struct AchievementsView: View {
    @EnvironmentObject private var progress: GameProgressStore
    @State private var animatingID: String?

    private let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]

    private var unlockedCount: Int {
        AchievementDefinition.all.filter { progress.isAchievementUnlocked($0) }.count
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    ScreenHeaderView(
                        title: "Achievements",
                        subtitle: "Unlock badges by playing and earning stars",
                        badgeText: "\(unlockedCount)/\(AchievementDefinition.all.count)",
                        badgeIcon: "rosette"
                    )

                    achievementsSummaryBar

                    LazyVGrid(columns: columns, spacing: 12) {
                        ForEach(AchievementDefinition.all) { achievement in
                            achievementCell(achievement)
                        }
                    }
                }
                .padding(20)
                .padding(.bottom, 24)
            }
            .transparentAppScreen()
            .background { AppBackgroundView() }
        }
    }

    private var achievementsSummaryBar: some View {
        HStack(spacing: 12) {
            summaryPill(icon: "star.fill", value: "\(progress.totalStarsEarned)", label: "Stars")
            summaryPill(icon: "gamecontroller.fill", value: "\(progress.totalActivitiesPlayed)", label: "Runs")
            summaryPill(icon: "clock.fill", value: progress.formattedPlayTime(), label: "Time")
        }
    }

    private func summaryPill(icon: String, value: String, label: String) -> some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.caption)
                .foregroundColor(.appPrimary)
            Text(value)
                .font(.caption.weight(.bold))
                .foregroundColor(.appAccent)
                .lineLimit(1)
                .minimumScaleFactor(0.6)
            Text(label)
                .font(.caption2)
                .foregroundColor(.appTextSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .appCard(accent: .primary)
    }

    private func achievementCell(_ achievement: AchievementDefinition) -> some View {
        let unlocked = progress.isAchievementUnlocked(achievement)
        return AchievementBadgeCell(
            achievement: achievement,
            unlocked: unlocked,
            progressHint: achievement.progressHint(store: progress),
            isAnimating: animatingID == achievement.id
        )
        .onAppear {
            if unlocked && animatingID != achievement.id {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    animatingID = achievement.id
                    HapticService.success()
                }
            }
        }
        .onChange(of: progress.totalStarsEarned) { _ in
            triggerUnlockAnimationIfNeeded(achievement, unlocked: unlocked)
        }
        .onChange(of: progress.totalActivitiesPlayed) { _ in
            triggerUnlockAnimationIfNeeded(achievement, unlocked: unlocked)
        }
        .onChange(of: progress.totalPlayTimeSeconds) { _ in
            triggerUnlockAnimationIfNeeded(achievement, unlocked: unlocked)
        }
    }

    private func triggerUnlockAnimationIfNeeded(_ achievement: AchievementDefinition, unlocked: Bool) {
        guard unlocked else { return }
        animatingID = achievement.id
        HapticService.success()
    }
}
