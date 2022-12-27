//
//  StoragePublisher.swift
//  MembersOf
//
//  Created by Ravil Khusainov on 2022-12-27.
//

import Foundation
import Combine

struct StoragePublisher<T: Storable> {
        
    let fetcher: any Fetcher<T>
    let queue: DispatchQueue
    let failure: (Error) -> Void
    let filter: (T.EntityType) -> Bool
    let descriptors: [SortDescriptor<T.EntityType>]
    
    init(
        fetcher: some Fetcher<T>,
        queue: DispatchQueue = .main,
        failure: @escaping (Error) -> Void = {_ in},
        filter: @escaping (T.EntityType) -> Bool = {_ in true},
        descriptors: [SortDescriptor<T.EntityType>] = []) {
            self.fetcher = fetcher
            self.queue = queue
            self.failure = failure
            self.filter = filter
            self.descriptors = descriptors
        }
    
    func subscribe(in queue: DispatchQueue) -> Self {
        .init(fetcher: fetcher, queue: queue, failure: failure, filter: filter, descriptors: descriptors)
    }
    
    func `catch`(_ failure: @escaping (Error) -> Void) -> Self {
        .init(fetcher: fetcher, queue: queue, failure: failure, filter: filter, descriptors: descriptors)
    }
    
    func filter(by condition: @escaping (T.EntityType) -> Bool) -> Self {
        .init(fetcher: fetcher, queue: queue, failure: failure, filter: condition, descriptors: descriptors)
    }
    
    func sort(by descriptors: [SortDescriptor<T.EntityType>]) -> Self {
        .init(fetcher: fetcher, queue: queue, failure: failure, filter: filter, descriptors: descriptors)
    }
    
    func sink(receiveValue: @escaping ([T]) -> Void) -> AnyCancellable {
        fetcher.sink(receiveValue: receiveValue, in: queue, failure: failure, query: .init(filter: filter, descriptors: descriptors))
    }
    
    func assign<Root: AnyObject>(to keyPath: ReferenceWritableKeyPath<Root, [T]>, on object: Root) -> AnyCancellable {
        sink { [unowned object] value in
            object[keyPath: keyPath] = value
        }
    }
}

struct StorageQuery<T: Storable> {
    let filter: (T.EntityType) -> Bool
    let descriptors: [SortDescriptor<T.EntityType>]
}
