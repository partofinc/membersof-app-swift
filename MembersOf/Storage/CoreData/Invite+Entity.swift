

import Foundation
import CoreData
import Models

extension Invite: Storable {
    
    static func fetchRequest() -> NSFetchRequest<Entity> {
        return NSFetchRequest<Entity>(entityName: "Invite")
    }
    
    @objc(InviteEntity)
    final class Entity: NSManagedObject {
        
        @NSManaged public var id: UUID
        @NSManaged public var createDate: Date
        @NSManaged public var name: String?
        @NSManaged public var role: String
        @NSManaged public var team: Team.Entity?
    }
    
    init(_ entity: Entity) {
        self.init(id: entity.id, createDate: entity.createDate, name: entity.name, role: .init(rawValue: entity.role)!, teamId: entity.team!.id)
    }
    
    func entity(_ context: NSManagedObjectContext) -> Entity {
        let entity = find(in: context) ?? Entity(context: context)
        entity.id = id
        entity.createDate = createDate
        entity.name = name
        entity.role = role.rawValue
        entity.team = Team.first(in: context, key: "id", value: teamId.uuidString)
        return entity
    }
    
    func find(in context: NSManagedObjectContext) -> Entity? {
        Invite.first(in: context, key: "id", value: id.uuidString)
    }
}
