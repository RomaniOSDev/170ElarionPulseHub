import SwiftUI

struct HomeView: View {
    @EnvironmentObject private var progress: GameProgressStore
    @Binding var selectedTab: MainTab

    var body: some View {
        NavigationStack {
            ZStack {
                HomeAnimatedBackground()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)

                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        ScreenHeaderView(
                            title: "Command Center",
                            subtitle: "Your flight hub — missions, stats, and daily goals",
                            badgeText: progress.dayStreak > 0 ? "\(progress.dayStreak)d" : nil,
                            badgeIcon: "flame.fill"
                        )
                        .padding(.top, 8)

                        HomeHeroWidget()

                        HomeStatsGridWidget()

                        DailyMissionCell()

                        HomeQuickPlayWidget(activity: progress.featuredActivity)

                        HStack(spacing: 10) {
                            HomeRankWidget()
                                .frame(maxWidth: .infinity)
                        }

                        HomeCampaignWidget()

                        HomeAchievementsWidget {
                            HapticService.lightTap()
                            withAnimation(.easeInOut(duration: 0.25)) {
                                selectedTab = .achievements
                            }
                        }

                        HomeShipWidget {
                            withAnimation(.easeInOut(duration: 0.25)) {
                                selectedTab = .settings
                            }
                        }

                        missionsSection
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 28)
                }
            }
            .navigationDestination(for: ActivityItem.self) { activity in
                LevelSelectionView(activity: activity)
            }
            .navigationDestination(for: DailyMissionLaunch.self) { launch in
                dailyMissionGame(launch)
            }
            .transparentAppScreen()
            .background { AppBackgroundView() }
        }
    }

    private var missionsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HomeWidgetSectionHeader(title: "All Missions")

            ForEach(ActivityItem.all) { activity in
                NavigationLink(value: activity) {
                    ActivityMissionCell(activity: activity)
                }
                .buttonStyle(.plain)
                .simultaneousGesture(TapGesture().onEnded {
                    HapticService.lightTap()
                })
            }
        }
    }

    @ViewBuilder
    private func dailyMissionGame(_ launch: DailyMissionLaunch) -> some View {
        if let activity = ActivityItem.find(id: launch.activityId),
           let difficulty = Difficulty(rawValue: launch.difficultyRaw) {
            switch activity.id {
            case "meteor_tap":
                MeteorTapView(activity: activity, difficulty: difficulty, level: launch.level)
            case "asteroid_evasion":
                AsteroidEvasionView(activity: activity, difficulty: difficulty, level: launch.level)
            case "meteor_glide":
                MeteorGlideView(activity: activity, difficulty: difficulty, level: launch.level)
            default:
                EmptyView()
            }
        } else {
            EmptyView()
        }
    }
}

struct HomeAnimatedBackground: View {
    var body: some View {
        Canvas { context, size in
            for index in 0..<32 {
                let seed = Double(index) * 2.17
                let x = (sin(seed) * 0.5 + 0.5) * size.width
                let y = (cos(seed * 1.3) * 0.5 + 0.5) * size.height
                let rect = CGRect(x: x, y: y, width: 3, height: 3)
                context.fill(Path(ellipseIn: rect), with: .color(Color.appAccent.opacity(0.18)))
            }
        }
        .allowsHitTesting(false)
    }
}
