import SwiftUI

enum ShipSkinAnimation: String {
    case classicPulse
    case blazeFlame
    case neonGlow
    case royalShimmer
    case pulseRing
    case auroraShift
}

struct ShipSkin: Identifiable {
    let id: String
    let title: String
    let subtitle: String
    let imageName: String
    let primary: Color
    let accent: Color
    let starsRequired: Int
    let animation: ShipSkinAnimation

    static let all: [ShipSkin] = [
        ShipSkin(
            id: "default",
            title: "Classic",
            subtitle: "Steady thrusters",
            imageName: "ShipSkinDefault",
            primary: .appPrimary,
            accent: .appAccent,
            starsRequired: 0,
            animation: .classicPulse
        ),
        ShipSkin(
            id: "blaze",
            title: "Blaze",
            subtitle: "Inferno exhaust",
            imageName: "ShipSkinBlaze",
            primary: .appAccent,
            accent: .appPrimary,
            starsRequired: 15,
            animation: .blazeFlame
        ),
        ShipSkin(
            id: "neon",
            title: "Neon",
            subtitle: "Pulsing aura",
            imageName: "ShipSkinNeon",
            primary: .appPrimary,
            accent: .appSurface,
            starsRequired: 30,
            animation: .neonGlow
        ),
        ShipSkin(
            id: "pulse",
            title: "Pulse",
            subtitle: "Radar waves",
            imageName: "ShipSkinPulse",
            primary: .appAccent,
            accent: .appTextPrimary,
            starsRequired: 45,
            animation: .pulseRing
        ),
        ShipSkin(
            id: "royal",
            title: "Royal",
            subtitle: "Golden shimmer",
            imageName: "ShipSkinRoyal",
            primary: .appTextPrimary,
            accent: .appPrimary,
            starsRequired: 60,
            animation: .royalShimmer
        ),
        ShipSkin(
            id: "aurora",
            title: "Aurora",
            subtitle: "Flowing lights",
            imageName: "ShipSkinAurora",
            primary: .appSurface,
            accent: .appAccent,
            starsRequired: 90,
            animation: .auroraShift
        )
    ]

    static func find(id: String) -> ShipSkin {
        all.first(where: { $0.id == id }) ?? all[0]
    }

    func isUnlocked(totalStars: Int) -> Bool {
        totalStars >= starsRequired
    }
}
