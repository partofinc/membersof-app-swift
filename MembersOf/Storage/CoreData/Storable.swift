

import Foundation
import CoreData

protocol Storable {
    
    associatedtype EntityType: NSManagedObject
    static func fetchRequest() -> NSFetchRequest<EntityType>
    
    init(_ entity: EntityType)
    
    func entity(_ context: NSManagedObjectContext) -> EntityType
    func find(in context: NSManagedObjectContext) -> EntityType?
}
