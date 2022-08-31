

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
        private var filters: [(T.EntityType) -> Bool] = []
        
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
        
        func filter(by check: @escaping (T.EntityType) -> Bool) -> Self {
            filters.append(check)
            return self
        }
        
        func assign<Root>(
            to keyPath: ReferenceWritableKeyPath<Root, [T]>,
            on object: Root,
            in queue: DispatchQueue = .main,
            failure: @escaping (Error) -> Void = {_ in}) -> Self {
                canceler = subject.eraseToAnyPublisher()
                    .sink { comp in
                        switch comp {
                        case .failure(let error):
                            queue.async {
                                failure(error)
                            }
                        default:
                            break
                        }
                    } receiveValue: { [unowned self] value in
                        let result = self.filtered(value)
                        queue.async {
                            object[keyPath: keyPath] = result
                        }
                    }
                return self
            }
        
        func sink(
            receiveValue: @escaping ([T]) -> Void,
            in queue: DispatchQueue = .main,
            failure: @escaping (Error) -> Void = {_ in}) -> Self {
            canceler = subject.eraseToAnyPublisher()
                .sink(receiveCompletion: {
                    switch $0 {
                    case .failure(let error):
                        queue.async {
                            failure(error)
                        }
                    default:
                        break
                    }
                }, receiveValue: { [unowned self] value in
                    let result = self.filtered(value)
                    queue.async {
                        receiveValue(result)
                    }
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
        
        private func filtered(_ result: [T.EntityType]) -> [T] {
            result.filter({ entity in
                for check in filters {
                    guard check(entity) else { return false }
                    continue
                }
                return true
            }).map(T.init)
        }
        
        func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
            if let obj = self.controller.fetchedObjects {
                self.subject.send(obj)
            }
        }
    }
}
