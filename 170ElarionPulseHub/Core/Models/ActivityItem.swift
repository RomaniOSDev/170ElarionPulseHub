import Foundation

struct ActivityItem: Identifiable, Hashable {
    let id: String
    let title: String
    let subtitle: String
    let iconName: String

    static let all: [ActivityItem] = [
        ActivityItem(
            id: "meteor_tap",
            title: "Meteor Tap Odyssey",
            subtitle: "Tap meteors before they reach your ship",
            iconName: "hand.tap.fill"
        ),
        ActivityItem(
            id: "asteroid_evasion",
            title: "Asteroid Evasion",
            subtitle: "Swipe to dodge falling meteors",
            iconName: "arrow.left.and.right"
        ),
        ActivityItem(
            id: "meteor_glide",
            title: "Meteor Glide",
            subtitle: "Hold to steer through the storm",
            iconName: "hand.point.up.left.fill"
        )
    ]

    static func find(id: String) -> ActivityItem? {
        all.first { $0.id == id }
    }
}
