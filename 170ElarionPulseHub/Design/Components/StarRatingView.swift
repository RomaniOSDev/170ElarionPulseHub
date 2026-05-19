import SwiftUI

struct StarRatingView: View {
    let count: Int
    var max: Int = 3
    var animated: Bool = false
    @State private var visibleCount = 0

    var body: some View {
        HStack(spacing: 6) {
            ForEach(0..<max, id: \.self) { index in
                Text("⭐")
                    .font(.title2)
                    .opacity(index < (animated ? visibleCount : count) ? 1 : 0.25)
                    .scaleEffect(index < (animated ? visibleCount : count) ? 1.1 : 0.85)
                    .shadow(
                        color: index < (animated ? visibleCount : count) ? .appAccent.opacity(0.8) : .clear,
                        radius: 8
                    )
            }
        }
        .onAppear {
            guard animated else { return }
            visibleCount = 0
            for index in 0..<count {
                DispatchQueue.main.asyncAfter(deadline: .now() + Double(index) * 0.15) {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                        visibleCount = index + 1
                    }
                    if index == 0 || index == count - 1 {
                        HapticService.success()
                    }
                }
            }
        }
    }
}
