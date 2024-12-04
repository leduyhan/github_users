//
//  ManagedUserCache.swift
//  LocalStorage
//
//  Created by Hận Lê on 12/3/24.
//

import CoreData

@objc(ManagedUserCache)
class ManagedUserCache: NSManagedObject {
    @NSManaged var timestamp: Date
    @NSManaged var users: NSOrderedSet
}

extension ManagedUserCache {
    static func find(in context: NSManagedObjectContext) throws -> ManagedUserCache? {
        let request = NSFetchRequest<ManagedUserCache>(entityName: entity().name!)
        request.returnsObjectsAsFaults = false
        return try context.fetch(request).first
    }
    
    static func deleteCache(in context: NSManagedObjectContext) throws {
        try find(in: context).map(context.delete).map(context.save)
    }
    
    static func newUniqueInstance(in context: NSManagedObjectContext) throws -> ManagedUserCache {
        try deleteCache(in: context)
        return ManagedUserCache(context: context)
    }
    
    var localUsers: [LocalUser] {
        return users.compactMap { ($0 as? ManagedUser)?.local }
    }
}
