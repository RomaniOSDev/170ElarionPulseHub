import Combine
import SwiftUI

@MainActor
final class GameEffectsState: ObservableObject {
    @Published var isPaused = false
    @Published var showHitFlash = false
    @Published var comboCount = 0
    @Published var showComboPulse = false
    @Published var nearMissShake: CGFloat = 0

    func registerHit() {
        comboCount += 1
        if comboCount >= 5 {
            showComboPulse = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) { [weak self] in
                self?.showComboPulse = false
            }
        }
        triggerHitFlash()
    }

    func registerMiss() {
        comboCount = 0
    }

    func triggerHitFlash() {
        showHitFlash = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.12) { [weak self] in
            self?.showHitFlash = false
        }
    }

    func triggerNearMiss() {
        withAnimation(.default.repeatCount(2, autoreverses: true)) {
            nearMissShake = 6
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) { [weak self] in
            self?.nearMissShake = 0
        }
    }

    func resetSession() {
        isPaused = false
        comboCount = 0
        showComboPulse = false
        showHitFlash = false
        nearMissShake = 0
    }
}
