

import Foundation
import CoreData
import Combine

final class CoreDataFetcher<T: Storable>: NSObject, NSFetchedResultsControllerDelegate, Fetcher {
    
    let context: NSManagedObjectContext
    let query: StorageQuery<T>
    
    private var controller: NSFetchedResultsController<T.EntityType>!
    private var receive: ([T.EntityType]) -> Void = {_ in}
    
    init(context: NSManagedObjectContext, query: StorageQuery<T>) {
        self.context = context
        self.query = query
        super.init()
    }
        
    func start<S: Subscriber>(with subscriber: S) where S.Input == [T], S.Failure == Error {
        receive = { [unowned self] value in
            _ = subscriber.receive(self.calculated(value: value))
        }
        let request = T.fetchRequest()
        request.sortDescriptors = query.descriptors.map(NSSortDescriptor.init)
        controller = .init(fetchRequest: request, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
        controller.delegate = self
        do {
            try self.controller.performFetch()
            if let obj = self.controller.fetchedObjects {
                _ = subscriber.receive(obj.filter(query.filter).map(T.init))
            }
        } catch {
            subscriber.receive(completion: .failure(error))
        }
    }
    
    fileprivate func calculated(value: [T.EntityType]) -> [T] {
        value.filter(query.filter).map(T.init)
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        if let obj = self.controller.fetchedObjects {
            receive(obj)
        }
    }
    
    func cancel() {
        controller.delegate = nil
    }
    
    func request(_ demand: Subscribers.Demand) {
        
    }
}
