import SwiftUI

/// Shared visual tokens — keep shadows shallow and gradients static for smooth scrolling.
enum AppDepth {
    static let cardShadowRadius: CGFloat = 8
    static let cardShadowY: CGFloat = 4
    static let elevatedShadowRadius: CGFloat = 12
    static let elevatedShadowY: CGFloat = 6
    static let tabBarShadowRadius: CGFloat = 14
}

enum AppGradients {
    static func cardSurface(highlighted: Bool) -> LinearGradient {
        LinearGradient(
            colors: [
                Color.appSurface.opacity(highlighted ? 1 : 0.96),
                Color.appSurface.opacity(0.78),
                Color.appBackground.opacity(0.72)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    static var cardBorder: LinearGradient {
        LinearGradient(
            colors: [
                Color.appTextPrimary.opacity(0.22),
                Color.appPrimary.opacity(0.35),
                Color.appAccent.opacity(0.18)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    static var cardTopSheen: LinearGradient {
        LinearGradient(
            colors: [
                Color.appTextPrimary.opacity(0.14),
                Color.clear
            ],
            startPoint: .top,
            endPoint: .bottom
        )
    }

    static var primaryButton: LinearGradient {
        LinearGradient(
            colors: [.appPrimary, .appAccent.opacity(0.92)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    static var tabBarSurface: LinearGradient {
        LinearGradient(
            colors: [
                Color.appSurface.opacity(0.97),
                Color.appBackground.opacity(0.92)
            ],
            startPoint: .top,
            endPoint: .bottom
        )
    }

    static var panelOverlay: LinearGradient {
        LinearGradient(
            colors: [
                Color.appSurface.opacity(0.98),
                Color.appBackground.opacity(0.94)
            ],
            startPoint: .top,
            endPoint: .bottom
        )
    }
}

struct AppCardBackground: View {
    var accent: AppCellAccent
    var highlighted: Bool
    var cornerRadius: CGFloat

    var body: some View {
        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
            .fill(AppGradients.cardSurface(highlighted: highlighted))
            .overlay(alignment: .top) {
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(AppGradients.cardTopSheen)
                    .frame(height: cornerRadius * 1.1)
                    .allowsHitTesting(false)
            }
            .overlay {
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .stroke(
                        highlighted ? AppGradients.cardBorder : LinearGradient(
                            colors: [accent.color.opacity(0.28), accent.color.opacity(0.12)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: highlighted ? 1.5 : 1
                    )
            }
    }
}

extension View {
    /// Single-pass depth shadow — cheaper than stacking multiple shadows.
    func appDepthShadow(accent: AppCellAccent = .primary, elevated: Bool = false) -> some View {
        shadow(
            color: accent.color.opacity(elevated ? 0.22 : 0.12),
            radius: elevated ? AppDepth.elevatedShadowRadius : AppDepth.cardShadowRadius,
            y: elevated ? AppDepth.elevatedShadowY : AppDepth.cardShadowY
        )
    }

    func appElevatedPanel(accent: AppCellAccent = .primary, cornerRadius: CGFloat = 22) -> some View {
        padding(20)
            .background {
                AppCardBackground(accent: accent, highlighted: true, cornerRadius: cornerRadius)
            }
            .appDepthShadow(accent: accent, elevated: true)
    }
}
