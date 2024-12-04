//
//  LocalUser.swift
//  LocalStorage
//
//  Created by Hận Lê on 12/3/24.
//

import Foundation

public typealias CachedUsers = (users: [LocalUser], timestamp: Date)

public struct LocalUser: Equatable {
    public let login: String
    public let avatarURL: String
    public let htmlURL: String
    
    public init(login: String, avatarURL: String, htmlURL: String) {
        self.login = login
        self.avatarURL = avatarURL
        self.htmlURL = htmlURL
    }
}
