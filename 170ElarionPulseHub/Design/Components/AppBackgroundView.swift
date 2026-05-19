import SwiftUI
import UIKit

struct AppBackgroundView: View {
    var body: some View {
        ZStack {
            AppGradientUIView()
            StaticStarfieldView()
        }
        .ignoresSafeArea()
    }
}

/// UIKit gradient — GPU-friendly, no SwiftUI animation overhead.
private struct AppGradientUIView: UIViewRepresentable {
    func makeUIView(context: Context) -> AppGradientUIViewImpl {
        AppGradientUIViewImpl()
    }

    func updateUIView(_ uiView: AppGradientUIViewImpl, context: Context) {
        uiView.updateGradient()
    }
}

private final class AppGradientUIViewImpl: UIView {
    private let gradientLayer = CAGradientLayer()

    override init(frame: CGRect) {
        super.init(frame: frame)
        isUserInteractionEnabled = false
        gradientLayer.startPoint = CGPoint(x: 0.1, y: 0)
        gradientLayer.endPoint = CGPoint(x: 0.9, y: 1)
        gradientLayer.locations = [0, 0.55, 1]
        layer.insertSublayer(gradientLayer, at: 0)
        updateGradient()
    }

    required init?(coder: NSCoder) {
        nil
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = bounds
    }

    func updateGradient() {
        let background = UIColor(named: "AppBackground") ?? UIColor(red: 0, green: 55 / 255, blue: 114 / 255, alpha: 1)
        let surface = UIColor(named: "AppSurface") ?? UIColor(red: 31 / 255, green: 79 / 255, blue: 131 / 255, alpha: 1)
        let primary = UIColor(named: "AppPrimary") ?? UIColor(red: 1, green: 0, blue: 0.565, alpha: 1)
        gradientLayer.colors = [
            background.cgColor,
            surface.withAlphaComponent(0.85).cgColor,
            primary.withAlphaComponent(0.12).cgColor
        ]
    }
}

/// Static stars — no TimelineView, redraws only on layout (scroll-friendly).
struct StaticStarfieldView: View {
    var opacity: Double = 0.38
    private let starCount = 26

    var body: some View {
        Canvas { context, size in
            guard size.width > 1, size.height > 1 else { return }
            for index in 0..<starCount {
                let seed = Double(index) * 1.37
                let x = (sin(seed * 3.1) * 0.5 + 0.5) * size.width
                let y = (cos(seed * 2.7) * 0.5 + 0.5) * size.height
                let radius = CGFloat(1 + (index % 3))
                let alpha = opacity * (0.35 + Double(index % 5) * 0.1)
                let rect = CGRect(x: x, y: y, width: radius, height: radius)
                context.fill(
                    Path(ellipseIn: rect),
                    with: .color(Color.appTextPrimary.opacity(alpha))
                )
            }
        }
        .allowsHitTesting(false)
    }
}

/// Legacy name — routes to static implementation for performance.
struct StarfieldCanvas: View {
    var opacity: Double = 0.38

    var body: some View {
        StaticStarfieldView(opacity: opacity)
    }
}

struct HostingBackgroundFixer: UIViewRepresentable {
    func makeUIView(context: Context) -> UIView {
        let view = UIView(frame: .zero)
        view.isUserInteractionEnabled = false
        view.backgroundColor = .clear
        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) {
        DispatchQueue.main.async {
            AppAppearance.applyHostingBackground(from: uiView)
        }
    }
}
