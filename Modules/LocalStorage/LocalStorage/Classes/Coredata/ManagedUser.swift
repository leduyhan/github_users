//
//  ManagedUser.swift
//  LocalStorage
//
//  Created by Hận Lê on 12/3/24.
//

import CoreData

@objc(ManagedUser)
class ManagedUser: NSManagedObject {
    @NSManaged var login: String
    @NSManaged var avatarURL: String
    @NSManaged var htmlURL: String
    @NSManaged var cache: ManagedUserCache
}

extension ManagedUser {
    static func users(from localUsers: [LocalUser], in context: NSManagedObjectContext) -> NSOrderedSet {
        return NSOrderedSet(array: localUsers.map { local in
            let managed = ManagedUser(context: context)
            managed.login = local.login
            managed.avatarURL = local.avatarURL
            managed.htmlURL = local.htmlURL
            return managed
        })
    }
    
    var local: LocalUser {
        return LocalUser(login: login, avatarURL: avatarURL, htmlURL: htmlURL)
    }
}
