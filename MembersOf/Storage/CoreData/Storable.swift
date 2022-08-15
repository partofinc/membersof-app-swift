

import Foundation
import CoreData

protocol Storable {
    
    associatedtype EntityType: NSManagedObject
    static func fetchRequest() -> NSFetchRequest<EntityType>
    
    init(_ entity: EntityType)
    
    func entity(_ context: NSManagedObjectContext) -> EntityType
    func find(in context: NSManagedObjectContext) -> EntityType?
}

extension Storable {
    static func first(in context: NSManagedObjectContext, key: String, value: String) -> EntityType? {
        let request = fetchRequest()
        request.predicate = NSPredicate(format: "%K == %@", key, value)
        return try? context.fetch(request).first
    }
}
