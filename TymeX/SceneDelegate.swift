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

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?
    private var appCoordinator: AppCoordinator?
    private var userCoordinator: UserCoordinator?
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
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
}

extension DIContainer {
    public func setupCoreData() {
        let storeURL = FileManager.default
            .urls(for: .documentDirectory, in: .userDomainMask)
            .first!
            .appendingPathComponent("user-store.sqlite")
        
        if let store = try? CoreDataUserStore(storeURL: storeURL) {
            register(type: UserStore.self, dependency: store)
        } else {
            register(type: UserStore.self, dependency: InMemoryUserStore())
        }
    }
}
