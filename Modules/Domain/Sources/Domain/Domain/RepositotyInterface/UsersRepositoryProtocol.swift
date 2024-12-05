//
//  UsersRepositoryProtocol.swift
//  Domain
//
//  Created by Hận Lê on 12/3/24.
//

import NetworkService
import RxSwift

public protocol UserRepository {
    func fetchUsers(since: Int, perPage: Int) -> Observable<[User]>
    func fetchUserDetail(username: String) -> Single<UserDetail>
}
