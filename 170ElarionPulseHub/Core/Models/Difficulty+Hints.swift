import Foundation

extension Difficulty {
    func hint(for activityId: String) -> String {
        switch activityId {
        case "meteor_tap":
            switch self {
            case .easy: return "Slower meteors · tap to shoot"
            case .normal: return "Balanced spawn rate"
            case .hard: return "Fast meteors · tight timing"
            }
        case "asteroid_evasion":
            switch self {
            case .easy: return "Survive 30s · drag to dodge"
            case .normal: return "Survive 45s"
            case .hard: return "Survive 60s · dense field"
            }
        case "meteor_glide":
            switch self {
            case .easy: return "Hold to steer · survive 15s"
            case .normal: return "Survive 30s"
            case .hard: return "Survive 45s · rapid spawns"
            }
        default:
            return title
        }
    }
}
