

import Foundation
import CoreData
import Models

extension Membership: Storable {
    
    static func fetchRequest() -> NSFetchRequest<Entity> {
        return NSFetchRequest<Entity>(entityName: "Membership")
    }
    
    @objc(MembershipEntity)
    final class Entity: NSManagedObject {
        
        @NSManaged public var id: UUID
        @NSManaged public var name: String?
        @NSManaged public var period: String?
        @NSManaged public var length: Int32
        @NSManaged public var visits: Int32
        @NSManaged public var createDate: Date
        @NSManaged public var team: Team.Entity
        @NSManaged public var pricing: Set<Price.Entity>?
    }
    
    init(_ entity: Entity) {
        self.init(id: entity.id, name: entity.name!, visits: .init(entity.visits), period: .init(rawValue: entity.period!)!, length: .init(entity.length), createDate: entity.createDate, team: .init(entity.team), pricing: entity.pricing == nil ? [] : entity.pricing!.map(Price.init))
    }
    
    func entity(_ context: NSManagedObjectContext) -> Entity {
        let entity = find(in: context) ?? Entity(context: context)
        entity.id = id
        entity.name = name
        entity.period = period.rawValue
        entity.visits = .init(visits)
        entity.length = .init(length)
        entity.createDate = createDate
        if let team = Team.first(in: context, key: "id", value: team.id.uuidString) {
            entity.team = team
        }
        if !pricing.isEmpty {
            entity.pricing = Set(pricing.map({$0.entity(context)}))
        }
        return entity
    }
    
    func find(in context: NSManagedObjectContext) -> Entity? {
        Membership.first(in: context, key: "id", value: id.uuidString)
    }
}
