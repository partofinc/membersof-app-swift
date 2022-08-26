

import Foundation
import CoreData

extension Invite: Storable {
    
    static func fetchRequest() -> NSFetchRequest<Entity> {
        return NSFetchRequest<Entity>(entityName: "Invite")
    }
    
    @objc(InviteEntity)
    final class Entity: NSManagedObject {
        
        @NSManaged public var id: UUID
        @NSManaged public var createDate: Date
        @NSManaged public var name: String?
        @NSManaged public var role: String?
        @NSManaged public var team: Team.Entity?
    }
    
    init(_ entity: Entity) {
        id = entity.id
    }
    
    func entity(_ context: NSManagedObjectContext) -> Entity {
        
    }
    
    func find(in context: NSManagedObjectContext) -> Entity? {
        
    }
}
