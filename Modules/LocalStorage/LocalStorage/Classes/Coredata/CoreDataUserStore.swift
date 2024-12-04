//
//  CoreDataUserStore.swift
//  LocalStorage
//
//  Created by Hận Lê on 12/3/24.
//

import CoreData

public final class CoreDataUserStore {
    private static let modelName = "UserStore"
    private static let model = NSManagedObjectModel.with(name: modelName, in: Bundle(for: CoreDataUserStore.self))
    
    private let container: NSPersistentContainer
    let context: NSManagedObjectContext
    
    enum StoreError: Error {
        case modelNotFound
        case failedToLoadPersistentContainer(Error)
    }
    
    public init(storeURL: URL) throws {
        guard let model = CoreDataUserStore.model else {
            throw StoreError.modelNotFound
        }
        
        do {
            container = try NSPersistentContainer.load(name: CoreDataUserStore.modelName, model: model, url: storeURL)
            context = container.newBackgroundContext()
        } catch {
            throw StoreError.failedToLoadPersistentContainer(error)
        }
    }
    
    private func cleanUpReferencesToPersistentStores() {
        context.performAndWait {
            let coordinator = self.container.persistentStoreCoordinator
            try? coordinator.persistentStores.forEach(coordinator.remove)
        }
    }
    
    deinit {
        cleanUpReferencesToPersistentStores()
    }
}

extension CoreDataUserStore: UserStore {
    public func retrieve() throws -> CachedUsers? {
        try ManagedUserCache.find(in: context).map {
            CachedUsers(users: $0.localUsers, timestamp: $0.timestamp)
        }
    }
    
    public func insert(_ users: [LocalUser], timestamp: Date) throws {
        let managedCache = try ManagedUserCache.newUniqueInstance(in: context)
        managedCache.timestamp = timestamp
        managedCache.users = ManagedUser.users(from: users, in: context)
        try context.save()
    }
    
    public func deleteCachedUsers() throws {
        try ManagedUserCache.deleteCache(in: context)
    }
}
