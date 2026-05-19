import SwiftUI
import UIKit

enum AppAppearance {
    static func configure() {
        UIScrollView.appearance().backgroundColor = .clear
        UITableView.appearance().backgroundColor = .clear
        UICollectionView.appearance().backgroundColor = .clear

        let nav = UINavigationBarAppearance()
        nav.configureWithTransparentBackground()
        nav.backgroundColor = .clear
        nav.shadowColor = .clear
        UINavigationBar.appearance().standardAppearance = nav
        UINavigationBar.appearance().scrollEdgeAppearance = nav
        UINavigationBar.appearance().compactAppearance = nav

        applyWindowBackground()
    }

    static func applyWindowBackground() {
        let color = UIColor(named: "AppBackground") ?? UIColor(red: 0, green: 55 / 255, blue: 114 / 255, alpha: 1)
        for scene in UIApplication.shared.connectedScenes {
            guard let windowScene = scene as? UIWindowScene else { continue }
            for window in windowScene.windows {
                window.backgroundColor = color
            }
        }
    }

    static func applyHostingBackground(from view: UIView) {
        let color = UIColor(named: "AppBackground") ?? UIColor(red: 0, green: 55 / 255, blue: 114 / 255, alpha: 1)
        var current: UIView? = view
        while let node = current {
            let name = String(describing: type(of: node))
            if name.contains("Hosting") {
                node.backgroundColor = color
            }
            current = node.superview
        }
        view.window?.backgroundColor = color
        if let root = view.window?.rootViewController {
            root.view.backgroundColor = color
        }
    }
}

extension View {
    /// Full-screen app gradient behind this view.
    func appScreenBackground() -> some View {
        frame(maxWidth: .infinity, maxHeight: .infinity)
            .background {
                AppBackgroundView()
            }
    }

    /// Lets `AppBackgroundView` show through NavigationStack / ScrollView layers.
    func transparentAppScreen() -> some View {
        scrollContentBackground(.hidden)
            .toolbarBackground(.hidden, for: .navigationBar)
            .background(Color.clear)
    }
}
