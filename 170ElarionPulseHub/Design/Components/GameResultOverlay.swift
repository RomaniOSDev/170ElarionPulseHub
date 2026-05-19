import SwiftUI

struct GameResultModel {
    let isSuccess: Bool
    let stars: Int
    let primaryMetric: String
    let primaryValue: String
    let showNextLevel: Bool
    let newAchievements: [AchievementDefinition]
    let onNextLevel: () -> Void
    let onRetry: () -> Void
    let onBackToLevels: () -> Void
}

struct GameResultOverlay: View {
    let model: GameResultModel
    @State private var showBanner = false
    @State private var redFlashOpacity: Double = 0

    var body: some View {
        ZStack {
            Color.black.opacity(0.72)
                .ignoresSafeArea()

            if !model.isSuccess {
                Color.red.opacity(redFlashOpacity)
                    .ignoresSafeArea()
                    .allowsHitTesting(false)
            }

            ScrollView {
                VStack(spacing: 20) {
                    resultHeader

                    scoreCard

                    if model.isSuccess, let first = model.newAchievements.first {
                        achievementBanner(first)
                            .offset(y: showBanner ? 0 : -120)
                            .opacity(showBanner ? 1 : 0)
                    }

                    VStack(spacing: 12) {
                        if model.isSuccess && model.showNextLevel {
                            AppButton(title: "Next Level", style: .primary) {
                                HapticService.mediumTap()
                                model.onNextLevel()
                            }
                        }

                        AppButton(
                            title: model.isSuccess ? "Retry" : "Try Again",
                            style: model.isSuccess ? .secondary : .primary
                        ) {
                            HapticService.mediumTap()
                            model.onRetry()
                        }

                        AppButton(title: "Back to Levels", style: .secondary) {
                            model.onBackToLevels()
                        }
                    }
                }
                .appElevatedPanel(accent: model.isSuccess ? .accent : .primary, cornerRadius: 24)
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
            }
        }
        .onAppear {
            if model.isSuccess {
                HapticService.success()
                SoundService.playSuccess()
                withAnimation(.easeInOut(duration: 0.3).delay(0.3)) {
                    showBanner = model.newAchievements.isEmpty == false
                }
            } else {
                HapticService.error()
                SoundService.playFail()
                redFlashOpacity = 0.6
                withAnimation(.easeInOut(duration: 0.3)) {
                    redFlashOpacity = 0
                }
            }
        }
    }

    @ViewBuilder
    private var resultHeader: some View {
        VStack(spacing: 12) {
            Image(systemName: model.isSuccess ? "checkmark.seal.fill" : "xmark.octagon.fill")
                .font(.system(size: 44))
                .foregroundColor(model.isSuccess ? .appAccent : .red.opacity(0.9))
                .symbolRenderingMode(.hierarchical)

            Text(model.isSuccess ? "Level Complete!" : "Game Over")
                .font(.title.bold())
                .foregroundColor(.appTextPrimary)

            StarRatingView(count: model.stars, animated: model.isSuccess)
        }
    }

    private var scoreCard: some View {
        VStack(spacing: 6) {
            Text(model.primaryMetric)
                .font(.subheadline.weight(.medium))
                .foregroundColor(.appTextSecondary)
            Text(model.primaryValue)
                .font(.system(size: 44, weight: .bold, design: .rounded))
                .foregroundColor(.appAccent)
                .lineLimit(1)
                .minimumScaleFactor(0.6)
        }
        .padding(.vertical, 20)
        .padding(.horizontal, 16)
        .frame(maxWidth: .infinity)
        .appCard(accent: .accent, highlighted: model.isSuccess)
    }

    @ViewBuilder
    private func achievementBanner(_ achievement: AchievementDefinition) -> some View {
        HStack(spacing: 14) {
            AppIconBadge(systemName: achievement.iconName, accent: .accent, size: 48)
            VStack(alignment: .leading, spacing: 4) {
                Text("Achievement Unlocked")
                    .font(.caption.weight(.bold))
                    .foregroundColor(.appAccent)
                Text(achievement.title)
                    .font(.headline)
                    .foregroundColor(.appTextPrimary)
                    .lineLimit(2)
                    .minimumScaleFactor(0.8)
            }
            Spacer(minLength: 0)
        }
        .padding(14)
        .appCard(accent: .accent, highlighted: true)
    }
}
