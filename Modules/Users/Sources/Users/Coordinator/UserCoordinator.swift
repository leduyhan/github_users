//
//  UserCoordinator.swift
//  Pods
//
//  Created by Hận Lê on 12/3/24.
//

import Coordinator

public final class UserCoordinator: NavigationCoordinator {
    public enum UserLink: DeepLink {
        case userList
        case userDetail(username: String)
    }

    public lazy var navigationController: UINavigationController = .init()
    public var childCoordinators: [Coordinator] = []
    public var finish: ((DeepLink?) -> Void)?

    public init() {}

    public func start() {
        navigationController.setViewControllers([makeUserListViewController()], animated: false)
    }

    @discardableResult
    public func start(link: DeepLink) -> Bool {
        guard let userLink = link as? UserLink else {
            return childCoordinators.map { $0.start(link: link) }.contains(true)
        }

        switch userLink {
        case .userList:
            navigationController.popToRootViewController(animated: true)
            return true
        case let .userDetail(username):
            navigationController.pushViewController(
                makeUserDetailViewController(username: username),
                animated: true
            )
            return true
        }
    }

    private func makeUserListViewController() -> UIViewController {
        let viewModel = UserListViewModel()
        let viewcontroler = UserListViewController(
            viewModel: viewModel,
            onShowDetail: { [weak self] username in
                self?.start(link: UserLink.userDetail(username: username))
            }
        )
        return viewcontroler
    }

    private func makeUserDetailViewController(username: String) -> UIViewController {
        let viewModel = UserDetailViewModel(username: username)
        return UserDetailViewController(viewModel: viewModel)
    }
}
