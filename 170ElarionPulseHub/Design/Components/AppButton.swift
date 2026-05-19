import SwiftUI

struct AppButton: View {
    let title: String
    var style: Style = .primary
    var action: () -> Void

    enum Style {
        case primary
        case secondary
        case destructive
    }

    @State private var isPressed = false

    private let cornerRadius: CGFloat = 14

    var body: some View {
        Button {
            HapticService.lightTap()
            action()
        } label: {
            Text(title)
                .font(.headline)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
                .foregroundColor(foregroundColor)
                .frame(maxWidth: .infinity)
                .padding(.horizontal, 16)
                .padding(.vertical, 13)
                .background { buttonBackground }
                .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
                .overlay {
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .stroke(borderGradient, lineWidth: style == .secondary ? 1 : 1.2)
                }
                .overlay(alignment: .top) {
                    if style == .primary {
                        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                            .fill(
                                LinearGradient(
                                    colors: [Color.white.opacity(0.22), Color.clear],
                                    startPoint: .top,
                                    endPoint: .center
                                )
                            )
                            .frame(height: cornerRadius * 1.4)
                            .allowsHitTesting(false)
                    }
                }
        }
        .buttonStyle(.plain)
        .scaleEffect(isPressed ? 0.96 : 1)
        .appDepthShadow(accent: shadowAccent, elevated: style == .primary)
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in
                    withAnimation(.easeInOut(duration: 0.15)) { isPressed = true }
                }
                .onEnded { _ in
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) { isPressed = false }
                }
        )
        .frame(minHeight: 48)
    }

    @ViewBuilder
    private var buttonBackground: some View {
        switch style {
        case .primary:
            AppGradients.primaryButton
        case .secondary:
            AppGradients.cardSurface(highlighted: false)
        case .destructive:
            LinearGradient(
                colors: [Color.red.opacity(0.92), Color.red.opacity(0.72)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
    }

    private var foregroundColor: Color { .appTextPrimary }

    private var borderGradient: LinearGradient {
        switch style {
        case .primary:
            return LinearGradient(
                colors: [Color.white.opacity(0.35), Color.appAccent.opacity(0.5)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .secondary:
            return LinearGradient(
                colors: [Color.appPrimary.opacity(0.4), Color.appAccent.opacity(0.2)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .destructive:
            return LinearGradient(
                colors: [Color.white.opacity(0.25), Color.red.opacity(0.4)],
                startPoint: .top,
                endPoint: .bottom
            )
        }
    }

    private var shadowAccent: AppCellAccent {
        switch style {
        case .primary: return .accent
        case .destructive: return .warm
        case .secondary: return .primary
        }
    }
}
