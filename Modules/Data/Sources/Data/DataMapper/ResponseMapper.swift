//
//  ResponseMapper.swift
//  Domain
//
//  Created by Hận Lê on 12/3/24.
//

import Domain

public protocol ResponseMapper {
    func map(_ dto: UserDTO) -> User
    func map(_ dto: UserDetailDTO) -> UserDetail
}

public final class DefaultResponseMapper: ResponseMapper {
    public init() {}
    
    public func map(_ dto: UserDTO) -> User {
        return User(
            login: dto.login,
            avatarUrl: dto.avatar_url,
            htmlUrl: dto.html_url
        )
    }

    public func map(_ dto: UserDetailDTO) -> UserDetail {
        return UserDetail(
            login: dto.login,
            avatarUrl: dto.avatar_url,
            htmlUrl: dto.html_url,
            location: dto.location,
            followers: dto.followers,
            following: dto.following
        )
    }
}
