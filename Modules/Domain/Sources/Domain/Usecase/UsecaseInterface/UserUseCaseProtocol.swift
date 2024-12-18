//
//  UseCaesProtocol.swift
//  Domain
//
//  Created by Hận Lê on 12/3/24.
//

import RxSwift

public protocol FetchUsersUseCase {
    func execute(since: Int, perPage: Int) -> Observable<[User]>
}

public protocol FetchUserDetailUseCase {
    func execute(username: String) -> Single<UserDetail>
}
