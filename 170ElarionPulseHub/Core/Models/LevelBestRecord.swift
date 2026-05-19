import Foundation

struct LevelBestRecord: Codable, Equatable {
    var bestScore: Int
    var bestSurvivalSeconds: Double
    var bestCombo: Int

    init(bestScore: Int = 0, bestSurvivalSeconds: Double = 0, bestCombo: Int = 0) {
        self.bestScore = bestScore
        self.bestSurvivalSeconds = bestSurvivalSeconds
        self.bestCombo = bestCombo
    }

    func formattedScore() -> String {
        bestScore > 0 ? "\(bestScore)" : "—"
    }

    func formattedSurvival() -> String {
        bestSurvivalSeconds > 0 ? String(format: "%.1fs", bestSurvivalSeconds) : "—"
    }
}

struct ActivitySessionStats: Codable, Equatable {
    var sessionsPlayed: Int
    var bestScore: Int
    var bestSurvivalSeconds: Double
    var highestCombo: Int

    init(
        sessionsPlayed: Int = 0,
        bestScore: Int = 0,
        bestSurvivalSeconds: Double = 0,
        highestCombo: Int = 0
    ) {
        self.sessionsPlayed = sessionsPlayed
        self.bestScore = bestScore
        self.bestSurvivalSeconds = bestSurvivalSeconds
        self.highestCombo = highestCombo
    }
}
