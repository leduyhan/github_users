//
//  User.swift
//  Domain
//
//  Created by Hận Lê on 12/3/24.
//

import Foundation

public struct User: Equatable {
    public let login: String
    public let avatarUrl: String
    public let htmlUrl: String
    
    public init(login: String, avatarUrl: String, htmlUrl: String) {
        self.login = login
        self.avatarUrl = avatarUrl
        self.htmlUrl = htmlUrl
    }
}
