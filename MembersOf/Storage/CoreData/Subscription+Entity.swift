

import Foundation
import CoreData

extension Subscription: Storable {
    
    static func fetchRequest() -> NSFetchRequest<Entity> {
        return NSFetchRequest<Entity>(entityName: "Subscription")
    }
    
    @objc(SubscriptionEntity)
    final class Entity: NSManagedObject {
        
        @NSManaged public var id: UUID
        @NSManaged public var startDate: Date
        @NSManaged public var endDate: Date?
        @NSManaged public var member: Member.Entity
        @NSManaged public var membership: Membership.Entity
        @NSManaged public var visits: Set<Visit.Entity>?
    }
    
    init(_ entity: Entity) {
        id = entity.id
        startDate = entity.startDate
        endDate = entity.endDate
        member = .init(entity.member)
        membership = .init(entity.membership)
        visits = entity.visits == nil ? 0 : entity.visits!.count
    }
    
    func entity(_ context: NSManagedObjectContext) -> Entity {
        let entity = find(in: context) ?? Entity(context: context)
        return entity
    }
    
    func find(in context: NSManagedObjectContext) -> Entity? {
        Subscription.first(in: context, key: "id", value: id.uuidString)
    }
}