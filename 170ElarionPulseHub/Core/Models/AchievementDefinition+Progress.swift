import Foundation

extension AchievementDefinition {
    func progressHint(store: GameProgressStore) -> String? {
        guard !store.isAchievementUnlocked(self) else { return nil }
        switch id {
        case "first_star":
            return "\(min(store.totalStarsEarned, 1))/1 stars"
        case "rookie_pilot":
            return "\(min(store.totalActivitiesPlayed, 10))/10 sessions"
        case "star_hoarder":
            return "\(min(store.totalStarsEarned, 50))/50 stars"
        case "in_the_sky":
            let minutes = store.totalPlayTimeSeconds / 60
            return "\(min(minutes, 60))/60 min played"
        case "star_collector":
            return "\(min(store.totalStarsEarned, 25))/25 stars"
        case "star_master":
            return "\(min(store.totalStarsEarned, 75))/75 stars"
        case "active_player":
            return "\(min(store.totalActivitiesPlayed, 25))/25 sessions"
        case "hundred_plays":
            return "\(min(store.totalActivitiesPlayed, 100))/100 sessions"
        default:
            return nil
        }
    }
}
