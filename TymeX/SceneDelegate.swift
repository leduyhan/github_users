//
//  SceneDelegate.swift
//  TymeX
//
//  Created by Hận Lê on 12/2/24.
//

import UIKit
import Users

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?
    private var appCoordinator: AppCoordinator?
    private var userCoordinator: UserCoordinator?
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
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
