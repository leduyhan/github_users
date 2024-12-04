//
//  UserStore.swift
//  LocalStorage
//
//  Created by Hận Lê on 12/3/24.
//

import Foundation

public protocol UserStore {
    func deleteCachedUsers() throws
    func insert(_ users: [LocalUser], timestamp: Date) throws
    func retrieve() throws -> CachedUsers?
}
