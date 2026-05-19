import SwiftUI

struct MeteorGlideView: View {
    let activity: ActivityItem
    let difficulty: Difficulty
    let level: Int

    @StateObject private var viewModel: MeteorGlideViewModel
    @EnvironmentObject private var progress: GameProgressStore
    @Environment(\.dismiss) private var dismiss
    @State private var navigateToNextLevel = false
    @State private var nextLevel = 0
    @State private var screenSize: CGSize = .zero

    init(activity: ActivityItem, difficulty: Difficulty, level: Int) {
        self.activity = activity
        self.difficulty = difficulty
        self.level = level
        _viewModel = StateObject(wrappedValue: MeteorGlideViewModel(difficulty: difficulty, level: level))
    }

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                if viewModel.isPlaying {
                    gameLayer(size: geometry.size)
                }

                if viewModel.showResult {
                    GameResultOverlay(model: resultModel)
                } else if !viewModel.isPlaying {
                    startOverlay
                }
            }
            .offset(x: viewModel.effects.nearMissShake)
            .onAppear {
                screenSize = geometry.size
                viewModel.configure(size: geometry.size)
            }
            .onChange(of: geometry.size) { newSize in
                screenSize = newSize
                viewModel.configure(size: newSize)
            }
        }
        .appScreenBackground()
        .navigationBarBackButtonHidden(viewModel.isPlaying || viewModel.showResult)
        .background(
            NavigationLink(
                destination: MeteorGlideView(activity: activity, difficulty: difficulty, level: nextLevel),
                isActive: $navigateToNextLevel
            ) { EmptyView() }
            .hidden()
        )
    }

    private var startOverlay: some View {
        VStack(spacing: 20) {
            Text("Meteor Glide")
                .font(.title2.bold())
                .foregroundColor(.appTextPrimary)
            Text("Level \(level + 1) · \(difficulty.title)")
                .foregroundColor(.appTextSecondary)
            Text("Hold left or right to steer · Tap Finish to end early · Survive for stars.")
                .font(.subheadline)
                .foregroundColor(.appTextSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            AppButton(title: "Start") { viewModel.startGame(screenSize: screenSize) }
                .padding(.horizontal, 24)
        }
    }

    private func gameLayer(size: CGSize) -> some View {
        ZStack {
            ForEach(viewModel.meteors) { meteor in
                MeteorView(size: 30)
                    .position(x: meteor.x, y: meteor.y)
            }

            SpaceshipView(size: 52)
                .position(x: viewModel.shipXRatio * size.width, y: size.height - 110)

            GameHUDOverlay {
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Time: \(viewModel.formattedTime())")
                            Text("Dodges: \(viewModel.dodgeStreak)")
                        }
                        Spacer()
                        if viewModel.effects.comboCount > 1 {
                            Text("Combo \(viewModel.effects.comboCount)")
                                .font(.caption.weight(.bold))
                                .foregroundColor(.appAccent)
                        }
                    }
                    .font(.subheadline.weight(.semibold))
                    .foregroundColor(.appTextPrimary)
                    Text(viewModel.isHolding ? "Steering..." : "Hold sides to move · Finish anytime")
                        .font(.caption)
                        .foregroundColor(.appTextSecondary)
                }
                .padding()
            }

            GameChromeOverlay(
                effects: viewModel.effects,
                activityId: activity.id,
                onTutorialDismiss: { progress.markTutorialSeen(for: activity.id) },
                onPause: { viewModel.togglePause() },
                onResume: { viewModel.effects.isPaused = false }
            )

            GameFinishButton {
                viewModel.finishEarly()
            }
        }
        .frame(width: size.width, height: size.height)
        .contentShape(Rectangle())
        .gesture(
            DragGesture(minimumDistance: 0)
                .onChanged { value in
                    viewModel.updateHold(at: value.location, in: size)
                }
                .onEnded { _ in
                    viewModel.endHold()
                }
        )
    }

    private var resultModel: GameResultModel {
        let isLast = level >= GameProgressStore.levelsPerDifficulty - 1
        return GameResultModel(
            isSuccess: viewModel.didWin,
            stars: viewModel.earnedStars,
            primaryMetric: "Survived",
            primaryValue: viewModel.formattedTime(),
            showNextLevel: viewModel.didWin && !isLast,
            newAchievements: viewModel.newAchievements,
            onNextLevel: {
                nextLevel = level + 1
                navigateToNextLevel = true
                viewModel.showResult = false
            },
            onRetry: {
                viewModel.showResult = false
                viewModel.startGame(screenSize: screenSize)
            },
            onBackToLevels: { dismiss() }
        )
    }
}
