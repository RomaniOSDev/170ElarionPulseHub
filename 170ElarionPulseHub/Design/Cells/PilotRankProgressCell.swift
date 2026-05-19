import SwiftUI

struct PilotRankProgressCell: View {
    @EnvironmentObject private var progress: GameProgressStore

    var body: some View {
        let rank = progress.pilotRank
        let next = PilotRank.next(after: rank)
        let fraction = rankProgressFraction(current: rank, next: next)

        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .stroke(Color.appBackground.opacity(0.6), lineWidth: 5)
                Circle()
                    .trim(from: 0, to: fraction)
                    .stroke(
                        LinearGradient(
                            colors: [.appPrimary, .appAccent],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        style: StrokeStyle(lineWidth: 5, lineCap: .round)
                    )
                    .rotationEffect(.degrees(-90))
                Image(systemName: rank.iconName)
                    .font(.title2)
                    .foregroundColor(.appPrimary)
            }
            .frame(width: 58, height: 58)

            VStack(alignment: .leading, spacing: 6) {
                Text("Pilot Rank")
                    .font(.caption.weight(.semibold))
                    .foregroundColor(.appTextSecondary)
                Text(rank.title)
                    .font(.title3.bold())
                    .foregroundColor(.appTextPrimary)
                if let next {
                    Text("\(max(0, next.minimumStars - progress.totalStarsEarned)) stars to \(next.title)")
                        .font(.caption)
                        .foregroundColor(.appTextSecondary)
                        .lineLimit(2)
                        .minimumScaleFactor(0.7)
                } else {
                    Text("Maximum rank achieved")
                        .font(.caption)
                        .foregroundColor(.appAccent)
                }
            }

            Spacer(minLength: 0)

            VStack(spacing: 2) {
                Text("\(progress.totalStarsEarned)")
                    .font(.title2.bold())
                    .foregroundColor(.appAccent)
                Text("stars")
                    .font(.caption2)
                    .foregroundColor(.appTextSecondary)
            }
        }
        .padding(16)
        .appCard(accent: .accent, highlighted: true)
    }

    private func rankProgressFraction(current: PilotRank, next: PilotRank?) -> CGFloat {
        guard let next else { return 1 }
        let span = max(1, next.minimumStars - current.minimumStars)
        let earned = progress.totalStarsEarned - current.minimumStars
        return CGFloat(min(max(earned, 0), span)) / CGFloat(span)
    }
}
