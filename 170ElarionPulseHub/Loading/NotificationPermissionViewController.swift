//
//  NotificationPermissionViewController.swift
//  1TrulbargrovarStrinel
//
//  Hosts the custom notification permission screen. On Accept requests system permission then shows WebView.
//  On Decline records date and shows WebView (custom screen will not show again for 3 days).
//

import UIKit
import SwiftUI
import UserNotifications

final class NotificationPermissionViewController: UIViewController {

    private let url: URL
    private weak var window: UIWindow?
    private var didFinishTransition = false

    init(url: URL, window: UIWindow?) {
        self.url = url
        self.window = window
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        let swiftUIView = NotificationPermissionView(
            onAccept: { [weak self] in self?.handleAccept() },
            onDecline: { [weak self] in self?.handleDecline() }
        )
        let hosting = UIHostingController(rootView: swiftUIView)
        addChild(hosting)
        view.addSubview(hosting.view)
        hosting.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            hosting.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            hosting.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            hosting.view.topAnchor.constraint(equalTo: view.topAnchor),
            hosting.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        hosting.didMove(toParent: self)
    }

    private func handleAccept() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            switch settings.authorizationStatus {
            case .notDetermined:
                UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { [weak self] granted, _ in
                    DispatchQueue.main.async {
                        if granted {
                            NotificationPermissionManager.shared.recordCustomAccept()
                            NotificationPermissionManager.shared.markShouldSendTokenOnce()
                            UIApplication.shared.registerForRemoteNotifications()
                        }
                        self?.showWebView()
                    }
                }
            case .authorized, .provisional, .ephemeral:
                NotificationPermissionManager.shared.recordCustomAccept()
                DispatchQueue.main.async { [weak self] in
                    self?.showWebView()
                }
            case .denied:
                DispatchQueue.main.async { [weak self] in
                    self?.showWebView()
                }
            @unknown default:
                DispatchQueue.main.async { [weak self] in
                    self?.showWebView()
                }
            }
        }
    }

    private func handleDecline() {
        NotificationPermissionManager.shared.recordCustomDecline()
        showWebView()
    }

    private func showWebView() {
        guard !didFinishTransition else { return }
        let webVC = WebviewVC(url: url)
        if setRootViewController(webVC) {
            didFinishTransition = true
            return
        }

        DispatchQueue.main.async { [weak self] in
            guard let self, !self.didFinishTransition else { return }
            let delayedWebVC = WebviewVC(url: self.url)
            if self.setRootViewController(delayedWebVC) {
                self.didFinishTransition = true
                return
            }
            self.didFinishTransition = true
            delayedWebVC.modalPresentationStyle = .fullScreen
            self.present(delayedWebVC, animated: false)
        }
    }

    private func setRootViewController(_ vc: UIViewController) -> Bool {
        guard let resolvedWindow else { return false }
        resolvedWindow.rootViewController = vc
        resolvedWindow.makeKeyAndVisible()
        return true
    }

    private var resolvedWindow: UIWindow? {
        if let window {
            return window
        }
        if let viewWindow = view.window {
            return viewWindow
        }
        let scene = UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .first { $0.activationState == .foregroundActive || $0.activationState == .foregroundInactive }
            ?? UIApplication.shared.connectedScenes.compactMap { $0 as? UIWindowScene }.first
        return scene?.windows.first(where: { $0.isKeyWindow }) ?? scene?.windows.first
    }
}
