

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
        
        init(_ context: NSManagedObjectContext) {
            self.context = context
            super.init()
            NotificationCenter.default.addObserver(self, selector: #selector(refetchIfNeeded), name: .NSManagedObjectContextDidSave, object: nil)
        }
        
        deinit {
            cancel()
            NotificationCenter.default.removeObserver(self)
        }
        
        func filter(with predicate: NSPredicate, type: NSCompoundPredicate.LogicalType = .and, skip: Bool = false) -> Self {
            guard !skip else { return self }
            let predicates: [NSPredicate] = compoundPredicate == nil ? [predicate] : [compoundPredicate!, predicate]
            compoundPredicate = .init(type: type, subpredicates: predicates)
            return self
        }
        
        func assign<Root>(
            to keyPath: ReferenceWritableKeyPath<Root, [T]>,
            on object: Root,
            in queue: DispatchQueue = .main,
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
                        queue.async {
                            object[keyPath: keyPath] = res
                        }
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
        
        @objc func refetchIfNeeded(_ notification: Notification) {
            guard let inserted = notification.userInfo?[NSInsertedObjectsKey] as? T.EntityType else { return }
            do {
                try self.controller.performFetch()
                if let obj = self.controller.fetchedObjects {
                    self.subject.send(obj)
                }
            } catch {
                self.subject.send(completion: .failure(error))
            }
        }
        
        func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
            if let obj = self.controller.fetchedObjects {
                self.subject.send(obj)
            }
        }
        
//        func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChangeContentWith diff: CollectionDifference<NSManagedObjectID>) {
//            if let obj = self.controller.fetchedObjects {
//                self.subject.send(obj)
//            }
//        }
    }
}
