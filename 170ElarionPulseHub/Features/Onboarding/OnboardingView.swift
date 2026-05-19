import SwiftUI

private struct OnboardingPageModel: Identifiable {
    let id: Int
    let headline: String
    let body: String
    let iconName: String
    let accent: AppCellAccent
    let features: [(icon: String, text: String)]
    let illustration: OnboardingIllustrationKind
}

struct OnboardingView: View {
    @EnvironmentObject private var progress: GameProgressStore
    @State private var pageIndex = 0
    @State private var illustrationScale: CGFloat = 0.92
    @State private var illustrationOpacity: Double = 0

    private let pages: [OnboardingPageModel] = [
        OnboardingPageModel(
            id: 0,
            headline: "Master The Controls",
            body: "Steer through the meteor storm with smooth touch gestures.",
            iconName: "hand.draw.fill",
            accent: .accent,
            features: [
                ("arrow.left.and.right", "Drag to move your ship"),
                ("hand.tap.fill", "Tap to shoot in Meteor Tap"),
                ("flag.checkered", "Tap Finish anytime to end a run")
            ],
            illustration: .swipe
        ),
        OnboardingPageModel(
            id: 1,
            headline: "Earn Stars & Rank Up",
            body: "Complete levels, unlock achievements, and climb pilot ranks.",
            iconName: "star.fill",
            accent: .primary,
            features: [
                ("star.leadinghalf.filled", "Up to 3 stars per level"),
                ("shield.fill", "Unlock Veteran and Legend ranks"),
                ("rosette", "Collect 8 achievement badges")
            ],
            illustration: .stars
        ),
        OnboardingPageModel(
            id: 2,
            headline: "Begin Your Flight",
            body: "Three missions, daily challenges, and ship styles await.",
            iconName: "airplane.departure",
            accent: .accent,
            features: [
                ("sun.max.fill", "Complete the daily mission for bonus stars"),
                ("gamecontroller.fill", "Three unique arcade missions"),
                ("paintbrush.fill", "Unlock animated ship styles")
            ],
            illustration: .launch
        )
    ]

    var body: some View {
        VStack(spacing: 0) {
            onboardingHeader
                .padding(.horizontal, 24)
                .padding(.top, 16)
                .padding(.bottom, 8)

            TabView(selection: $pageIndex) {
                ForEach(pages) { page in
                    onboardingPage(page)
                        .tag(page.id)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .animation(.easeInOut(duration: 0.28), value: pageIndex)

            footerControls
                .padding(.horizontal, 24)
                .padding(.bottom, 28)
        }
        .background { AppBackgroundView() }
        .onChange(of: pageIndex) { _ in animateIllustration() }
        .onAppear { animateIllustration() }
    }

    private var onboardingHeader: some View {
        HStack(alignment: .center, spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Welcome, Pilot")
                    .font(.caption.weight(.bold))
                    .foregroundColor(.appAccent)
                Text("Flight Briefing")
                    .font(.title2.bold())
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.appTextPrimary, .appTextPrimary.opacity(0.85)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
            }
            Spacer()
            Text("Step \(pageIndex + 1)/\(pages.count)")
                .font(.caption.weight(.bold))
                .foregroundColor(.appTextPrimary)
                .padding(.horizontal, 12)
                .padding(.vertical, 7)
                .background(
                    LinearGradient(
                        colors: [.appPrimary.opacity(0.5), .appAccent.opacity(0.35)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .clipShape(Capsule())
                .overlay(Capsule().stroke(Color.appTextPrimary.opacity(0.18), lineWidth: 1))
        }
        .padding(14)
        .background { AppCardBackground(accent: .accent, highlighted: false, cornerRadius: 18) }
        .appDepthShadow(accent: .accent)
    }

    private func onboardingPage(_ page: OnboardingPageModel) -> some View {
        let isActive = pageIndex == page.id

        return ScrollView {
            VStack(spacing: 18) {
                illustrationCard(page: page, isActive: isActive)
                textCard(page: page)
                featuresCard(page: page)
            }
            .padding(.horizontal, 24)
            .padding(.top, 8)
            .padding(.bottom, 12)
        }
        .transparentAppScreen()
    }

    private func illustrationCard(page: OnboardingPageModel, isActive: Bool) -> some View {
        ZStack {
            if page.illustration == .launch {
                RadialGradient(
                    colors: [.appPrimary.opacity(0.35), .clear],
                    center: .center,
                    startRadius: 8,
                    endRadius: 120
                )
            }

            Group {
                if page.illustration == .launch {
                    OnboardingLaunchIllustration()
                } else {
                    OnboardingIllustrationView(kind: page.illustration)
                }
            }
            .frame(height: 220)
            .frame(maxWidth: .infinity)
        }
        .padding(16)
        .background {
            AppCardBackground(accent: page.accent, highlighted: isActive, cornerRadius: 22)
        }
        .appDepthShadow(accent: page.accent, elevated: isActive)
        .scaleEffect(isActive ? illustrationScale : 0.94)
        .opacity(isActive ? illustrationOpacity : 0.45)
    }

    private func textCard(page: OnboardingPageModel) -> some View {
        VStack(spacing: 12) {
            HStack(spacing: 10) {
                AppIconBadge(systemName: page.iconName, accent: page.accent, size: 40)
                Text(page.headline)
                    .font(.title3.bold())
                    .foregroundColor(.appTextPrimary)
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }

            Text(page.body)
                .font(.body)
                .foregroundColor(.appTextSecondary)
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(18)
        .frame(maxWidth: .infinity)
        .background { AppCardBackground(accent: page.accent, highlighted: false, cornerRadius: 18) }
        .appDepthShadow(accent: page.accent)
    }

    private func featuresCard(page: OnboardingPageModel) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Key Points")
                .font(.caption.weight(.bold))
                .foregroundColor(.appTextSecondary)

            ForEach(Array(page.features.enumerated()), id: \.offset) { _, feature in
                HStack(spacing: 12) {
                    Image(systemName: feature.icon)
                        .font(.subheadline.weight(.semibold))
                        .foregroundColor(page.accent.color)
                        .frame(width: 28, height: 28)
                        .background(page.accent.color.opacity(0.15))
                        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                    Text(feature.text)
                        .font(.subheadline)
                        .foregroundColor(.appTextPrimary)
                        .fixedSize(horizontal: false, vertical: true)
                    Spacer(minLength: 0)
                }
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background { AppCardBackground(accent: .primary, highlighted: false, cornerRadius: 16) }
        .appDepthShadow(accent: .primary)
    }

    private var footerControls: some View {
        VStack(spacing: 16) {
            pageIndicator

            AppButton(title: pageIndex < pages.count - 1 ? "Next" : "Get Started") {
                if pageIndex < pages.count - 1 {
                    HapticService.mediumTap()
                    withAnimation(.easeInOut(duration: 0.28)) {
                        pageIndex += 1
                    }
                } else {
                    HapticService.mediumTap()
                    progress.hasSeenOnboarding = true
                }
            }
        }
        .padding(.top, 4)
    }

    private var pageIndicator: some View {
        HStack(spacing: 8) {
            ForEach(pages) { page in
                let selected = pageIndex == page.id
                Capsule()
                    .fill(
                        selected
                            ? LinearGradient(colors: [.appPrimary, .appAccent], startPoint: .leading, endPoint: .trailing)
                            : LinearGradient(colors: [Color.appTextSecondary.opacity(0.35), Color.appTextSecondary.opacity(0.2)], startPoint: .leading, endPoint: .trailing)
                    )
                    .frame(width: selected ? 28 : 8, height: 8)
                    .appDepthShadow(accent: selected ? .accent : .primary, elevated: selected)
                    .animation(.spring(response: 0.38, dampingFraction: 0.78), value: pageIndex)
            }
        }
        .padding(.vertical, 4)
    }

    private func animateIllustration() {
        illustrationScale = 0.92
        illustrationOpacity = 0
        withAnimation(.spring(response: 0.42, dampingFraction: 0.78)) {
            illustrationScale = 1
            illustrationOpacity = 1
        }
    }
}

// MARK: - Illustrations

enum OnboardingIllustrationKind {
    case swipe, stars, launch
}

struct OnboardingLaunchIllustration: View {
    var body: some View {
        ZStack {
            ForEach(0..<18, id: \.self) { index in
                let seed = Double(index) * 2.3
                Circle()
                    .fill(Color.appTextPrimary.opacity(0.25 + Double(index % 3) * 0.1))
                    .frame(width: CGFloat(2 + index % 2), height: CGFloat(2 + index % 2))
                    .offset(
                        x: CGFloat(sin(seed) * 90),
                        y: CGFloat(cos(seed * 1.2) * 70)
                    )
            }
            SpaceshipView(size: 44, animated: true)
        }
    }
}

struct OnboardingIllustrationView: View {
    let kind: OnboardingIllustrationKind

    var body: some View {
        ZStack {
            Canvas { context, size in
                switch kind {
                case .swipe:
                    drawSwipeScene(context: context, size: size)
                case .stars:
                    drawStarsScene(context: context, size: size)
                case .launch:
                    drawLaunchScene(context: context, size: size)
                }
            }

            if kind == .stars {
                VStack {
                    Spacer()
                    StarRatingView(count: 3, animated: false)
                        .padding(.bottom, 8)
                }
            }
        }
    }

    private func drawSwipeScene(context: GraphicsContext, size: CGSize) {
        for offset in stride(from: 0.1, through: 0.55, by: 0.12) {
            let meteor = CGRect(x: size.width * offset, y: size.height * 0.08, width: 26, height: 26)
            context.fill(Path(ellipseIn: meteor), with: .color(.appTextSecondary.opacity(0.85)))
        }

        let shipRect = CGRect(x: size.width * 0.38, y: size.height * 0.52, width: 52, height: 58)
        context.fill(
            SpaceshipShape().path(in: shipRect),
            with: .linearGradient(
                Gradient(colors: [.appPrimary, .appAccent.opacity(0.85)]),
                startPoint: CGPoint(x: shipRect.minX, y: shipRect.minY),
                endPoint: CGPoint(x: shipRect.maxX, y: shipRect.maxY)
            )
        )

        var arrow = Path()
        arrow.move(to: CGPoint(x: size.width * 0.12, y: size.height * 0.42))
        arrow.addLine(to: CGPoint(x: size.width * 0.78, y: size.height * 0.42))
        context.stroke(arrow, with: .color(.appAccent), style: StrokeStyle(lineWidth: 3, lineCap: .round))

        let tip = CGRect(x: size.width * 0.76, y: size.height * 0.39, width: 10, height: 10)
        context.fill(Path(ellipseIn: tip), with: .color(.appAccent))
    }

    private func drawStarsScene(context: GraphicsContext, size: CGSize) {
        for index in 0..<5 {
            let x = size.width * (0.12 + CGFloat(index) * 0.18)
            let y = size.height * (0.12 + CGFloat(index % 2) * 0.1)
            context.fill(
                Path(ellipseIn: CGRect(x: x, y: y, width: 20, height: 20)),
                with: .color(.appTextSecondary.opacity(0.75))
            )
        }

        let shipRect = CGRect(x: size.width * 0.4, y: size.height * 0.38, width: 50, height: 54)
        context.fill(
            SpaceshipShape().path(in: shipRect),
            with: .linearGradient(
                Gradient(colors: [.appAccent, .appPrimary]),
                startPoint: .zero,
                endPoint: CGPoint(x: size.width, y: size.height)
            )
        )

        let ringRect = CGRect(x: size.width * 0.28, y: size.height * 0.28, width: size.width * 0.44, height: size.width * 0.44)
        context.stroke(Path(ellipseIn: ringRect), with: .color(.appPrimary.opacity(0.45)), lineWidth: 2)
    }

    private func drawLaunchScene(context: GraphicsContext, size: CGSize) {
        for index in 0..<24 {
            let seed = CGFloat(index) * 17
            let x = (seed.truncatingRemainder(dividingBy: size.width))
            let y = (seed * 1.3).truncatingRemainder(dividingBy: size.height)
            context.fill(
                Path(ellipseIn: CGRect(x: x, y: y, width: 2, height: 2)),
                with: .color(Color.appTextPrimary.opacity(0.45))
            )
        }
    }
}
