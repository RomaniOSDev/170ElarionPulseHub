//
//  LoadingViewController.swift
//  1TrulbargrovarStrinel
//
//  Показывает загрузку в стиле приложения (градиент + анимированный индикатор), запрашивает конфиг,
//  затем переходит на ContentView или WebviewVC.
//  Гарантированный дедлайн: не более 15 с на экране со спиннером.
//

import UIKit
import SwiftUI

/// Максимальное ожидание данных конверсии перед конфиг-запросом.
private let conversionDataWaitInterval: TimeInterval = 10
/// Окно свежести conversion-данных для fast-path при старте.
private let conversionDataFreshnessWindow: TimeInterval = 10
/// Гарантированное максимальное время показа спиннера с момента появления экрана.
private let hardLoadingDeadlineInterval: TimeInterval = 15

/// Задержка перед стартом обычного config-flow (когда нет pending push URL).
private let ordinaryStartDelayInterval: TimeInterval = 5

private enum LoadingUIState {
    case spinner
    case noInternet
}

final class LoadingViewController: UIViewController {

    private let loadingHosting = UIHostingController(rootView: AnyView(LoadingView()))
    private var didFinishTransition = false
    private var loadingUIState: LoadingUIState = .spinner
    private var hardDeadlineWorkItem: DispatchWorkItem?
    private var conversionWaitWorkItem: DispatchWorkItem?
    private var conversionObserver: NSObjectProtocol?
    private var didStartConfigRequest = false
    private var ordinaryStartWorkItem: DispatchWorkItem?
    private var isConfigFlowInProgress = false

    override func viewDidLoad() {
        super.viewDidLoad()
        addChild(loadingHosting)
        view.addSubview(loadingHosting.view)
        loadingHosting.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            loadingHosting.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            loadingHosting.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            loadingHosting.view.topAnchor.constraint(equalTo: view.topAnchor),
            loadingHosting.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        loadingHosting.didMove(toParent: self)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        scheduleHardDeadline()
        startConfigFlow()
    }

    // MARK: - Hard deadline (always leaves spinner)

    private func scheduleHardDeadline() {
        hardDeadlineWorkItem?.cancel()
        let workItem = DispatchWorkItem { [weak self] in
            self?.forceFinishLoading()
        }
        hardDeadlineWorkItem = workItem
        DispatchQueue.main.asyncAfter(deadline: .now() + hardLoadingDeadlineInterval, execute: workItem)
    }

    private func cancelHardDeadline() {
        hardDeadlineWorkItem?.cancel()
        hardDeadlineWorkItem = nil
    }

    /// Принудительно завершает загрузку, если спиннер всё ещё на экране (не трогает No Internet).
    private func forceFinishLoading() {
        guard !didFinishTransition else { return }
        guard loadingUIState == .spinner else { return }
        cancelPendingConfigWork()
        cancelHardDeadline()
        isConfigFlowInProgress = false
        transitionToContentViewOrSavedWebView()
    }

    // MARK: - Config flow

    private func startConfigFlow() {
        if didFinishTransition { return }
        if let pushURL = PushNotificationURLRouter.shared.consumePendingURL() {
            ordinaryStartWorkItem?.cancel()
            ordinaryStartWorkItem = nil
            isConfigFlowInProgress = true
            finishTransition {
                WebviewVC(url: pushURL)
            }
            return
        }

        guard !isConfigFlowInProgress, ordinaryStartWorkItem == nil else { return }
        isConfigFlowInProgress = true
        showLoadingState()

        let workItem = DispatchWorkItem { [weak self] in
            guard let self else { return }
            self.ordinaryStartWorkItem = nil
            guard !self.didFinishTransition, self.isConfigFlowInProgress else { return }
            self.startConfigFlowWithoutPush()
        }
        ordinaryStartWorkItem = workItem
        DispatchQueue.main.asyncAfter(deadline: .now() + ordinaryStartDelayInterval, execute: workItem)
    }

    private func startConfigFlowWithoutPush() {
        if didFinishTransition { return }
        isConfigFlowInProgress = true
        showLoadingState()

        NetworkAvailability.checkConnection { [weak self] isConnected in
            guard let self = self, !self.didFinishTransition else { return }
            if !isConnected {
                self.showNoInternetState()
                return
            }
            self.startConfigFlowWithInternet()
        }
    }

    private func startConfigFlowWithInternet() {
        if didFinishTransition { return }
        let config = ConfigManager.shared
        didStartConfigRequest = false

        if config.isSavedURLValid, let url = config.savedURL {
            transitionToWebView(url: url)
            return
        }

        waitForConversionDataThenRequestConfig()
    }

    private func showLoadingState() {
        loadingUIState = .spinner
        loadingHosting.rootView = AnyView(LoadingView())
    }

    private func showNoInternetState() {
        loadingUIState = .noInternet
        isConfigFlowInProgress = false
        cancelPendingConfigWork()
        loadingHosting.rootView = AnyView(
            NoInternetView(
                onRetry: { [weak self] in
                    guard let self else { return }
                    self.isConfigFlowInProgress = false
                    self.loadingUIState = .spinner
                    self.startConfigFlow()
                }
            )
        )
    }

    private func cancelPendingConfigWork() {
        ordinaryStartWorkItem?.cancel()
        ordinaryStartWorkItem = nil
        conversionWaitWorkItem?.cancel()
        conversionWaitWorkItem = nil
        if let observer = conversionObserver {
            NotificationCenter.default.removeObserver(observer)
            conversionObserver = nil
        }
    }

    private func performConfigRequest() {
        guard !didFinishTransition, !didStartConfigRequest else { return }
        didStartConfigRequest = true
        cancelPendingConfigWork()

        ConfigManager.shared.requestConfig { [weak self] result in
            guard let self = self, !self.didFinishTransition else { return }
            switch result {
            case .success(let response):
                if response.ok, let urlString = response.url, let url = URL(string: urlString) {
                    self.transitionToWebView(url: url)
                } else {
                    self.transitionToContentViewOrSavedWebView()
                }
            case .failure:
                self.transitionToContentViewOrSavedWebView()
            }
        }
    }

    private func waitForConversionDataThenRequestConfig() {
        if AppsFlyerManager.shared.hasFreshConversionData(within: conversionDataFreshnessWindow) {
            performConfigRequest()
            return
        }

        conversionObserver = NotificationCenter.default.addObserver(
            forName: .appsFlyerConversionDataReady,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.performConfigRequest()
        }

        conversionWaitWorkItem = DispatchWorkItem { [weak self] in
            guard let self else { return }
            guard !self.didFinishTransition, !self.didStartConfigRequest else { return }
            self.performConfigRequest()
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + conversionDataWaitInterval, execute: conversionWaitWorkItem!)

        if AppsFlyerManager.shared.hasFreshConversionData(within: conversionDataFreshnessWindow) {
            performConfigRequest()
        }
    }

    // MARK: - Transitions

    private func transitionToContentViewOrSavedWebView() {
        if let url = ConfigManager.shared.savedURL {
            transitionToWebView(url: url)
        } else {
            transitionToContentView()
        }
    }

    private func transitionToWebView(url: URL) {
        NotificationPermissionManager.shared.shouldShowCustomNotificationScreen { [weak self] shouldShow in
            guard let self = self, !self.didFinishTransition else { return }
            if shouldShow {
                let notificationVC = NotificationPermissionViewController(
                    url: url,
                    window: self.resolvedWindow
                )
                self.finishTransition { notificationVC }
            } else {
                self.finishTransition { WebviewVC(url: url) }
            }
        }
    }

    private func transitionToContentView() {
        finishTransition {
            UIHostingController(rootView: ContentView())
        }
    }

    private func finishTransition(makeViewController: () -> UIViewController) {
        guard !didFinishTransition else { return }
        didFinishTransition = true
        cancelHardDeadline()
        cancelPendingConfigWork()
        replaceRoot(with: makeViewController())
    }

    private var resolvedWindow: UIWindow? {
        if let window = view.window {
            return window
        }
        let scene = UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .first { $0.activationState == .foregroundActive || $0.activationState == .foregroundInactive }
            ?? UIApplication.shared.connectedScenes.compactMap { $0 as? UIWindowScene }.first
        return scene?.windows.first(where: { $0.isKeyWindow }) ?? scene?.windows.first
    }

    private func replaceRoot(with vc: UIViewController) {
        guard let window = resolvedWindow else { return }
        window.rootViewController = vc
    }
}
