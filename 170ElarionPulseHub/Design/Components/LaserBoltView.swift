import SwiftUI

struct LaserBoltView: View {
    var angle: Angle

    var body: some View {
        Capsule()
            .fill(
                LinearGradient(
                    colors: [.appAccent, .appPrimary],
                    startPoint: .bottom,
                    endPoint: .top
                )
            )
            .frame(width: 6, height: 22)
            .shadow(color: .appPrimary.opacity(0.8), radius: 4)
            .rotationEffect(angle)
    }
}
