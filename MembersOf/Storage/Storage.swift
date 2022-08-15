

import Foundation
import CoreData
import Combine

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
        var err: Error?
        await context.perform {
            perform(context)
            do {
                try context.save()
            } catch {
                err = error
            }
        }
        if let err { throw err }
        guard container.viewContext.hasChanges else { return }
        do {
            try self.container.viewContext.save()
        } catch {
            err = error
        }
        if let err { throw err }
    }
}

extension Storage {
    
    final class Fetcher<T: Storable>: NSObject, NSFetchedResultsControllerDelegate {
        
        private let context: NSManagedObjectContext
        private var controller: NSFetchedResultsController<T.EntityType>!
        private let subject: PassthroughSubject<[T.EntityType], Error> = .init()
        private var canceler: AnyCancellable?
        private var compoundPredicate: NSCompoundPredicate?
        
        init(_ context: NSManagedObjectContext) {
            self.context = context
            super.init()
        }
        
        deinit {
            cancel()
        }
        
        func filter(with predicate: NSPredicate, type: NSCompoundPredicate.LogicalType = .and, skip: Bool = false) -> Self {
            guard skip == false else { return self }
            let predicates: [NSPredicate] = compoundPredicate == nil ? [predicate] : [compoundPredicate!, predicate]
            compoundPredicate = .init(type: type, subpredicates: predicates)
            return self
        }
        
        func assign<Root>(
            to keyPath: ReferenceWritableKeyPath<Root, [T]>,
            on object: Root,
            failure: @escaping (Error) -> Void = {_ in}) -> Self {
                canceler = subject.eraseToAnyPublisher()
                    .map({$0.map(T.init)})
                    .sink { comp in
                        switch comp {
                        case .failure(let error):
                            failure(error)
                        default:
                            break
                        }
                    } receiveValue: { res in
                        object[keyPath: keyPath] = res
                    }
                return self
            }
        
        func sink(receiveValue: @escaping ([T]) -> Void, failure: @escaping (Error) -> Void) -> Self {
            canceler = subject.eraseToAnyPublisher()
                .map({$0.map(T.init)})
                .sink(receiveCompletion: {
                    switch $0 {
                    case .failure(let error):
                        failure(error)
                    default:
                        break
                    }
                }, receiveValue: receiveValue)
            return self
        }
        
        func cancel() {
            canceler?.cancel()
        }
        
        func run(sort: [NSSortDescriptor]) -> Self {
            let request = T.fetchRequest()
            request.predicate = compoundPredicate
            request.sortDescriptors = sort
            controller = .init(fetchRequest: request, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
            controller.delegate = self
            do {
                try self.controller.performFetch()
                if let obj = self.controller.fetchedObjects {
                    self.subject.send(obj)
                }
            } catch {
                self.subject.send(completion: .failure(error))
            }
            return self
        }
        
        func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
            if let obj = self.controller.fetchedObjects {
                self.subject.send(obj)
            }
        }
    }
}

