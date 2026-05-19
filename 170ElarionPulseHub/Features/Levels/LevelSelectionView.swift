import SwiftUI

struct LevelSelectionView: View {
    let activity: ActivityItem
    @EnvironmentObject private var progress: GameProgressStore
    @State private var difficulty: Difficulty = .easy
    @Environment(\.dismiss) private var dismiss

    private let columns = [
        GridItem(.flexible(), spacing: 10),
        GridItem(.flexible(), spacing: 10),
        GridItem(.flexible(), spacing: 10),
        GridItem(.flexible(), spacing: 10),
        GridItem(.flexible(), spacing: 10)
    ]

    private var completedLevels: Int {
        (0..<GameProgressStore.levelsPerDifficulty).filter { level in
            progress.stars(activityId: activity.id, difficulty: difficulty, level: level) > 0
        }.count
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                activityHeader

                DifficultyChipPicker(selection: $difficulty)

                levelProgressCard

                LazyVGrid(columns: columns, spacing: 10) {
                    ForEach(0..<GameProgressStore.levelsPerDifficulty, id: \.self) { level in
                        levelCell(level: level)
                    }
                }
            }
            .padding(20)
            .padding(.bottom, 24)
        }
        .transparentAppScreen()
        .background { AppBackgroundView() }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("Levels")
                    .font(.headline)
                    .foregroundColor(.appTextPrimary)
            }
        }
    }

    private var activityHeader: some View {
        HStack(spacing: 14) {
            AppIconBadge(systemName: activity.iconName, accent: activity.cellAccent, size: 52)
            VStack(alignment: .leading, spacing: 6) {
                Text(activity.title)
                    .font(.title3.bold())
                    .foregroundColor(.appTextPrimary)
                    .lineLimit(2)
                    .minimumScaleFactor(0.8)
                Text(difficulty.hint(for: activity.id))
                    .font(.caption)
                    .foregroundColor(.appTextSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            Spacer(minLength: 0)
        }
        .padding(14)
        .appCard(accent: activity.cellAccent, highlighted: true)
    }

    private var levelProgressCard: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("\(GameProgressStore.levelsPerDifficulty) levels")
                    .font(.subheadline.weight(.semibold))
                    .foregroundColor(.appTextPrimary)
                Text("\(completedLevels) cleared on \(difficulty.title)")
                    .font(.caption)
                    .foregroundColor(.appTextSecondary)
            }
            Spacer()
            Text("\(progress.totalStars(for: activity.id)) ⭐")
                .font(.headline)
                .foregroundColor(.appAccent)
        }
        .padding(14)
        .appCard(accent: activity.cellAccent, highlighted: completedLevels > 0)
    }

    @ViewBuilder
    private func levelCell(level: Int) -> some View {
        let unlocked = progress.isLevelUnlocked(activityId: activity.id, difficulty: difficulty, level: level)
        let stars = progress.stars(activityId: activity.id, difficulty: difficulty, level: level)
        let record = progress.bestRecord(activityId: activity.id, difficulty: difficulty, level: level)

        if unlocked {
            NavigationLink {
                gameView(level: level)
            } label: {
                LevelGridCell(
                    level: level + 1,
                    stars: stars,
                    locked: false,
                    recordText: recordLabel(record)
                )
            }
            .simultaneousGesture(TapGesture().onEnded {
                HapticService.mediumTap()
            })
        } else {
            LevelGridCell(
                level: level + 1,
                stars: stars,
                locked: true,
                recordText: nil
            )
        }
    }

    private func recordLabel(_ record: LevelBestRecord) -> String? {
        switch activity.id {
        case "meteor_tap":
            return record.bestScore > 0 ? "Best \(record.bestScore)" : nil
        default:
            return record.bestSurvivalSeconds > 0 ? String(format: "Best %.0fs", record.bestSurvivalSeconds) : nil
        }
    }

    @ViewBuilder
    private func gameView(level: Int) -> some View {
        switch activity.id {
        case "meteor_tap":
            MeteorTapView(activity: activity, difficulty: difficulty, level: level)
        case "asteroid_evasion":
            AsteroidEvasionView(activity: activity, difficulty: difficulty, level: level)
        case "meteor_glide":
            MeteorGlideView(activity: activity, difficulty: difficulty, level: level)
        default:
            EmptyView()
        }
    }
}
