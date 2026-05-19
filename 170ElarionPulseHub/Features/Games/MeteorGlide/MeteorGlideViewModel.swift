import Combine
import Foundation
import SwiftUI

@MainActor
final class MeteorGlideViewModel: ObservableObject {
    @Published var meteors: [MeteorEntity] = []
    @Published var shipXRatio: CGFloat = 0.5
    @Published var survivedSeconds: Double = 0
    @Published var dodgeStreak = 0
    @Published var isPlaying = false
    @Published var showResult = false
    @Published var didWin = false
    @Published var earnedStars = 0
    @Published var newAchievements: [AchievementDefinition] = []
    @Published var isHolding = false
    @Published var holdDirection: CGFloat = 0
    let effects = GameEffectsState()

    let difficulty: Difficulty
    let level: Int

    private var screenSize = CGSize.zero
    private var spawnInterval: TimeInterval
    private var targetSeconds: Double
    private var spawnTimer: AnyCancellable?
    private var gameTimer: AnyCancellable?
    private var peakCombo = 0
    private var achievementSnapshot = AchievementSnapshot(store: GameProgressStore.shared)

    private var levelMultiplier: CGFloat {
        1 + CGFloat(level) * 0.06
    }

    init(difficulty: Difficulty, level: Int) {
        self.difficulty = difficulty
        self.level = level
        switch difficulty {
        case .easy:
            spawnInterval = 2.0
            targetSeconds = 15
        case .normal:
            spawnInterval = 1.0
            targetSeconds = 30
        case .hard:
            spawnInterval = 0.5
            targetSeconds = 45
        }
        targetSeconds += Double(level) * 1.2
        spawnInterval -= Double(level) * 0.04
        spawnInterval = max(spawnInterval, 0.3)
    }

    func configure(size: CGSize) {
        screenSize = size
    }

    func startGame(screenSize: CGSize? = nil) {
        if let screenSize, screenSize.width > 0, screenSize.height > 0 {
            configure(size: screenSize)
        }
        meteors = []
        survivedSeconds = 0
        dodgeStreak = 0
        peakCombo = 0
        shipXRatio = 0.5
        didWin = false
        earnedStars = 0
        showResult = false
        isPlaying = true
        effects.resetSession()
        achievementSnapshot = GameProgressStore.shared.achievementSnapshot()
        HapticService.mediumTap()

        spawnTimer = Timer.publish(every: spawnInterval, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in self?.spawnMeteor() }

        gameTimer = Timer.publish(every: 1.0 / 60.0, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in self?.tick() }
    }

    func stopGame() {
        isPlaying = false
        spawnTimer?.cancel()
        gameTimer?.cancel()
        isHolding = false
        holdDirection = 0
    }

    func togglePause() {
        effects.isPaused.toggle()
    }

    func updateHold(at location: CGPoint, in size: CGSize) {
        guard isPlaying, !effects.isPaused else { return }
        if screenSize.width == 0 {
            screenSize = size
        }
        if !isHolding {
            isHolding = true
            HapticService.lightTap()
        }
        let midX = size.width / 2
        holdDirection = location.x < midX ? -1 : 1
    }

    func endHold() {
        isHolding = false
        holdDirection = 0
    }

    private func tick() {
        guard isPlaying, !effects.isPaused, screenSize.width > 0 else { return }

        if isHolding {
            let delta = 0.022 * holdDirection * levelMultiplier
            shipXRatio = min(0.92, max(0.08, shipXRatio + delta))
        }

        survivedSeconds += 1.0 / 60.0

        let shipX = shipXRatio * screenSize.width
        let shipY = screenSize.height - 100

        meteors = meteors.compactMap { meteor in
            var updated = meteor
            updated.y += updated.speed * levelMultiplier

            let dx = updated.x - shipX
            let dy = updated.y - shipY
            let distance = sqrt(dx * dx + dy * dy)

            if checkCollision(meteor: updated) {
                effects.registerMiss()
                effects.triggerNearMiss()
                endGame(success: false)
                return nil
            }

            if distance < 55 && distance >= 42 {
                effects.triggerNearMiss()
            }

            if updated.y > screenSize.height + 40 {
                dodgeStreak += 1
                effects.registerHit()
                peakCombo = max(peakCombo, effects.comboCount)
                if dodgeStreak % 10 == 0 {
                    HapticService.success()
                    SoundService.playSuccess()
                }
                return nil
            }

            return updated
        }

        if survivedSeconds >= targetSeconds {
            endGame(success: true)
        }
    }

    private func spawnMeteor() {
        guard isPlaying, !effects.isPaused, screenSize.width > 0 else { return }
        let x = CGFloat.random(in: 0.15...0.85) * screenSize.width
        let speed: CGFloat
        switch difficulty {
        case .easy: speed = CGFloat.random(in: 2.0...3.0)
        case .normal: speed = CGFloat.random(in: 3.0...4.5)
        case .hard: speed = CGFloat.random(in: 4.5...6.5)
        }
        meteors.append(MeteorEntity(x: x, y: -40, speed: speed * levelMultiplier))
    }

    private func checkCollision(meteor: MeteorEntity) -> Bool {
        let shipX = shipXRatio * screenSize.width
        let shipY = screenSize.height - 100
        let shipRadius: CGFloat = 24
        let meteorRadius: CGFloat = 16
        let dx = meteor.x - shipX
        let dy = meteor.y - shipY
        return sqrt(dx * dx + dy * dy) < shipRadius + meteorRadius
    }

    func endGame(success: Bool) {
        guard isPlaying else { return }
        stopGame()
        didWin = success
        earnedStars = success ? stars(for: survivedSeconds) : 0

        let store = GameProgressStore.shared
        let playTime = max(1, Int(survivedSeconds))
        if success {
            store.completeLevel(
                activityId: "meteor_glide",
                difficulty: difficulty,
                level: level,
                starsEarned: earnedStars,
                playTimeSeconds: playTime,
                sessionScore: dodgeStreak,
                survivalSeconds: survivedSeconds,
                peakCombo: peakCombo
            )
        } else {
            store.recordSession(
                activityId: "meteor_glide",
                survivalSeconds: survivedSeconds,
                combo: peakCombo,
                playTimeSeconds: playTime
            )
        }
        newAchievements = store.newlyUnlockedAchievements(comparedTo: achievementSnapshot)
        showResult = true
    }

    func stars(for seconds: Double) -> Int {
        if seconds >= 45 { return 3 }
        if seconds >= 30 { return 2 }
        if seconds >= 15 { return 1 }
        return 0
    }

    func formattedTime() -> String {
        String(format: "%.1fs", survivedSeconds)
    }

    func finishEarly() {
        guard isPlaying else { return }
        HapticService.mediumTap()
        let earned = stars(for: survivedSeconds)
        if earned >= 1 {
            earnedStars = earned
            endGame(success: true)
        } else {
            endGame(success: false)
        }
    }
}
