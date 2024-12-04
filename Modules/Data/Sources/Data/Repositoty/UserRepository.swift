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

public final class DefaultUserRepository: UserRepository {
    private let networkClient: NetworkClient<UserAPI>
    private let mapper: ResponseMapper
    private let cache: UserCache

    public init(
        networkClient: NetworkClient<UserAPI> = NetworkClient(),
        mapper: ResponseMapper = DefaultResponseMapper(),
        store: UserStore = DIContainer.shared.resolve(type: UserStore.self) ?? InMemoryUserStore())
    {
        self.networkClient = networkClient
        self.mapper = mapper
        self.cache = LocalUserLoader(store: store, currentDate: Date.init)
    }

    public func fetchUsers(since: Int, perPage: Int, forceRefresh: Bool = false) -> Observable<[User]> {
        return Observable.create { [weak self] observer in
            guard let self = self else {
                observer.onCompleted()
                return Disposables.create()
            }
            
            // First load from cache if it's first page
            if since == 0, !forceRefresh {
                if let cachedUsers = try? self.cache.load(),
                   !cachedUsers.isEmpty {
                    observer.onNext(cachedUsers)
                }
            }

            let networkDisposable = self.networkClient
                .request(UserAPI.users(since: since, perPage: perPage))
                .asObservable()
                .map { [weak self] (dtos: [UserDTO]) -> [User] in
                    guard let self = self else { return [] }
                    let users = dtos.map(self.mapper.map)
                    
                    if since == 0 {
                        try? self.cache.save(users)
                    }
                    
                    return users
                }
                .share(replay: 1, scope: .whileConnected)
                .subscribe(
                    with: self,
                    onNext: { _, users in
                        observer.onNext(users)
                        observer.onCompleted()
                    },
                    onError: { _, error in
                        observer.onError(error)
                    }
                )
            return networkDisposable
        }.distinctUntilChanged()
    }
    
    public func fetchUserDetail(username: String) -> Single<UserDetail> {
        return networkClient
            .request(UserAPI.userDetail(username: username))
            .map(self.mapper.map)
    }
}
