

import Foundation
import CoreData

extension Supervisor: Storable {
    
    static func fetchRequest() -> NSFetchRequest<Entity> {
        return NSFetchRequest<Entity>(entityName: "Supervisor")
    }
    
    @objc(SupervisorEntity)
    final class Entity: NSManagedObject {
        
        @NSManaged public var id: UUID?
        @NSManaged public var role: String?
        @NSManaged public var order: Int32
        @NSManaged public var member: Member.Entity?
    }
    
    init(_ entity: Entity) {
        id = entity.id!
        role = .init(rawValue: entity.role!)!
        order = Int(entity.order)
        member = .init(entity.member!)
    }
    
    func entity(_ context: NSManagedObjectContext) -> Entity {
        let entity = find(in: context) ?? Entity(context: context)
        entity.id = id
        entity.role = role.rawValue
        entity.order = .init(order)
        entity.member = member.entity(context)
        return entity
    }
    
    func find(in context: NSManagedObjectContext) -> Entity? {
        Supervisor.first(in: context, key: "id", value: id.uuidString)
    }
}
