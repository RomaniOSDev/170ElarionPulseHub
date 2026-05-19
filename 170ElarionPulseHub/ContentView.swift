import SwiftUI

struct ContentView: View {
    @StateObject private var progress = GameProgressStore.shared

    var body: some View {
        Group {
            if progress.hasSeenOnboarding {
                MainTabView()
            } else {
                OnboardingView()
            }
        }
        .appScreenBackground()
        .background(HostingBackgroundFixer())
        .environmentObject(progress)
        .preferredColorScheme(.dark)
        .onAppear {
            AppAppearance.configure()
            progress.refreshOnLaunch()
        }
    }
}

#Preview {
    ContentView()
}
