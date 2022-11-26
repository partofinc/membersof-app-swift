

import Foundation
import CoreData
import Models

extension Visit: Storable {
    
    static func fetchRequest() -> NSFetchRequest<Entity> {
        return NSFetchRequest<Entity>(entityName: "Visit")
    }
    
    @objc(VisitEntity)
    final class Entity: NSManagedObject {
        
        @NSManaged public var id: UUID
        @NSManaged public var checkInDate: Date
        @NSManaged public var member: Member.Entity!
        @NSManaged public var event: Event.Entity!
        @NSManaged public var subscription: Subscription.Entity!
    }
    
    init(_ entity: Entity) {
        self.init(id: entity.id, checkInDate: entity.checkInDate, event: .init(entity.event), member: .init(entity.member), subscription: .init(entity.subscription))
    }
    
    func entity(_ context: NSManagedObjectContext) -> Entity {
        let entity = find(in: context) ?? Entity(context: context)
        entity.id = id
        entity.checkInDate = checkInDate
        entity.event = event.entity(context)
        entity.member = member.entity(context)
        entity.subscription = subscription.entity(context)
        return entity
    }
    
    func find(in context: NSManagedObjectContext) -> Entity? {
        Visit.first(in: context, key: "id", value: id.uuidString)
    }
}
