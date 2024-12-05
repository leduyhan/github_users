//
//  SceneDelegate.swift
//  TymeX
//
//  Created by Hận Lê on 12/2/24.
//

import UIKit
import Users
import AppShared
import LocalStorage
import DesignSystem

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?
    private var appCoordinator: AppCoordinator?
    private var userCoordinator: UserCoordinator?
    private lazy var cache: UserCache = {
        let store: UserStore = DIContainer.shared.resolve(type: UserStore.self) ?? InMemoryUserStore()
        let cache = LocalUserLoader(store: store, currentDate: Date.init)
        return cache
    }()
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        Design.initialize()
        guard let windowScene = (scene as? UIWindowScene) else { return }
        DIContainer.shared.setupCoreData()
        let window = UIWindow(windowScene: windowScene)
        self.window = window
        
        userCoordinator = UserCoordinator()
        appCoordinator = AppCoordinator(
            window: window,
            configuration: .userConfiguration
        )
        appCoordinator?.childCoordinators = [userCoordinator!]
        appCoordinator?.start()
    }
    
    func sceneWillResignActive(_: UIScene) {
        try? cache.validateCache()
    }
}
