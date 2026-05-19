import Foundation

extension GameProgressStore {
    var unlockedAchievementsCount: Int {
        achievements.filter { isAchievementUnlocked($0) }.count
    }

    var totalPossibleStars: Int {
        ActivityItem.all.count * Self.maxStarsPerActivity
    }

    var overallStarProgress: Double {
        guard totalPossibleStars > 0 else { return 0 }
        return Double(totalStarsEarned) / Double(totalPossibleStars)
    }

    /// Activity with the most room to earn stars, or most played.
    var featuredActivity: ActivityItem {
        let ranked = ActivityItem.all.map { activity -> (ActivityItem, Int, Int) in
            let earned = totalStars(for: activity.id)
            let sessions = activityStat(for: activity.id).sessionsPlayed
            return (activity, earned, sessions)
        }
        if let lowProgress = ranked.min(by: { $0.1 < $1.1 })?.0, totalStars(for: lowProgress.id) < Self.maxStarsPerActivity {
            return lowProgress
        }
        return ranked.max(by: { $0.2 < $1.2 })?.0 ?? ActivityItem.all[0]
    }

    func rankProgressFraction() -> Double {
        let rank = pilotRank
        guard let next = PilotRank.next(after: rank) else { return 1 }
        let span = max(1, next.minimumStars - rank.minimumStars)
        let earned = totalStarsEarned - rank.minimumStars
        return Double(min(max(earned, 0), span)) / Double(span)
    }

    func nextPlayableLevel(for activityId: String, difficulty: Difficulty = .easy) -> Int {
        let highest = highestUnlockedLevel(activityId: activityId, difficulty: difficulty)
        for level in 0...highest {
            if stars(activityId: activityId, difficulty: difficulty, level: level) < 3 {
                return level
            }
        }
        return min(highest, Self.levelsPerDifficulty - 1)
    }
}
