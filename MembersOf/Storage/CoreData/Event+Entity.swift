

import Foundation
import CoreData

extension Event: Storable {
    
    static func fetchRequest() -> NSFetchRequest<Entity> {
        return NSFetchRequest<Entity>(entityName: "Member")
    }
    
    @objc(EventEntity)
    final class Entity: NSManagedObject {
        
        @NSManaged public var id: UUID?
        @NSManaged public var name: String?
        @NSManaged public var startDate: Date?
        @NSManaged public var endDate: Date?
//        @NSManaged public var visits: [Visit.Entity]?
    }
    
    init(_ entity: Entity) {
        id = entity.id!
        name = entity.name!
        startDate = entity.startDate!
        endDate = entity.endDate!
        visits = []
    }
    
    func entity(_ context: NSManagedObjectContext) -> Entity {
        let result = find(in: context)
        let entity = result == nil ? Entity(context: context) : result!
        return entity
    }
    
    func find(in context: NSManagedObjectContext) -> Entity? {
        let request = Event.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id.uuidString)
        return try? context.fetch(request).first
    }
}
