import SwiftUI

// MARK: - Widget chrome

struct HomeWidgetSectionHeader: View {
    let title: String
    var actionTitle: String?
    var action: (() -> Void)?

    var body: some View {
        HStack {
            Text(title)
                .font(.headline)
                .foregroundColor(.appTextPrimary)
            Spacer()
            if let actionTitle, let action {
                Button(action: action) {
                    Text(actionTitle)
                        .font(.caption.weight(.bold))
                        .foregroundColor(.appAccent)
                }
                .buttonStyle(.plain)
            }
        }
    }
}

struct HomeStatChip: View {
    let icon: String
    let value: String
    let label: String
    var accent: AppCellAccent = .accent

    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.subheadline.weight(.semibold))
                .foregroundColor(accent.color)
            Text(value)
                .font(.subheadline.bold())
                .foregroundColor(.appTextPrimary)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
            Text(label)
                .font(.caption2)
                .foregroundColor(.appTextSecondary)
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .appCard(accent: accent, cornerRadius: 14)
    }
}

// MARK: - Hero

struct HomeHeroWidget: View {
    @EnvironmentObject private var progress: GameProgressStore

    var body: some View {
        HStack(alignment: .center, spacing: 16) {
            VStack(alignment: .leading, spacing: 8) {
                Text(greeting)
                    .font(.caption.weight(.semibold))
                    .foregroundColor(.appAccent)
                Text(progress.pilotRank.title)
                    .font(.title2.bold())
                    .foregroundColor(.appTextPrimary)
                Text("Ready for your next flight?")
                    .font(.subheadline)
                    .foregroundColor(.appTextSecondary)

                if progress.dayStreak > 0 {
                    Label("\(progress.dayStreak) day streak", systemImage: "flame.fill")
                        .font(.caption.weight(.bold))
                        .foregroundColor(.appPrimary)
                }
            }

            Spacer(minLength: 8)

            ZStack {
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [.appPrimary.opacity(0.35), .clear],
                            center: .center,
                            startRadius: 4,
                            endRadius: 56
                        )
                    )
                    .frame(width: 100, height: 100)
                SpaceshipView(size: 38, skin: progress.selectedSkin)
            }
        }
        .padding(18)
        .appCard(accent: .accent, highlighted: true)
    }

    private var greeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 5..<12: return "Good morning, pilot"
        case 12..<17: return "Good afternoon, pilot"
        case 17..<22: return "Good evening, pilot"
        default: return "Night shift, pilot"
        }
    }
}

// MARK: - Stats grid

struct HomeStatsGridWidget: View {
    @EnvironmentObject private var progress: GameProgressStore

    private let columns = [
        GridItem(.flexible(), spacing: 10),
        GridItem(.flexible(), spacing: 10)
    ]

    var body: some View {
        LazyVGrid(columns: columns, spacing: 10) {
            HomeStatChip(icon: "star.fill", value: "\(progress.totalStarsEarned)", label: "Stars", accent: .accent)
            HomeStatChip(icon: "gamecontroller.fill", value: "\(progress.totalActivitiesPlayed)", label: "Runs", accent: .primary)
            HomeStatChip(icon: "flame.fill", value: "\(progress.dayStreak)", label: "Day streak", accent: .warm)
            HomeStatChip(icon: "clock.fill", value: progress.formattedPlayTime(), label: "Flight time", accent: .primary)
        }
    }
}

// MARK: - Rank compact

struct HomeRankWidget: View {
    @EnvironmentObject private var progress: GameProgressStore

    var body: some View {
        let rank = progress.pilotRank
        let next = PilotRank.next(after: rank)
        let fraction = progress.rankProgressFraction()

        HStack(spacing: 14) {
            ZStack {
                Circle()
                    .stroke(Color.appBackground.opacity(0.55), lineWidth: 4)
                Circle()
                    .trim(from: 0, to: fraction)
                    .stroke(
                        LinearGradient(colors: [.appPrimary, .appAccent], startPoint: .topLeading, endPoint: .bottomTrailing),
                        style: StrokeStyle(lineWidth: 4, lineCap: .round)
                    )
                    .rotationEffect(.degrees(-90))
                Image(systemName: rank.iconName)
                    .font(.title3)
                    .foregroundColor(.appPrimary)
            }
            .frame(width: 52, height: 52)

            VStack(alignment: .leading, spacing: 4) {
                Text("Rank Progress")
                    .font(.caption.weight(.semibold))
                    .foregroundColor(.appTextSecondary)
                Text(rank.title)
                    .font(.headline)
                    .foregroundColor(.appTextPrimary)
                if let next {
                    Text("\(max(0, next.minimumStars - progress.totalStarsEarned)) stars to \(next.title)")
                        .font(.caption2)
                        .foregroundColor(.appTextSecondary)
                        .lineLimit(2)
                        .minimumScaleFactor(0.7)
                }
            }
            Spacer()
            Text("\(Int(fraction * 100))%")
                .font(.title3.bold())
                .foregroundColor(.appAccent)
        }
        .padding(14)
        .appCard(accent: .primary)
    }
}

// MARK: - Achievements

struct HomeAchievementsWidget: View {
    @EnvironmentObject private var progress: GameProgressStore
    var onViewAll: () -> Void

    private var total: Int { AchievementDefinition.all.count }
    private var unlocked: Int { progress.unlockedAchievementsCount }
    private var fraction: CGFloat {
        guard total > 0 else { return 0 }
        return CGFloat(unlocked) / CGFloat(total)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HomeWidgetSectionHeader(title: "Achievements", actionTitle: "View all", action: onViewAll)

            HStack(spacing: 14) {
                ZStack {
                    Circle()
                        .stroke(Color.appBackground.opacity(0.5), lineWidth: 4)
                    Circle()
                        .trim(from: 0, to: fraction)
                        .stroke(Color.appAccent, style: StrokeStyle(lineWidth: 4, lineCap: .round))
                        .rotationEffect(.degrees(-90))
                    Image(systemName: "rosette")
                        .foregroundColor(.appPrimary)
                }
                .frame(width: 48, height: 48)

                VStack(alignment: .leading, spacing: 6) {
                    Text("\(unlocked) of \(total) unlocked")
                        .font(.subheadline.weight(.semibold))
                        .foregroundColor(.appTextPrimary)
                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            Capsule().fill(Color.appBackground.opacity(0.5))
                            Capsule()
                                .fill(LinearGradient(colors: [.appPrimary, .appAccent], startPoint: .leading, endPoint: .trailing))
                                .frame(width: geo.size.width * fraction)
                        }
                    }
                    .frame(height: 6)
                }
            }
        }
        .padding(14)
        .appCard(accent: .accent)
    }
}

// MARK: - Campaign progress

struct HomeCampaignWidget: View {
    @EnvironmentObject private var progress: GameProgressStore

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Campaign Progress")
                .font(.headline)
                .foregroundColor(.appTextPrimary)

            HStack {
                Text("\(progress.totalStarsEarned) / \(progress.totalPossibleStars) stars")
                    .font(.caption.weight(.semibold))
                    .foregroundColor(.appTextSecondary)
                Spacer()
                Text("\(Int(progress.overallStarProgress * 100))%")
                    .font(.caption.bold())
                    .foregroundColor(.appAccent)
            }

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule().fill(Color.appBackground.opacity(0.5))
                    Capsule()
                        .fill(LinearGradient(colors: [.appPrimary, .appAccent], startPoint: .leading, endPoint: .trailing))
                        .frame(width: max(4, geo.size.width * progress.overallStarProgress))
                }
            }
            .frame(height: 8)

            HStack(spacing: 8) {
                ForEach(ActivityItem.all) { activity in
                    let earned = progress.totalStars(for: activity.id)
                    let maxStars = GameProgressStore.maxStarsPerActivity
                    VStack(spacing: 4) {
                        AppIconBadge(systemName: activity.iconName, accent: activity.cellAccent, size: 32)
                        Text("\(earned)/\(maxStars)")
                            .font(.system(size: 9, weight: .bold))
                            .foregroundColor(.appAccent)
                    }
                    .frame(maxWidth: .infinity)
                }
            }
        }
        .padding(14)
        .appCard(accent: .primary)
    }
}

// MARK: - Quick play

struct HomeQuickPlayWidget: View {
    @EnvironmentObject private var progress: GameProgressStore
    let activity: ActivityItem

    var body: some View {
        let level = progress.nextPlayableLevel(for: activity.id)
        let stars = progress.stars(activityId: activity.id, difficulty: .easy, level: level)

        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Label("Quick Play", systemImage: "bolt.fill")
                    .font(.caption.weight(.bold))
                    .foregroundColor(.appAccent)
                Spacer()
                Text("Recommended")
                    .font(.caption2.weight(.bold))
                    .foregroundColor(.appTextPrimary)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.appPrimary.opacity(0.3))
                    .clipShape(Capsule())
            }

            HStack(spacing: 12) {
                AppIconBadge(systemName: activity.iconName, accent: activity.cellAccent, size: 48)
                VStack(alignment: .leading, spacing: 4) {
                    Text(activity.title)
                        .font(.headline)
                        .foregroundColor(.appTextPrimary)
                        .lineLimit(2)
                        .minimumScaleFactor(0.8)
                    Text("Level \(level + 1) · Easy · \(stars)/3 ⭐")
                        .font(.caption)
                        .foregroundColor(.appTextSecondary)
                }
                Spacer()
            }

            NavigationLink(value: activity) {
                HStack {
                    Image(systemName: "play.fill")
                    Text("Continue Mission")
                        .font(.subheadline.weight(.bold))
                }
                .foregroundColor(.appTextPrimary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(
                    LinearGradient(colors: [.appPrimary, .appAccent.opacity(0.85)], startPoint: .leading, endPoint: .trailing)
                )
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            }
            .simultaneousGesture(TapGesture().onEnded { HapticService.mediumTap() })
        }
        .padding(16)
        .appCard(accent: activity.cellAccent, highlighted: true)
    }
}

// MARK: - Ship skin teaser

struct HomeShipWidget: View {
    @EnvironmentObject private var progress: GameProgressStore
    var onOpenSettings: () -> Void

    var body: some View {
        let skin = progress.selectedSkin
        let unlockedSkins = ShipSkin.all.filter { $0.isUnlocked(totalStars: progress.totalStarsEarned) }.count

        Button(action: {
            HapticService.lightTap()
            onOpenSettings()
        }) {
            HStack(spacing: 14) {
                SpaceshipView(size: 32, skin: skin)
                    .frame(width: 70, height: 80)
                VStack(alignment: .leading, spacing: 4) {
                    Text("Equipped Ship")
                        .font(.caption.weight(.semibold))
                        .foregroundColor(.appTextSecondary)
                    Text(skin.title)
                        .font(.headline)
                        .foregroundColor(.appTextPrimary)
                    Text("\(unlockedSkins)/\(ShipSkin.all.count) styles unlocked")
                        .font(.caption2)
                        .foregroundColor(.appAccent)
                }
                Spacer()
                AppChevronBadge()
            }
            .padding(14)
            .appCard(accent: .accent)
        }
        .buttonStyle(.plain)
    }
}
