

import Foundation
import CoreData

final class Storage {
    
    static let shared = Storage()
    
    private let container: NSPersistentContainer = .init(name: "CoreModel")
    
    private init() {
        container.loadPersistentStores { brief, error in
            if let error {
                print("CoreData loading failed with error: \(error.localizedDescription)")
            }
        }
    }
    
    func fetch<Entity: Storable>() -> Fetcher<Entity> {
        return Fetcher(container.viewContext)
    }
    
    func find<Entity: Storable>(key: String, value: String) -> Entity? {
        Entity.first(in: container.viewContext, key: key, value: value).map(Entity.init)
    }
    
    func save(_ entities: [any Storable]) async throws {
        try await update { context in
            _ = entities.map{$0.entity(context)}
        }
    }
    
    func save(_ entity: some Storable) async throws {
        try await save([entity])
    }
    
    func delete(_ entities: [any Storable]) async throws {
        try await update { context in
            entities.forEach { value in
                if let obj = value.find(in: context) {
                    context.delete(obj)
                }
            }
        }
    }
    
    func delete(_ entity: some Storable) async throws {
        try await delete([entity])
    }
    
    fileprivate func update(_ perform: @escaping (NSManagedObjectContext) -> Void) async throws {
        let context = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        context.parent = container.viewContext
        try await context.perform {
            perform(context)
            try context.saveIfNeeded()
        }
        try self.container.viewContext.saveIfNeeded()
    }
}


extension NSManagedObjectContext {
    func saveIfNeeded() throws {
        guard hasChanges else { return }
        try save()
    }
}

