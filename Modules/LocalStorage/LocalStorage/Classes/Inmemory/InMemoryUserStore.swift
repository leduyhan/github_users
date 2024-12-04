//
//  InMemoryUserStore.swift
//  LocalStorage
//
//  Created by Hận Lê on 12/3/24.
//

import Foundation

public class InMemoryUserStore {
   private var userCache: CachedUsers?
   
   public init() {}
}

extension InMemoryUserStore: UserStore {
   public func deleteCachedUsers() throws {
       userCache = nil
   }
   
   public func insert(_ users: [LocalUser], timestamp: Date) throws {
       userCache = CachedUsers(users: users, timestamp: timestamp)
   }
   
   public func retrieve() throws -> CachedUsers? {
       userCache
   }
}
