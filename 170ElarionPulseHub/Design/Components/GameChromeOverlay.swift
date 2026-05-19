import SwiftUI

struct GameChromeOverlay: View {
    @ObservedObject var effects: GameEffectsState
    let activityId: String
    let onTutorialDismiss: () -> Void
    let onPause: () -> Void
    let onResume: () -> Void

    @EnvironmentObject private var progress: GameProgressStore

    var body: some View {
        ZStack {
            if effects.showHitFlash {
                Color.appAccent.opacity(0.35)
                    .ignoresSafeArea()
                    .allowsHitTesting(false)
            }

            if effects.showComboPulse {
                VStack {
                    Text("Combo x\(effects.comboCount)")
                        .font(.title2.bold())
                        .foregroundColor(.appTextPrimary)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                        .background(Color.appPrimary.opacity(0.85))
                        .clipShape(Capsule())
                        .shadow(color: .appAccent.opacity(0.8), radius: 10)
                    Spacer()
                }
                .padding(.top, 80)
                .allowsHitTesting(false)
                .transition(.scale.combined(with: .opacity))
            }

            if !progress.hasSeenTutorial(for: activityId) {
                GameTutorialOverlay(activityId: activityId, onDismiss: onTutorialDismiss)
            }

            if effects.isPaused {
                PauseOverlay(onResume: onResume)
            }

            VStack {
                HStack {
                    Spacer()
                    Button {
                        HapticService.lightTap()
                        onPause()
                    } label: {
                        Image(systemName: "pause.circle.fill")
                            .font(.system(size: 36))
                            .foregroundColor(.appTextPrimary)
                            .shadow(color: .appPrimary.opacity(0.5), radius: 4)
                    }
                    .buttonStyle(.plain)
                    .frame(minWidth: 44, minHeight: 44)
                    .padding(.trailing, 12)
                    .padding(.top, 8)
                }
                Spacer()
            }
        }
    }
}

struct PauseOverlay: View {
    let onResume: () -> Void

    var body: some View {
        ZStack {
            Color.black.opacity(0.55)
                .ignoresSafeArea()

            VStack(spacing: 20) {
                Text("Paused")
                    .font(.largeTitle.bold())
                    .foregroundColor(.appTextPrimary)
                AppButton(title: "Resume", style: .primary) {
                    onResume()
                }
                .padding(.horizontal, 40)
            }
            .appElevatedPanel(accent: .accent)
            .padding(.horizontal, 28)
        }
    }
}

struct GameTutorialOverlay: View {
    let activityId: String
    let onDismiss: () -> Void

    @State private var step = 0

    private var steps: [String] {
        switch activityId {
        case "meteor_tap":
            return [
                "Drag to move your ship left and right.",
                "Tap the screen to shoot lasers at meteors.",
                "Tap Finish anytime. Earn 50+ points for stars. Avoid meteor hits!"
            ]
        case "asteroid_evasion":
            return [
                "Drag anywhere to steer your ship.",
                "Dodge falling meteors — collision ends the run.",
                "Tap Finish anytime. Survive long enough to earn stars."
            ]
        case "meteor_glide":
            return [
                "Hold the left or right side to steer.",
                "Release to stop moving.",
                "Tap Finish anytime. Survive without collisions for stars."
            ]
        default:
            return ["Good luck, pilot!"]
        }
    }

    var body: some View {
        ZStack {
            Color.black.opacity(0.72)
                .ignoresSafeArea()

            VStack(spacing: 20) {
                Text("Quick Briefing")
                    .font(.title2.bold())
                    .foregroundColor(.appTextPrimary)

                Text(steps[step])
                    .font(.body)
                    .foregroundColor(.appTextSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24)
                    .frame(minHeight: 80)

                HStack(spacing: 8) {
                    ForEach(0..<steps.count, id: \.self) { index in
                        Circle()
                            .fill(index == step ? Color.appPrimary : Color.appTextSecondary.opacity(0.4))
                            .frame(width: 8, height: 8)
                    }
                }

                AppButton(title: step < steps.count - 1 ? "Next" : "Got It", style: .primary) {
                    HapticService.lightTap()
                    if step < steps.count - 1 {
                        step += 1
                    } else {
                        onDismiss()
                    }
                }
                .padding(.horizontal, 32)
            }
            .appElevatedPanel(accent: .primary, cornerRadius: 20)
            .padding(.horizontal, 24)
        }
    }
}
