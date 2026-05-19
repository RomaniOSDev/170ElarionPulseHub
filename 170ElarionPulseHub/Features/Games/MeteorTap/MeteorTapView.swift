import SwiftUI

struct MeteorTapView: View {
    let activity: ActivityItem
    let difficulty: Difficulty
    let level: Int

    @StateObject private var viewModel: MeteorTapViewModel
    @EnvironmentObject private var progress: GameProgressStore
    @Environment(\.dismiss) private var dismiss
    @State private var navigateToNextLevel = false
    @State private var nextLevel = 0
    @State private var screenSize: CGSize = .zero

    init(activity: ActivityItem, difficulty: Difficulty, level: Int) {
        self.activity = activity
        self.difficulty = difficulty
        self.level = level
        _viewModel = StateObject(wrappedValue: MeteorTapViewModel(difficulty: difficulty, level: level))
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
                destination: MeteorTapView(activity: activity, difficulty: difficulty, level: nextLevel),
                isActive: $navigateToNextLevel
            ) { EmptyView() }
            .hidden()
        )
    }

    private var startOverlay: some View {
        VStack(spacing: 20) {
            Text("Meteor Tap Odyssey")
                .font(.title2.bold())
                .foregroundColor(.appTextPrimary)
            Text("Level \(level + 1) · \(difficulty.title)")
                .foregroundColor(.appTextSecondary)
            Text("Drag to move · Tap to shoot · Tap Finish anytime · 50+ pts for stars.")
                .font(.subheadline)
                .foregroundColor(.appTextSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            AppButton(title: "Start") {
                viewModel.startGame(screenSize: screenSize)
            }
            .padding(.horizontal, 24)
        }
    }

    private func gameLayer(size: CGSize) -> some View {
        ZStack {
            ForEach(viewModel.meteors) { meteor in
                MeteorView(size: 40)
                    .position(x: meteor.x, y: meteor.y)
            }

            ForEach(viewModel.lasers) { laser in
                LaserBoltView(angle: Angle(radians: atan2(laser.directionY, laser.directionX) + .pi / 2))
                    .position(x: laser.x, y: laser.y)
            }

            SpaceshipView(size: 52)
                .position(x: viewModel.shipXRatio * size.width, y: size.height - 110)

            GameHUDOverlay {
                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        Text("Score: \(viewModel.score)")
                            .font(.headline)
                            .foregroundColor(.appTextPrimary)
                        Spacer()
                        if viewModel.effects.comboCount > 1 {
                            Text("Combo \(viewModel.effects.comboCount)")
                                .font(.caption.weight(.bold))
                                .foregroundColor(.appAccent)
                        }
                    }
                    Text("Drag = move · Tap = shoot · Finish anytime")
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
                    viewModel.moveShip(ratio: value.location.x / max(size.width, 1))
                }
                .onEnded { value in
                    let travel = hypot(value.translation.width, value.translation.height)
                    if travel < 18 {
                        viewModel.shoot(toward: value.location)
                    }
                }
        )
    }

    private var resultModel: GameResultModel {
        let isLast = level >= GameProgressStore.levelsPerDifficulty - 1
        return GameResultModel(
            isSuccess: viewModel.didWin,
            stars: viewModel.earnedStars,
            primaryMetric: "Score",
            primaryValue: "\(viewModel.score)",
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
