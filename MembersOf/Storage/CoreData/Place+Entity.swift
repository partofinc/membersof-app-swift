//
//  Place+Entity.swift
//  MembersOf
//
//  Created by Ravil Khusainov on 2023-02-07.
//

import Foundation
import CoreData

extension Place: Storable {
    
    static func fetchRequest() -> NSFetchRequest<Entity> {
        NSFetchRequest<Entity>(entityName: "Place")
    }
    
    @objc(PlaceEntity)
    final class Entity: NSManagedObject {
        
        @NSManaged var id: UUID
        @NSManaged var name: String
        @NSManaged var latitude: Double
        @NSManaged var longitude: Double
    }
    
    init(_ entity: Entity) {
        id = entity.id
        name = entity.name
        latitude = entity.latitude
        longitude = entity.longitude
    }
    
    func entity(_ context: NSManagedObjectContext) -> Entity {
        let entity = find(in: context) ?? Entity(context: context)
        entity.id = id
        entity.name = name
        entity.latitude = latitude
        entity.longitude = longitude
        return entity
    }
    
    func find(in context: NSManagedObjectContext) -> Entity? {
        Place.first(in: context, key: "id", value: id.uuidString)
    }
}
