

import Foundation
import CoreData


extension Event.Visit: Storable {
    
    static func fetchRequest() -> NSFetchRequest<Entity> {
        return NSFetchRequest<Entity>(entityName: "Visit")
    }
    
    @objc(VisitEntity)
    final class Entity: NSManagedObject {
        
        @NSManaged public var id: UUID?
        @NSManaged public var member: Member.Entity?
        @NSManaged public var event: Event.Entity?
        @NSManaged public var checkInDate: Date?
    }
    
    init(_ entity: Entity) {
        id = entity.id!
        checkInDate = entity.checkInDate!
        eventId = entity.event!.id!
        member = .init(entity.member!)
    }
    
    func entity(_ context: NSManagedObjectContext) -> Entity {
        let entity = find(in: context) ?? Entity(context: context)
        entity.id = id
        entity.checkInDate = checkInDate
        entity.event = Event.first(in: context, key: "id", value: eventId.uuidString)
        entity.member = Member.first(in: context, key: "id", value: member.id.uuidString)
        return entity
    }
    
    func find(in context: NSManagedObjectContext) -> Entity? {
        Event.Visit.first(in: context, key: "id", value: id.uuidString)
    }
}
