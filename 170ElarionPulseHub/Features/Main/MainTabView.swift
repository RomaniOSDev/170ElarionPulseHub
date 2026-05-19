import SwiftUI

enum MainTab: Int, CaseIterable {
    case home
    case achievements
    case settings

    var title: String {
        switch self {
        case .home: return "Home"
        case .achievements: return "Achievements"
        case .settings: return "Settings"
        }
    }

    var icon: String {
        switch self {
        case .home: return "house.fill"
        case .achievements: return "rosette"
        case .settings: return "gearshape.fill"
        }
    }
}

struct MainTabView: View {
    @State private var selectedTab: MainTab = .home

    var body: some View {
        ZStack(alignment: .bottom) {
            Group {
                switch selectedTab {
                case .home:
                    HomeView(selectedTab: $selectedTab)
                case .achievements:
                    AchievementsView()
                case .settings:
                    SettingsView()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding(.bottom, 80)
            .background(Color.clear)

            CustomTabBar(selectedTab: $selectedTab)
        }
        .preferredColorScheme(.dark)
    }
}

struct CustomTabBar: View {
    @Binding var selectedTab: MainTab

    var body: some View {
        HStack(spacing: 4) {
            ForEach(MainTab.allCases, id: \.rawValue) { tab in
                tabButton(tab)
            }
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 8)
        .background {
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(AppGradients.tabBarSurface)
                .overlay(alignment: .top) {
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .fill(AppGradients.cardTopSheen)
                        .frame(height: 20)
                        .allowsHitTesting(false)
                }
                .overlay {
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .stroke(AppGradients.cardBorder, lineWidth: 1.2)
                }
        }
        .appDepthShadow(accent: .accent, elevated: true)
        .padding(.horizontal, 20)
        .padding(.bottom, 10)
    }

    private func tabButton(_ tab: MainTab) -> some View {
        let isSelected = selectedTab == tab
        return Button {
            HapticService.lightTap()
            withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                selectedTab = tab
            }
        } label: {
            VStack(spacing: 5) {
                ZStack {
                    if isSelected {
                        Capsule()
                            .fill(
                                LinearGradient(
                                    colors: [.appPrimary.opacity(0.45), .appAccent.opacity(0.25)],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                            .frame(width: 52, height: 32)
                    }
                    Image(systemName: tab.icon)
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(isSelected ? .appTextPrimary : .appTextSecondary)
                        .symbolRenderingMode(.hierarchical)
                }
                .frame(height: 32)

                Text(tab.title)
                    .font(.caption2.weight(isSelected ? .bold : .medium))
                    .foregroundColor(isSelected ? .appPrimary : .appTextSecondary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
            }
            .frame(maxWidth: .infinity)
            .frame(minHeight: 48)
        }
        .buttonStyle(TabPressStyle())
    }
}

private struct TabPressStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.94 : 1)
            .animation(.spring(response: 0.35, dampingFraction: 0.75), value: configuration.isPressed)
    }
}
