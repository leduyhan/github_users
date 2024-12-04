//
//  UserUsecase.swift
//  Domain
//
//  Created by Hận Lê on 12/3/24.
//

import RxSwift

public final class DefaultFetchUsersUseCase: FetchUsersUseCase {
    private let repository: UserRepository

    public init(repository: UserRepository) {
        self.repository = repository
    }

    public func execute(since: Int, perPage: Int, forceRefresh: Bool) -> Single<[User]> {
        return repository.fetchUsers(since: since, perPage: perPage, forceRefresh: forceRefresh)
    }
}

public final class DefaultFetchUserDetailUseCase: FetchUserDetailUseCase {
    private let repository: UserRepository

    public init(repository: UserRepository) {
        self.repository = repository
    }

    public func execute(username: String) -> Single<UserDetail> {
        return repository.fetchUserDetail(username: username)
    }
}
