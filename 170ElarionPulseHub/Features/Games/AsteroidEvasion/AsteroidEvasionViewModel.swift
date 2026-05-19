import Combine
import Foundation
import SwiftUI

@MainActor
final class AsteroidEvasionViewModel: ObservableObject {
    @Published var meteors: [MeteorEntity] = []
    @Published var shipXRatio: CGFloat = 0.5
    @Published var survivedSeconds: Double = 0
    @Published var isPlaying = false
    @Published var showResult = false
    @Published var didWin = false
    @Published var earnedStars = 0
    @Published var newAchievements: [AchievementDefinition] = []
    @Published var speedMultiplier: CGFloat = 1
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
            spawnInterval = 1.0
            targetSeconds = 30
        case .normal:
            spawnInterval = 0.75
            targetSeconds = 45
        case .hard:
            spawnInterval = 0.5
            targetSeconds = 60
        }
        targetSeconds += Double(level) * 1.5
        spawnInterval -= Double(level) * 0.03
        spawnInterval = max(spawnInterval, 0.35)
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
        shipXRatio = 0.5
        speedMultiplier = 1
        peakCombo = 0
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

        spawnMeteor()
    }

    func stopGame() {
        isPlaying = false
        spawnTimer?.cancel()
        gameTimer?.cancel()
    }

    func togglePause() {
        effects.isPaused.toggle()
    }

    func updateShipPosition(ratio: CGFloat) {
        guard !effects.isPaused else { return }
        shipXRatio = min(0.9, max(0.1, ratio))
    }

    private func tick() {
        guard isPlaying, !effects.isPaused, screenSize.height > 0 else { return }

        survivedSeconds += 1.0 / 60.0
        speedMultiplier += 0.0008 * levelMultiplier

        let shipX = shipXRatio * screenSize.width
        let shipY = screenSize.height * 0.8

        meteors = meteors.compactMap { meteor in
            var updated = meteor
            let baseSpeed: CGFloat
            switch difficulty {
            case .easy: baseSpeed = 2.5
            case .normal: baseSpeed = 3.2
            case .hard: baseSpeed = 4.0
            }
            updated.y += baseSpeed * speedMultiplier * levelMultiplier

            let dx = updated.x - shipX
            let dy = updated.y - shipY
            let distance = sqrt(dx * dx + dy * dy)

            if checkCollision(meteor: updated) {
                effects.registerMiss()
                endGame(success: false)
                return nil
            }

            if distance < 55 && distance >= 42 {
                effects.triggerNearMiss()
            }

            if updated.y > screenSize.height * 1.1 {
                effects.registerHit()
                peakCombo = max(peakCombo, effects.comboCount)
                return nil
            }

            return updated
        }

        if survivedSeconds >= targetSeconds {
            earnedStars = stars(for: survivedSeconds)
            endGame(success: true)
        }
    }

    private func spawnMeteor() {
        guard isPlaying, !effects.isPaused, screenSize.width > 0 else { return }
        let xRatio = CGFloat.random(in: 0.1...0.9)
        meteors.append(MeteorEntity(x: xRatio * screenSize.width, y: -screenSize.height * 0.1, speed: 0))
    }

    private func checkCollision(meteor: MeteorEntity) -> Bool {
        let shipX = shipXRatio * screenSize.width
        let shipY = screenSize.height * 0.8
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
                activityId: "asteroid_evasion",
                difficulty: difficulty,
                level: level,
                starsEarned: earnedStars,
                playTimeSeconds: playTime,
                sessionScore: 0,
                survivalSeconds: survivedSeconds,
                peakCombo: peakCombo
            )
        } else {
            store.recordSession(
                activityId: "asteroid_evasion",
                survivalSeconds: survivedSeconds,
                combo: peakCombo,
                playTimeSeconds: playTime
            )
        }
        newAchievements = store.newlyUnlockedAchievements(comparedTo: achievementSnapshot)
        showResult = true
    }

    func stars(for seconds: Double) -> Int {
        if seconds >= 60 { return 3 }
        if seconds >= 45 { return 2 }
        if seconds >= 30 { return 1 }
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
