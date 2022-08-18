

import Foundation
import CoreData
import Combine

extension Storage {
    
    final class Fetcher<T: Storable>: NSObject, NSFetchedResultsControllerDelegate {
        
        private let context: NSManagedObjectContext
        private var controller: NSFetchedResultsController<T.EntityType>!
        private let subject: PassthroughSubject<[T.EntityType], Error> = .init()
        private var canceler: AnyCancellable?
        private var compoundPredicate: NSCompoundPredicate?
        private var filter: Filter<T.EntityType, UUID>?
        
        init(_ context: NSManagedObjectContext) {
            self.context = context
            super.init()
        }
        
        deinit {
            cancel()
        }
        
        func filter(with predicate: NSPredicate, type: NSCompoundPredicate.LogicalType = .and, skip: Bool = false) -> Self {
            guard !skip else { return self }
            let predicates: [NSPredicate] = compoundPredicate == nil ? [predicate] : [compoundPredicate!, predicate]
            compoundPredicate = .init(type: type, subpredicates: predicates)
            return self
        }
        
        func filter(by path: KeyPath<T.EntityType, UUID>, value: UUID) -> Self {
            self.filter = .init(path: path, value: value)
            return self
        }
        
        func assign<Root>(
            to keyPath: ReferenceWritableKeyPath<Root, [T]>,
            on object: Root,
            in queue: DispatchQueue = .main,
            failure: @escaping (Error) -> Void = {_ in}) -> Self {
                canceler = subject.eraseToAnyPublisher()
//                    .map({$0.map(T.init)})
                    .sink { comp in
                        switch comp {
                        case .failure(let error):
                            failure(error)
                        default:
                            break
                        }
                    } receiveValue: { value in
                        let result = self.filter == nil ? value : value.filter(self.filter!.isIncluded)
                        queue.async {
                            object[keyPath: keyPath] = result.map(T.init)
                        }
                    }
                return self
            }
        
        func sink(receiveValue: @escaping ([T]) -> Void, failure: @escaping (Error) -> Void) -> Self {
            canceler = subject.eraseToAnyPublisher()
//                .map({$0.map(T.init)})
                .sink(receiveCompletion: {
                    switch $0 {
                    case .failure(let error):
                        failure(error)
                    default:
                        break
                    }
                }, receiveValue: { value in
                    let result = self.filter == nil ? value : value.filter(self.filter!.isIncluded)
                    receiveValue(result.map(T.init))
                })
            return self
        }
        
        func cancel() {
            canceler?.cancel()
        }
        
        func run(sort: [SortDescriptor<T.EntityType>]) -> Self {
            let request = T.fetchRequest()
            request.predicate = compoundPredicate
            request.sortDescriptors = sort.map(NSSortDescriptor.init)
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
    
    struct Filter<Element, Value: Equatable> {
        
        let path: KeyPath<Element, Value>
        let value: Value
        
        func isIncluded(_ entity: Element) -> Bool {
            entity[keyPath: path] == value
        }
    }
}
