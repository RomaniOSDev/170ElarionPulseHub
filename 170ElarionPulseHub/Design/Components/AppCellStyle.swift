import SwiftUI

enum AppCellAccent {
    case primary
    case accent
    case warm

    var color: Color {
        switch self {
        case .primary: return .appPrimary
        case .accent: return .appAccent
        case .warm: return .appPrimary.opacity(0.85)
        }
    }
}

struct AppCardStyle: ViewModifier {
    var accent: AppCellAccent = .primary
    var highlighted: Bool = false
    var cornerRadius: CGFloat = 18

    func body(content: Content) -> some View {
        content
            .background {
                AppCardBackground(accent: accent, highlighted: highlighted, cornerRadius: cornerRadius)
            }
            .appDepthShadow(accent: accent, elevated: highlighted)
    }
}

struct AppIconBadge: View {
    let systemName: String
    var accent: AppCellAccent = .primary
    var size: CGFloat = 52

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            accent.color.opacity(0.42),
                            accent.color.opacity(0.14),
                            Color.appBackground.opacity(0.5)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay {
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .stroke(Color.appTextPrimary.opacity(0.12), lineWidth: 1)
                }
            Image(systemName: systemName)
                .font(.system(size: size * 0.42, weight: .semibold))
                .foregroundStyle(
                    LinearGradient(
                        colors: [accent.color, .appTextPrimary.opacity(0.9)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .symbolRenderingMode(.hierarchical)
        }
        .frame(width: size, height: size)
        .appDepthShadow(accent: accent)
    }
}

struct AppChevronBadge: View {
    var body: some View {
        Image(systemName: "chevron.right")
            .font(.caption.weight(.bold))
            .foregroundColor(.appAccent)
            .padding(8)
            .background(
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color.appSurface, Color.appBackground.opacity(0.8)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            )
            .overlay(Circle().stroke(Color.appPrimary.opacity(0.25), lineWidth: 1))
    }
}

extension View {
    func appCard(accent: AppCellAccent = .primary, highlighted: Bool = false, cornerRadius: CGFloat = 18) -> some View {
        modifier(AppCardStyle(accent: accent, highlighted: highlighted, cornerRadius: cornerRadius))
    }
}
