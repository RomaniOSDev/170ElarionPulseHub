import Foundation

struct PilotRank: Identifiable {
    let id: String
    let title: String
    let iconName: String
    let minimumStars: Int

    static let all: [PilotRank] = [
        PilotRank(id: "cadet", title: "Cadet", iconName: "airplane.circle", minimumStars: 0),
        PilotRank(id: "rookie", title: "Rookie Pilot", iconName: "airplane", minimumStars: 10),
        PilotRank(id: "ace", title: "Ace", iconName: "star.circle.fill", minimumStars: 25),
        PilotRank(id: "veteran", title: "Veteran", iconName: "shield.fill", minimumStars: 50),
        PilotRank(id: "legend", title: "Legend", iconName: "crown.fill", minimumStars: 75)
    ]

    static func current(for totalStars: Int) -> PilotRank {
        all.last(where: { totalStars >= $0.minimumStars }) ?? all[0]
    }

    static func next(after rank: PilotRank) -> PilotRank? {
        guard let index = all.firstIndex(where: { $0.id == rank.id }), index + 1 < all.count else {
            return nil
        }
        return all[index + 1]
    }
}
