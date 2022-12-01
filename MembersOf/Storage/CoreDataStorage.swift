

import Foundation
import CoreData

final class CoreDataStorage: Storage {

    private let container: NSPersistentContainer
    
    init(_ containerName: String) {
        container = .init(name: containerName)
        container.loadPersistentStores { brief, error in
            if let error {
                print("CoreData loading failed with error: \(error.localizedDescription)")
            }
        }
    }
    
    func fetch<T>() -> Fetcher<T> where T : Storable {
        Fetcher(container.viewContext)
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

//@propertyWrapper
//class StorageBacked<Value: Storable> {
//    
//    let key: String
//    let value: String
//    let defaultValue: Value
//    let storage: CoreDataStorage
//    
//    init(key: String, value: String, defaultValue: Value) {
//        self.key = key
//        self.value = value
//        self.defaultValue = defaultValue
//    }
//    
//    var wrappedValue: Value {
//        get {
//            storage.find(key: key, value: value) ?? defaultValue
//        }
//        set {
//            Task {
//                try await storage.save(newValue)
//            }
//        }
//    }
//}

