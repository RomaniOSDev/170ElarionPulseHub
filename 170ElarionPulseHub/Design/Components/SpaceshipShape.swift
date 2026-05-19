import SwiftUI

// MARK: - Vector fallback (onboarding illustrations)

struct SpaceshipShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let w = rect.width
        let h = rect.height
        path.move(to: CGPoint(x: w * 0.5, y: 0))
        path.addLine(to: CGPoint(x: w, y: h * 0.75))
        path.addLine(to: CGPoint(x: w * 0.65, y: h))
        path.addLine(to: CGPoint(x: w * 0.5, y: h * 0.85))
        path.addLine(to: CGPoint(x: w * 0.35, y: h))
        path.addLine(to: CGPoint(x: 0, y: h * 0.75))
        path.closeSubpath()
        return path
    }
}

// MARK: - Sprite ship (Assets)

struct SpaceshipView: View {
    /// Base scale — multiplied internally so sprites read well in-game.
    var size: CGFloat = 44
    var skin: ShipSkin?
    var animated: Bool = true

    private var resolvedSkin: ShipSkin {
        skin ?? GameProgressStore.shared.selectedSkin
    }

    /// `size` is a logical scale; sprites render larger with transparent edges trimmed.
    private var shipWidth: CGFloat { size * 2.6 }
    private var shipHeight: CGFloat { size * 3.4 }

    var body: some View {
        Group {
            if animated {
                TimelineView(.animation(minimumInterval: 1.0 / 20.0)) { timeline in
                    shipContent(time: timeline.date.timeIntervalSinceReferenceDate)
                }
            } else {
                shipContent(time: 0)
            }
        }
        .frame(width: shipWidth, height: shipHeight)
    }

    @ViewBuilder
    private func shipContent(time: TimeInterval) -> some View {
        let bob = CGFloat(sin(time * 3.2) * 1.5)
        let pulse = 0.55 + 0.25 * sin(time * 3.5)
        let scale = 1.0 + (animated ? 0.035 * sin(time * 4) : 0)

        ZStack {
            skinBackdrop(time: time)

            Image(resolvedSkin.imageName)
                .resizable()
                .interpolation(.high)
                .antialiased(true)
                .aspectRatio(contentMode: .fit)
                .frame(width: shipWidth, height: shipHeight)
                .scaleEffect(scale)
                .offset(y: bob)
                .shadow(color: resolvedSkin.primary.opacity(pulse * 0.7), radius: size * 0.18, y: 3)
                .overlay {
                    skinImageOverlay(time: time)
                }
        }
        .compositingGroup()
    }

    @ViewBuilder
    private func skinBackdrop(time: TimeInterval) -> some View {
        switch resolvedSkin.animation {
        case .neonGlow:
            Circle()
                .stroke(resolvedSkin.accent.opacity(0.35 + 0.2 * sin(time * 4.2)), lineWidth: 2)
                .frame(width: size * 1.4, height: size * 1.4)
                .blur(radius: 2)
        case .pulseRing:
            ForEach(0..<2, id: \.self) { index in
                let phase = (time * 1.5 + Double(index) * 0.85).truncatingRemainder(dividingBy: 2.0) / 2.0
                Circle()
                    .stroke(resolvedSkin.primary.opacity(0.35 * (1 - phase)), lineWidth: 1.5)
                    .frame(
                        width: size * (0.9 + CGFloat(phase) * 1.1),
                        height: size * (0.9 + CGFloat(phase) * 1.1)
                    )
                    .offset(y: size * 0.35)
            }
        case .auroraShift:
            Ellipse()
                .fill(resolvedSkin.accent.opacity(0.15 + 0.1 * sin(time * 2.5)))
                .frame(width: size * 1.8, height: size * 0.9)
                .offset(y: size * 0.55)
                .blur(radius: 10)
        default:
            EmptyView()
        }
    }

    @ViewBuilder
    private func skinImageOverlay(time: TimeInterval) -> some View {
        switch resolvedSkin.animation {
        case .royalShimmer:
            LinearGradient(
                colors: [
                    Color.clear,
                    Color.appTextPrimary.opacity(0.35),
                    Color.clear
                ],
                startPoint: UnitPoint(x: shimmerOffset(time: time), y: 0),
                endPoint: UnitPoint(x: shimmerOffset(time: time) + 0.3, y: 1)
            )
            .blendMode(.plusLighter)
            .allowsHitTesting(false)
        case .classicPulse:
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .stroke(resolvedSkin.accent.opacity(0.25 + 0.15 * sin(time * 2.8)), lineWidth: 1)
                .padding(size * 0.2)
                .allowsHitTesting(false)
        default:
            EmptyView()
        }
    }

    private func shimmerOffset(time: TimeInterval) -> CGFloat {
        let cycle = (time * 0.75).truncatingRemainder(dividingBy: 1.4) / 1.4
        return CGFloat(-0.15 + cycle * 1.3)
    }
}

// MARK: - Meteor

struct MeteorShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let inset = rect.width * 0.1
        path.addEllipse(in: rect.insetBy(dx: inset, dy: inset * 1.2))
        path.move(to: CGPoint(x: rect.midX, y: rect.minY + inset))
        path.addLine(to: CGPoint(x: rect.midX - inset, y: rect.maxY - inset))
        path.move(to: CGPoint(x: rect.midX + inset * 0.5, y: rect.minY + inset * 2))
        path.addLine(to: CGPoint(x: rect.maxX - inset, y: rect.midY))
        return path
    }
}

struct MeteorView: View {
    var size: CGFloat = 36

    var body: some View {
        MeteorShape()
            .fill(
                RadialGradient(
                    colors: [.appTextSecondary, .appSurface],
                    center: .center,
                    startRadius: 2,
                    endRadius: size * 0.5
                )
            )
            .frame(width: size, height: size)
            .shadow(color: .appAccent.opacity(0.3), radius: 4)
    }
}
