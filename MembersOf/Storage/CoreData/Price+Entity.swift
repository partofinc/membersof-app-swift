

import Foundation
import CoreData

extension Price: Storable {
    
    static func fetchRequest() -> NSFetchRequest<Entity> {
        return NSFetchRequest<Entity>(entityName: "Price")
    }
    
    @objc(PriceEntity)
    final class Entity: NSManagedObject {
        
        @NSManaged public var id: UUID
        @NSManaged public var currency: String
        @NSManaged public var value: NSDecimalNumber
    }
    
    init(_ entity: Entity) {
        id = entity.id
        currency = entity.currency
        value = entity.value.decimalValue
    }
    
    func entity(_ context: NSManagedObjectContext) -> Entity {
        let entity = find(in: context) ?? Entity(context: context)
        entity.id = id
        entity.currency = currency
        entity.value = NSDecimalNumber(decimal: value)
        return entity
    }
    
    func find(in context: NSManagedObjectContext) -> Entity? {
        Price.first(in: context, key: "id", value: id.uuidString)
    }
}
