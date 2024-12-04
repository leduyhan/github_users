//
//  UserDetail.swift
//  Domain
//
//  Created by Hận Lê on 12/3/24.
//

import Foundation

public struct UserDetail: Hashable {
    public let login: String
    public let avatarUrl: String
    public let htmlUrl: String
    public let location: String?
    public let followers: Int
    public let following: Int
    
    public init(login: String, avatarUrl: String, htmlUrl: String, location: String?, followers: Int, following: Int) {
        self.login = login
        self.avatarUrl = avatarUrl
        self.htmlUrl = htmlUrl
        self.location = location
        self.followers = followers
        self.following = following
    }
}
