

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
        @NSManaged public var payments: Set<Payment.Entity>?
    }
    
    init(_ entity: Entity) {
        id = entity.id
        startDate = entity.startDate
        endDate = entity.endDate
        member = .init(entity.member)
        membership = .init(entity.membership)
        payments = []
    }
    
    func entity(_ context: NSManagedObjectContext) -> Entity {
        let entity = find(in: context) ?? Entity(context: context)
        entity.id = id
        entity.startDate = startDate
        entity.endDate = endDate
        entity.member = member.entity(context)
        entity.membership = membership.entity(context)
        entity.payments = Set(payments.map{$0.entity(context)})
        return entity
    }
    
    func find(in context: NSManagedObjectContext) -> Entity? {
        Subscription.first(in: context, key: "id", value: id.uuidString)
    }
}
