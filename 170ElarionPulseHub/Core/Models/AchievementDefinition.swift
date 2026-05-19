import Foundation

struct AchievementDefinition: Identifiable {
    let id: String
    let title: String
    let description: String
    let iconName: String
    let isUnlocked: (GameProgressStore) -> Bool

    static let all: [AchievementDefinition] = [
        AchievementDefinition(
            id: "first_star",
            title: "First Star",
            description: "You earned your first star.",
            iconName: "star.fill",
            isUnlocked: { $0.totalStarsEarned >= 1 }
        ),
        AchievementDefinition(
            id: "rookie_pilot",
            title: "Rookie Pilot",
            description: "Complete 10 activities.",
            iconName: "airplane",
            isUnlocked: { $0.totalActivitiesPlayed >= 10 }
        ),
        AchievementDefinition(
            id: "star_hoarder",
            title: "Star Hoarder",
            description: "Collect a total of 50 stars.",
            iconName: "star.circle.fill",
            isUnlocked: { $0.totalStarsEarned >= 50 }
        ),
        AchievementDefinition(
            id: "in_the_sky",
            title: "...In The Sky!",
            description: "'Meteor Dodge' for an hour in total.",
            iconName: "cloud.fill",
            isUnlocked: { $0.totalPlayTimeSeconds >= 3600 }
        ),
        AchievementDefinition(
            id: "star_collector",
            title: "Star Collector",
            description: "Earned 25 stars total.",
            iconName: "sparkles",
            isUnlocked: { $0.totalStarsEarned >= 25 }
        ),
        AchievementDefinition(
            id: "star_master",
            title: "Star Master",
            description: "Earned 75 stars total.",
            iconName: "crown.fill",
            isUnlocked: { $0.totalStarsEarned >= 75 }
        ),
        AchievementDefinition(
            id: "active_player",
            title: "Active Player",
            description: "Completed 25 activity sessions.",
            iconName: "bolt.fill",
            isUnlocked: { $0.totalActivitiesPlayed >= 25 }
        ),
        AchievementDefinition(
            id: "hundred_plays",
            title: "Hundred Plays",
            description: "Completed 100 activity sessions.",
            iconName: "trophy.circle.fill",
            isUnlocked: { $0.totalActivitiesPlayed >= 100 }
        )
    ]
}
