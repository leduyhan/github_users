//
//  UserRepository.swift
//  Domain
//
//  Created by Hận Lê on 12/3/24.
//

import NetworkService
import RxSwift
import Domain
import LocalStorage
import AppShared

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
    
    public func fetchUsers(since: Int, perPage: Int, forceRefresh: Bool = false) -> Observable<[User]> {
        Observable.create { [weak self] observer in
            guard let self = self else {
                observer.onCompleted()
                return Disposables.create()
            }
            
            self.loadCachedUsers(since: since, forceRefresh: forceRefresh, observer: observer)
            
            return self.fetchRemoteUsers(since: since, perPage: perPage, forceRefresh: forceRefresh)
                .subscribe(observer)
        }
    }
    
    public func fetchUserDetail(username: String) -> Single<UserDetail> {
        dependencies.networkClient
            .request(UserAPI.userDetail(username: username))
            .map(dependencies.mapper.map)
    }
    
    private func loadCachedUsers(since: Int, forceRefresh: Bool, observer: AnyObserver<[User]>) {
        guard since == 0, !forceRefresh else { return }
        
        if let cachedUsers = try? dependencies.cache.load(),
           !cachedUsers.isEmpty {
            observer.onNext(cachedUsers)
        }
    }
    
    private func fetchRemoteUsers(since: Int, perPage: Int, forceRefresh: Bool) -> Observable<[User]> {
        dependencies.networkClient
            .request(UserAPI.users(since: since, perPage: perPage))
            .asObservable()
            .map { [weak self] (dtos: [UserDTO]) -> [User] in
                guard let self = self else { return [] }
                let users = dtos.map(self.dependencies.mapper.map)
                if since == 0 {
                    try? self.dependencies.cache.save(users)
                }
                return users
            }
            .catch { [weak self] error -> Observable<[User]> in
                guard let self = self,
                      forceRefresh,
                      let cachedUsers = try? self.dependencies.cache.load(),
                      !cachedUsers.isEmpty else {
                    return .error(error)
                }
                return .just(cachedUsers)
            }
            .share(replay: 1, scope: .whileConnected)
    }
}
