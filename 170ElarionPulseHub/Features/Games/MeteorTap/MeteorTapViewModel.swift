import Combine
import Foundation
import SwiftUI

struct MeteorEntity: Identifiable {
    let id = UUID()
    var x: CGFloat
    var y: CGFloat
    var speed: CGFloat
}

struct LaserShot: Identifiable {
    let id = UUID()
    var x: CGFloat
    var y: CGFloat
    var directionX: CGFloat
    var directionY: CGFloat
    let speed: CGFloat = 16
}

@MainActor
final class MeteorTapViewModel: ObservableObject {
    @Published var meteors: [MeteorEntity] = []
    @Published var lasers: [LaserShot] = []
    @Published var shipXRatio: CGFloat = 0.5
    @Published var score = 0
    @Published var isPlaying = false
    @Published var showResult = false
    @Published var didWin = false
    @Published var earnedStars = 0
    @Published var tapsDisabled = false
    @Published var newAchievements: [AchievementDefinition] = []
    let effects = GameEffectsState()

    let difficulty: Difficulty
    let level: Int

    private var screenSize = CGSize.zero
    private var spawnInterval: TimeInterval
    private var minSpeed: CGFloat
    private var maxSpeed: CGFloat
    private var spawnTimer: AnyCancellable?
    private var gameTimer: AnyCancellable?
    private var elapsedSeconds = 0
    private var sessionStart: Date?
    private var peakCombo = 0
    private var achievementSnapshot = AchievementSnapshot(store: GameProgressStore.shared)

    private var levelMultiplier: CGFloat {
        1 + CGFloat(level) * 0.07
    }

    init(difficulty: Difficulty, level: Int) {
        self.difficulty = difficulty
        self.level = level
        switch difficulty {
        case .easy:
            spawnInterval = 1.5
            minSpeed = 1.0
            maxSpeed = 1.5
        case .normal:
            spawnInterval = 1.0
            minSpeed = 1.5
            maxSpeed = 2.0
        case .hard:
            spawnInterval = 0.7
            minSpeed = 2.0
            maxSpeed = 3.0
        }
        spawnInterval -= Double(level) * 0.04
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
        lasers = []
        shipXRatio = 0.5
        score = 0
        peakCombo = 0
        didWin = false
        earnedStars = 0
        showResult = false
        isPlaying = true
        elapsedSeconds = 0
        sessionStart = Date()
        effects.resetSession()
        achievementSnapshot = GameProgressStore.shared.achievementSnapshot()
        HapticService.mediumTap()

        spawnTimer?.cancel()
        spawnTimer = Timer.publish(every: spawnInterval, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.spawnMeteor()
                self?.tightenSpawnRate()
            }

        gameTimer?.cancel()
        gameTimer = Timer.publish(every: 1.0 / 60.0, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.tick()
            }

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

    func shoot(toward target: CGPoint) {
        guard isPlaying, !effects.isPaused else { return }
        guard screenSize.width > 0, screenSize.height > 0 else { return }

        let shipX = shipXRatio * screenSize.width
        let shipY = screenSize.height - 100
        var dx = target.x - shipX
        var dy = target.y - shipY
        let length = sqrt(dx * dx + dy * dy)
        guard length > 4 else { return }

        dx /= length
        dy /= length

        lasers.append(
            LaserShot(
                x: shipX,
                y: shipY - 20,
                directionX: dx,
                directionY: dy
            )
        )
        HapticService.lightTap()
    }

    private func registerHit() {
        score += 1
        effects.registerHit()
        peakCombo = max(peakCombo, effects.comboCount)
        HapticService.mediumTap()
        SoundService.playSuccess()
        tapsDisabled = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { [weak self] in
            self?.tapsDisabled = false
        }
    }

    func moveShip(ratio: CGFloat) {
        guard !effects.isPaused else { return }
        shipXRatio = min(0.9, max(0.1, ratio))
    }

    private func tick() {
        guard isPlaying, !effects.isPaused, screenSize.width > 0, screenSize.height > 0 else { return }

        let shipX = shipXRatio * screenSize.width
        let shipY = screenSize.height - 100

        updateLasers()

        meteors = meteors.compactMap { meteor in
            var updated = meteor
            updated.y += meteor.speed * levelMultiplier

            let dx = updated.x - shipX
            let dy = updated.y - shipY
            let distance = sqrt(dx * dx + dy * dy)

            if collidesWithShip(meteor: updated, shipX: shipX, shipY: shipY) {
                effects.registerMiss()
                endGame(success: false)
                return nil
            }

            if distance < 58 && distance >= 46 {
                effects.triggerNearMiss()
            }

            if updated.y > screenSize.height + 50 {
                effects.registerMiss()
                return nil
            }

            return updated
        }
    }

    private func updateLasers() {
        let hitRadius: CGFloat = 28
        var destroyedMeteorIDs = Set<UUID>()

        lasers = lasers.compactMap { laser in
            var shot = laser
            shot.x += shot.directionX * shot.speed
            shot.y += shot.directionY * shot.speed

            if let meteor = meteors.first(where: { candidate in
                guard !destroyedMeteorIDs.contains(candidate.id) else { return false }
                let dx = candidate.x - shot.x
                let dy = candidate.y - shot.y
                return sqrt(dx * dx + dy * dy) < hitRadius
            }) {
                destroyedMeteorIDs.insert(meteor.id)
                registerHit()
                return nil
            }

            if shot.x < -40 || shot.x > screenSize.width + 40 ||
                shot.y < -40 || shot.y > screenSize.height + 40 {
                return nil
            }

            return shot
        }

        if !destroyedMeteorIDs.isEmpty {
            meteors.removeAll { destroyedMeteorIDs.contains($0.id) }
        }
    }

    private func collidesWithShip(meteor: MeteorEntity, shipX: CGFloat, shipY: CGFloat) -> Bool {
        let shipRadius: CGFloat = 28
        let meteorRadius: CGFloat = 20
        let dx = meteor.x - shipX
        let dy = meteor.y - shipY
        return sqrt(dx * dx + dy * dy) < shipRadius + meteorRadius
    }

    private func spawnMeteor() {
        guard isPlaying, !effects.isPaused, screenSize.width > 0 else { return }
        let padding: CGFloat = 30
        let x = CGFloat.random(in: padding...(screenSize.width - padding))
        let speed = CGFloat.random(in: minSpeed...maxSpeed) * levelMultiplier
        meteors.append(MeteorEntity(x: x, y: -30, speed: speed))
    }

    private func tightenSpawnRate() {
        spawnInterval = max(0.32, spawnInterval * 0.985)
    }

    func endGame(success: Bool) {
        guard isPlaying else { return }
        stopGame()
        didWin = success
        earnedStars = success ? stars(for: score) : 0
        if let start = sessionStart {
            elapsedSeconds = max(1, Int(Date().timeIntervalSince(start)))
        } else {
            elapsedSeconds = max(1, score / 5)
        }
        let store = GameProgressStore.shared
        if success {
            store.completeLevel(
                activityId: "meteor_tap",
                difficulty: difficulty,
                level: level,
                starsEarned: earnedStars,
                playTimeSeconds: elapsedSeconds,
                sessionScore: score,
                survivalSeconds: 0,
                peakCombo: peakCombo
            )
        } else {
            store.recordSession(
                activityId: "meteor_tap",
                score: score,
                combo: peakCombo,
                playTimeSeconds: elapsedSeconds
            )
        }
        newAchievements = store.newlyUnlockedAchievements(comparedTo: achievementSnapshot)
        showResult = true
    }

    func stars(for score: Int) -> Int {
        if score >= 150 { return 3 }
        if score >= 100 { return 2 }
        if score >= 50 { return 1 }
        return 0
    }

    func finishEarly() {
        guard isPlaying else { return }
        HapticService.mediumTap()
        endGame(success: score >= 50)
    }
}
