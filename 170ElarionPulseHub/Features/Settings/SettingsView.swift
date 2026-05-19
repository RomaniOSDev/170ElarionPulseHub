import StoreKit
import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var progress: GameProgressStore
    @State private var showResetAlert = false

    private var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    ScreenHeaderView(
                        title: "Settings",
                        subtitle: "Customize your flight experience"
                    )

                    PilotProfileCell()

                    statisticsSection
                    perGameSection
                    ShipSkinPickerView()

                    preferencesSection
                    legalSection

                    SettingsDestructiveRow(title: "Reset All Progress") {
                        showResetAlert = true
                    }

                    Text("Version \(appVersion)")
                        .font(.caption)
                        .foregroundColor(.appTextSecondary)
                        .frame(maxWidth: .infinity)
                        .padding(.top, 4)
                }
                .padding(20)
                .padding(.bottom, 24)
            }
            .alert("Reset All Progress?", isPresented: $showResetAlert) {
                Button("Cancel", role: .cancel) {
                    HapticService.lightTap()
                }
                Button("Reset", role: .destructive) {
                    HapticService.error()
                    progress.resetAllProgress()
                }
            } message: {
                Text("This will erase all stars, levels, and statistics. This cannot be undone.")
            }
            .transparentAppScreen()
            .background { AppBackgroundView() }
        }
    }

    private var statisticsSection: some View {
        SettingsSectionCard(title: "Statistics", subtitle: "Your overall flight record") {
            StatMetricRow(icon: "gamecontroller.fill", label: "Activities Played", value: "\(progress.totalActivitiesPlayed)")
            StatMetricRow(icon: "star.fill", label: "Total Stars", value: "\(progress.totalStarsEarned)")
            StatMetricRow(icon: "flame.fill", label: "Session Streak", value: "\(progress.streakCount)")
            StatMetricRow(icon: "calendar", label: "Day Streak", value: "\(progress.dayStreak)")
            StatMetricRow(icon: "clock.fill", label: "Play Time", value: progress.formattedPlayTime())
        }
    }

    private var perGameSection: some View {
        SettingsSectionCard(title: "Per Activity Best", subtitle: "Personal records by mission") {
            ForEach(ActivityItem.all) { activity in
                let stats = progress.activityStat(for: activity.id)
                ActivityStatRow(activity: activity, value: perGameValue(activity: activity, stats: stats))
                if activity.id != ActivityItem.all.last?.id {
                    Divider().opacity(0.25)
                }
            }
        }
    }

    private var preferencesSection: some View {
        SettingsSectionCard(title: "Preferences", subtitle: "Sound and feedback") {
            SettingsToggleRow(title: "Sound Effects", icon: "speaker.wave.2.fill", isOn: $progress.soundEnabled)
            Divider().opacity(0.25)
            SettingsToggleRow(title: "Haptics", icon: "iphone.radiowaves.left.and.right", isOn: $progress.hapticsEnabled)
        }
    }

    private var legalSection: some View {
        SettingsSectionCard(title: "Legal & Feedback", subtitle: "Rate the app and review policies") {
            VStack(spacing: 10) {
                SettingsNavigationRow(title: "Rate Us", icon: "star.fill", accent: .accent) {
                    rateApp()
                }
                SettingsNavigationRow(title: "Privacy", icon: "hand.raised.fill") {
                    openLink(.privacyPolicy)
                }
                SettingsNavigationRow(title: "Terms", icon: "doc.text.fill", accent: .warm) {
                    openLink(.termsOfUse)
                }
            }
        }
    }

    private func perGameValue(activity: ActivityItem, stats: ActivitySessionStats) -> String {
        if activity.id == "meteor_tap" {
            return stats.bestScore > 0 ? "\(stats.bestScore) pts" : "—"
        }
        return stats.bestSurvivalSeconds > 0 ? String(format: "%.1fs", stats.bestSurvivalSeconds) : "—"
    }

    private func openLink(_ link: AppExternalLink) {
        guard let url = link.url else { return }
        HapticService.lightTap()
        UIApplication.shared.open(url)
    }

    private func rateApp() {
        HapticService.lightTap()
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            SKStoreReviewController.requestReview(in: windowScene)
        }
    }
}
