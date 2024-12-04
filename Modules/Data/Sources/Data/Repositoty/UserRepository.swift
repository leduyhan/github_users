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

public final class DefaultUserRepository: UserRepository {
    private let networkClient: NetworkClient<UserAPI>
    private let mapper: ResponseMapper
    private let cache: LocalUserLoader

    public init(
        networkClient: NetworkClient<UserAPI> = NetworkClient(),
        mapper: ResponseMapper = DefaultResponseMapper(),
        cache: LocalUserLoader
    ) {
        self.networkClient = networkClient
        self.mapper = mapper
        self.cache = cache
    }

    public func fetchUsers(since: Int, perPage: Int, forceRefresh: Bool = false) -> Single<[User]> {
        return Single.create { [weak self] single in
            guard let self = self else { return Disposables.create() }
            
            // Use cache for initial non-forced load
            if since == 0, !forceRefresh,
               let cachedUsers = try? self.cache.load(),
               !cachedUsers.isEmpty {
                single(.success(cachedUsers))
                return Disposables.create()
            }

            let networkDisposable = self.networkClient
                .request(UserAPI.users(since: since, perPage: perPage))
                .map { (dtos: [UserDTO]) in
                    let users = dtos.map(self.mapper.map)
                    try? self.cache.save(users)
                    return users
                }
                .catch { error in
                    // Fallback to cache on network failure
                    if forceRefresh,
                        let cachedUsers = try? self.cache.load()
                    {
                        return .just(cachedUsers)
                    }
                    return .error(error)
                }
                .subscribe(onSuccess: { users in
                    single(.success(users))
                }, onFailure: { error in
                    single(.failure(error))
                })
            
            return networkDisposable
        }
    }
    
    public func fetchUserDetail(username: String) -> Single<UserDetail> {
        return networkClient
            .request(UserAPI.userDetail(username: username))
            .map(self.mapper.map)
    }
}

public struct UserRepositoryFactory {
    public static func makeRepository() -> UserRepository {
        let storeURL = FileManager.default
            .urls(for: .documentDirectory, in: .userDomainMask)
            .first!
            .appendingPathComponent("user-store.sqlite")
        
        guard let store = try? CoreDataUserStore(storeURL: storeURL) else {
            // Provide a fallback repository without cache
            return DefaultUserRepository(
                networkClient: NetworkClient(),
                mapper: DefaultResponseMapper(),
                cache: makeInMemoryCache() // In-memory cache as fallback
            )
        }
        
        let cache = LocalUserLoader(
            store: store,
            currentDate: Date.init
        )
        
        return DefaultUserRepository(
            networkClient: NetworkClient(),
            mapper: DefaultResponseMapper(),
            cache: cache
        )
    }
    
    private static func makeInMemoryCache() -> LocalUserLoader {
        return LocalUserLoader(
            store: InMemoryUserStore(),
            currentDate: Date.init
        )
    }
}
