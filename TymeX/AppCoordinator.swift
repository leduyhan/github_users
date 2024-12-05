//
//  AppCoordinator.swift
//  TymeX
//
//  Created by Hận Lê on 12/4/24.
//

import Coordinator

final class AppCoordinator: Coordinator {
    var childCoordinators: [Coordinator] = []
    var finish: ((DeepLink?) -> Void)?

    lazy var tabBarController: UITabBarController = .init()
    private let window: UIWindow
    private let configuration: Configuration

    init(window: UIWindow, configuration: Configuration) {
        self.window = window
        self.configuration = configuration
    }

    func start() {
        switch configuration.style {
        case .navigation:
            setupNavigationStyle()
        case .tabBar:
            setupTabBarStyle()
        }

        window.makeKeyAndVisible()
        childCoordinators.first?.start()
    }

    private func setupNavigationStyle() {
        guard let navigationCoordinator = childCoordinators.first as? NavigationCoordinator else {
            fatalError("No NavigationCoordinator found for initial screen")
        }

        let sharedNavigationController = navigationCoordinator.navigationController
        window.rootViewController = sharedNavigationController

        for coordinator in childCoordinators {
            (coordinator as? NavigationCoordinator)?.navigationController = sharedNavigationController
            setupFinishHandler(for: coordinator)
        }
    }

    private func setupTabBarStyle() {
        for coordinator in childCoordinators {
            if let tabCoordinator = coordinator as? TabBarCoordinator {
                tabCoordinator.tabBarController = tabBarController
                tabBarController.addChild(tabCoordinator.tabBarController)
            }
            setupFinishHandler(for: coordinator)
        }
        window.rootViewController = tabBarController
    }

    private func setupFinishHandler(for coordinator: Coordinator) {
        coordinator.finish = { [weak self] deepLink in
            if let deepLink = deepLink {
                _ = self?.start(link: deepLink)
            }
        }
    }

    func start(link: DeepLink) -> Bool {
        return childCoordinators.map { $0.start(link: link) }.contains(true)
    }
}

extension AppCoordinator {
    struct Configuration {
        enum PresentationStyle {
            case tabBar, navigation
        }

        var style: PresentationStyle

        init(style: PresentationStyle) {
            self.style = style
        }
    }
}

extension AppCoordinator.Configuration {
    static var userConfiguration: Self {
        .init(style: .navigation)
    }
}
