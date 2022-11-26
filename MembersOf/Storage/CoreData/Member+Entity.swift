
import Foundation
import CoreData
import Models

extension Member: Storable {
        
    static func fetchRequest() -> NSFetchRequest<Entity> {
        return NSFetchRequest<Entity>(entityName: "Member")
    }
    
    @objc(MemberEntity)
    final class Entity: NSManagedObject {
        
        @NSManaged public var id: UUID
        @NSManaged public var firstName: String
        @NSManaged public var lastName: String?
    }
    
    init(_ entity: Entity) {
        self.init(id: entity.id, firstName: entity.firstName, lastName: entity.lastName)
    }
    
    func entity(_ context: NSManagedObjectContext) -> Entity {
        let e = find(in: context) ?? Entity(context: context)
        e.id = id
        e.firstName = firstName
        e.lastName = lastName
        return e
    }
    
    func find(in context: NSManagedObjectContext) -> Entity? {
        Member.first(in: context, key: "id", value: id.uuidString)
    }
}

