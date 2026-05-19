import SwiftUI

struct LevelGridCell: View {
    let level: Int
    let stars: Int
    let locked: Bool
    var recordText: String?
    var isPerfect: Bool { stars >= 3 }

    var body: some View {
        VStack(spacing: 6) {
            ZStack {
                if locked {
                    Image(systemName: "lock.fill")
                        .font(.title3)
                        .foregroundColor(.appTextSecondary.opacity(0.7))
                } else {
                    Text("\(level)")
                        .font(.headline.bold())
                        .foregroundColor(.appTextPrimary)
                }
            }
            .frame(height: 28)

            StarRatingView(count: stars, max: 3)
                .scaleEffect(0.55)
                .frame(height: 18)

            if let recordText, !locked {
                Text(recordText)
                    .font(.system(size: 8, weight: .semibold))
                    .foregroundColor(.appAccent)
                    .lineLimit(1)
                    .minimumScaleFactor(0.6)
            } else {
                Color.clear.frame(height: 10)
            }
        }
        .frame(maxWidth: .infinity, minHeight: 82)
        .padding(.vertical, 8)
        .padding(.horizontal, 4)
        .appCard(
            accent: locked ? .primary : (isPerfect ? .accent : .primary),
            highlighted: !locked && stars > 0,
            cornerRadius: 12
        )
        .opacity(locked ? 0.55 : 1)
    }
}
