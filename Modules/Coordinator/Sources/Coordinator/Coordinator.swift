//
//  Coordinator.swift
//  LocalStorage
//
//  Created by Hận Lê on 12/4/24.
//

import Foundation
import UIKit

// DeepLink represents a linking within the coordinator
public protocol DeepLink {}

public protocol Coordinator: AnyObject {
    var childCoordinators: [Coordinator] { get set }
    var finish: ((DeepLink?) -> Void)? { get set }
//    var registeredOutterLinks: [DeepLink: DeepLink] { get set }
    
    func start()
    func start(link: DeepLink) -> Bool
    
    // Optional links mapping outside of the scope of the coordinator
    func register(outsideLink: DeepLink, for: DeepLink)
}

public extension Coordinator {
    
    // Implement if the coordinator must call route outside of its module.
    // On the higher level register the coordinator's link to a link of
    // a different not internally linked coordinator
    func register(outsideLink: DeepLink, for: DeepLink) {}
}

// Representation of a coordinator who is using navigationController
public protocol NavigationCoordinator: Coordinator {
    var navigationController: UINavigationController { get set }
}

// Representation of a coordinator who is using tabBarController
public protocol TabBarCoordinator: Coordinator {
    var tabBarController: UITabBarController { get set }
    var tabViewController: TabBarViewController { get }
}

public protocol TabBarViewController: UIViewController {
    var tabBarImage: UIImage { get }
    var tabBarName: String { get }
}
