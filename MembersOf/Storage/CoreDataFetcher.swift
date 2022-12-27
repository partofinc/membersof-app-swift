

import Foundation
import CoreData
import Combine

final class CoreDataFetcher<T: Storable>: NSObject, NSFetchedResultsControllerDelegate, Fetcher {
    
    private let context: NSManagedObjectContext
    private var controller: NSFetchedResultsController<T.EntityType>!
    let subject: PassthroughSubject<[T.EntityType], Error> = .init()
    
    init(_ context: NSManagedObjectContext) {
        self.context = context
        super.init()
    }
    
    func sink(receiveValue: @escaping ([T]) -> Void, in queue: DispatchQueue, failure: @escaping (Error) -> Void, query: StorageQuery<T>) -> AnyCancellable {
        let canceler = subject.eraseToAnyPublisher()
            .sink { completion in
                switch completion {
                case .failure(let error):
                    queue.async {
                        failure(error)
                    }
                default:
                    break
                }
            } receiveValue: { value in
                queue.async {
                    receiveValue(value.filter(query.filter).map(T.init))
                }
            }
        start(with: query.descriptors)
        return canceler
    }
    
    private func start(with descriptors: [SortDescriptor<T.EntityType>]) {
        let request = T.fetchRequest()
        request.sortDescriptors = descriptors.map(NSSortDescriptor.init)
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
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        if let obj = self.controller.fetchedObjects {
            self.subject.send(obj)
        }
    }
}
