import Foundation

struct DailyMission: Codable, Equatable {
    var dayKey: String
    var activityId: String
    var difficultyRaw: String
    var level: Int
    var isCompleted: Bool

    var difficulty: Difficulty {
        Difficulty(rawValue: difficultyRaw) ?? .easy
    }

    static func todayKey() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: Date())
    }
}
