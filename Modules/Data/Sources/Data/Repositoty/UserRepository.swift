//
//  UserRepository.swift
//  Domain
//
//  Created by Hận Lê on 12/3/24.
//

import AppShared
import Domain
import LocalStorage
import NetworkService
import RxSwift

public protocol UserRepositoryDependencies {
    var networkClient: NetworkClient<UserAPI> { get }
    var mapper: ResponseMapper { get }
    var cache: UserCache { get }
}

public struct DefaultUserRepositoryDependencies: UserRepositoryDependencies {
    public let networkClient: NetworkClient<UserAPI>
    public let mapper: ResponseMapper
    public let cache: UserCache

    public init(
        networkClient: NetworkClient<UserAPI> = NetworkClient(),
        mapper: ResponseMapper = DefaultResponseMapper(),
        store: UserStore = DIContainer.shared.resolve(type: UserStore.self) ?? InMemoryUserStore()
    ) {
        self.networkClient = networkClient
        self.mapper = mapper
        self.cache = LocalUserLoader(store: store, currentDate: Date.init)
    }
}

public final class DefaultUserRepository: UserRepository {
    private let dependencies: UserRepositoryDependencies

    public init(dependencies: UserRepositoryDependencies = DefaultUserRepositoryDependencies()) {
        self.dependencies = dependencies
    }

    public func fetchUsers(since: Int, perPage: Int) -> Observable<[User]> {
        if since == 0,
           let cachedUsers = try? dependencies.cache.load(),
           !cachedUsers.isEmpty {
            return .concat([
                .just(cachedUsers),
                fetchRemoteUsers(since: since, perPage: perPage)
                    .filter { remoteUsers in
                        // Only emit remote users if they're different from cached ones
                        !remoteUsers.elementsEqual(cachedUsers) { $0.login == $1.login }
                    },
            ])
        }
        return fetchRemoteUsers(since: since, perPage: perPage)
    }

    public func fetchUserDetail(username: String) -> Single<UserDetail> {
        dependencies
            .networkClient
            .request(.userDetail(username: username))
            .map(dependencies.mapper.map)
    }

    private func fetchRemoteUsers(since: Int, perPage: Int) -> Observable<[User]> {
        dependencies.networkClient
            .request(.users(since: since, perPage: perPage))
            .map { [weak self] (dtos: [UserDTO]) -> [User] in
                guard let self = self else { return [] }
                let users = dtos.map(self.dependencies.mapper.map)
                return users
            }
            .do(onSuccess: { [weak self] users in
                if since == 0 {
                    try? self?.dependencies.cache.save(users)
                }
            })
            .asObservable()
            .share(replay: 1, scope: .whileConnected)
    }
}
