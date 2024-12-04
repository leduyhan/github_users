//
//  Extension.swift
//  LocalStorage
//
//  Created by Hận Lê on 12/3/24.
//

import Domain
import CoreData

extension Array where Element == User {
    func toLocal() -> [LocalUser] {
        return map { LocalUser(login: $0.login, avatarURL: $0.avatarUrl, htmlURL: $0.htmlUrl) }
    }
}

extension Array where Element == LocalUser {
    func toModels() -> [User] {
        return map { User(login: $0.login, avatarUrl: $0.avatarURL, htmlUrl: $0.htmlURL) }
    }
}

extension NSPersistentContainer {
    static func load(name: String, model: NSManagedObjectModel, url: URL) throws -> NSPersistentContainer {
        let description = NSPersistentStoreDescription(url: url)
        let container = NSPersistentContainer(name: name, managedObjectModel: model)
        container.persistentStoreDescriptions = [description]
        
        var loadError: Swift.Error?
        container.loadPersistentStores { loadError = $1 }
        try loadError.map { throw $0 }
        
        return container
    }
}

extension NSManagedObjectModel {
    static func with(name: String, in bundle: Bundle) -> NSManagedObjectModel? {
        return bundle
            .url(forResource: name, withExtension: "momd")
            .flatMap { NSManagedObjectModel(contentsOf: $0) }
    }
}
