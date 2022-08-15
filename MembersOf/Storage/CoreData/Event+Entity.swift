

import Foundation
import CoreData

extension Event: Storable {
    
    static func fetchRequest() -> NSFetchRequest<Entity> {
        return NSFetchRequest<Entity>(entityName: "Event")
    }
    
    @objc(EventEntity)
    final class Entity: NSManagedObject {
        
        @NSManaged public var id: UUID?
        @NSManaged public var name: String?
        @NSManaged public var startDate: Date?
        @NSManaged public var endDate: Date?
        @NSManaged public var createDate: Date?
//        @NSManaged public var visits: Set<Visit.Entity>?
    }
    
    init(_ entity: Entity) {
        id = entity.id!
        name = entity.name!
        createDate = entity.createDate!
        startDate = entity.startDate
        endDate = entity.endDate
//        visits = entity.visits == nil ? [] : entity.visits!.map(Visit.init)
    }
    
    func entity(_ context: NSManagedObjectContext) -> Entity {
        let entity = find(in: context) ?? Entity(context: context)
        entity.id = id
        entity.name = name
        entity.startDate = startDate
        entity.endDate = endDate
        entity.createDate = createDate
        return entity
    }
    
    func find(in context: NSManagedObjectContext) -> Entity? {
        Event.first(in: context, key: "id", value: id.uuidString)
    }
}
