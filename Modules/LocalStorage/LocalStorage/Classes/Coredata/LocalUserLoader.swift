//
//  LocalUserLoader.swift
//  LocalStorage
//
//  Created by Hận Lê on 12/3/24.
//

import Domain

public final class LocalUserLoader {
    private let store: UserStore
    private let currentDate: () -> Date
    
    public init(store: UserStore, currentDate: @escaping () -> Date) {
        self.store = store
        self.currentDate = currentDate
    }
}

extension LocalUserLoader {
    public func save(_ users: [User]) throws {
        try store.deleteCachedUsers()
        try store.insert(users.toLocal(), timestamp: currentDate())
    }
    
    public func load() throws -> [User] {
        if let cache = try store.retrieve(), UserCachePolicy.validate(cache.timestamp, against: currentDate()) {
            return cache.users.toModels()
        }
        return []
    }
    
    public func validateCache() throws {
        do {
            if let cache = try store.retrieve(), !UserCachePolicy.validate(cache.timestamp, against: currentDate()) {
                throw CacheError.expired
            }
        } catch {
            try store.deleteCachedUsers()
        }
    }
    
    enum CacheError: Error {
        case expired
    }
}
