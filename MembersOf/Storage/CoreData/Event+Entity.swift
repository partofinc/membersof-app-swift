

import Foundation
import CoreData
import Models

extension Event: Storable {
    
    static func fetchRequest() -> NSFetchRequest<Entity> {
        return NSFetchRequest<Entity>(entityName: "Event")
    }
        
    @objc(EventEntity)
    final class Entity: NSManagedObject {
        
        @NSManaged public var id: UUID
        @NSManaged public var name: String
        @NSManaged public var startDate: Date
        @NSManaged public var endDate: Date?
        @NSManaged public var estimatedEndDate: Date?
        @NSManaged public var createDate: Date
        @NSManaged public var team: Team.Entity
        @NSManaged public var memberships: Set<Membership.Entity>?
    }
    
    init(_ entity: Entity) {
        self.init(id: entity.id, name: entity.name, createDate: entity.createDate, startDate: entity.startDate, estimatedEndDate: entity.estimatedEndDate, endDate: entity.endDate, team: .init(entity.team), memberships: entity.memberships == nil ? [] : entity.memberships!.map(Membership.init))
    }
    
    func entity(_ context: NSManagedObjectContext) -> Entity {
        let entity = find(in: context) ?? Entity(context: context)
        entity.id = id
        entity.name = name
        entity.startDate = startDate
        entity.endDate = endDate
        entity.estimatedEndDate = estimatedEndDate
        entity.createDate = createDate
        entity.team = team.entity(context)
        entity.memberships = Set(memberships.map{$0.entity(context)})
        return entity
    }
    
    func find(in context: NSManagedObjectContext) -> Entity? {
        Event.first(in: context, key: "id", value: id.uuidString)
    }
}
