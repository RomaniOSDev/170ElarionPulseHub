import SwiftUI

struct DailyMissionCell: View {
    @EnvironmentObject private var progress: GameProgressStore

    var body: some View {
        if let mission = progress.dailyMission,
           let activity = ActivityItem.find(id: mission.activityId) {
            VStack(alignment: .leading, spacing: 14) {
                HStack(spacing: 10) {
                    AppIconBadge(systemName: "sun.max.fill", accent: .accent, size: 44)
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Daily Mission")
                            .font(.headline)
                            .foregroundColor(.appTextPrimary)
                        Text(mission.isCompleted ? "Completed today" : "Bonus star available")
                            .font(.caption)
                            .foregroundColor(.appTextSecondary)
                    }
                    Spacer()
                    missionStatusPill(completed: mission.isCompleted)
                }

                VStack(alignment: .leading, spacing: 6) {
                    Text(activity.title)
                        .font(.subheadline.weight(.semibold))
                        .foregroundColor(.appTextPrimary)
                        .lineLimit(2)
                        .minimumScaleFactor(0.8)
                    HStack(spacing: 12) {
                        Label("Level \(mission.level + 1)", systemImage: "number")
                        Label(mission.difficulty.title, systemImage: "gauge.with.needle")
                    }
                    .font(.caption)
                    .foregroundColor(.appTextSecondary)
                    .labelStyle(.titleAndIcon)
                }

                if mission.isCompleted {
                    Text("Come back tomorrow for a new challenge.")
                        .font(.caption)
                        .foregroundColor(.appTextSecondary)
                } else {
                    NavigationLink(
                        value: DailyMissionLaunch(
                            activityId: mission.activityId,
                            difficultyRaw: mission.difficultyRaw,
                            level: mission.level
                        )
                    ) {
                        HStack {
                            Image(systemName: "play.fill")
                            Text("Launch Mission")
                                .font(.subheadline.weight(.bold))
                        }
                        .foregroundColor(.appTextPrimary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(
                            LinearGradient(
                                colors: [.appPrimary, .appAccent.opacity(0.85)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                    }
                    .simultaneousGesture(TapGesture().onEnded {
                        HapticService.mediumTap()
                    })
                }
            }
            .padding(16)
            .appCard(accent: .accent, highlighted: !mission.isCompleted)
        }
    }

    @ViewBuilder
    private func missionStatusPill(completed: Bool) -> some View {
        Text(completed ? "Done" : "+1 ⭐")
            .font(.caption.weight(.bold))
            .foregroundColor(completed ? .appPrimary : .appTextPrimary)
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background((completed ? Color.appPrimary : Color.appAccent).opacity(0.25))
            .clipShape(Capsule())
    }
}
