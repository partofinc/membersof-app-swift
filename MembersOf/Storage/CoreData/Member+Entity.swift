//
//  Member+Entity.swift
//  MembersOf
//
//  Created by Ravil Khusainov on 8/11/22.
//

import Foundation
import CoreData

extension Member: Storable {
        
    static func fetchRequest() -> NSFetchRequest<Entity> {
        return NSFetchRequest<Entity>(entityName: "Member")
    }
    
    @objc(MemberEntity)
    final class Entity: NSManagedObject {
        
        @NSManaged public var id: UUID?
        @NSManaged public var firstName: String?
        @NSManaged public var lastName: String?
    }
    
    init(_ entity: Entity) {
        id = entity.id!
        firstName = entity.firstName!
        lastName = entity.lastName!
    }
    
    func entity(_ context: NSManagedObjectContext) -> Entity {
        let result = find(in: context)
        let e = result == nil ? Entity(context: context) : result!
        e.id = id
        e.firstName = firstName
        e.lastName = lastName
        return e
    }
    
    func find(in context: NSManagedObjectContext) -> Entity? {
        let request = Member.fetchRequest()
        request.predicate = NSPredicate(format: "self.id == %@", id.uuidString)
        return try? context.fetch(request).first
    }
}

protocol Storable {
    
    associatedtype EntityType: NSManagedObject
    static func fetchRequest() -> NSFetchRequest<EntityType>
    
    init(_ entity: EntityType)
    
    func entity(_ context: NSManagedObjectContext) -> EntityType
    func find(in context: NSManagedObjectContext) -> EntityType?
}
