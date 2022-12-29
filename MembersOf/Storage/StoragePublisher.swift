//
//  StoragePublisher.swift
//  MembersOf
//
//  Created by Ravil Khusainov on 2022-12-27.
//

import Foundation
import Combine

struct StoragePublisher<T: Storable>: Publisher {
    
    typealias Output = [T]
    typealias Failure = Error
    typealias Constructor = (StorageQuery<T>) -> any Fetcher<T>
            
    let constructor: Constructor
    let filter: (T.EntityType) -> Bool
    let descriptors: [SortDescriptor<T.EntityType>]
    
    init(constructor: @escaping Constructor, filter: @escaping (T.EntityType) -> Bool = {_ in true}, descriptors: [SortDescriptor<T.EntityType>] = []) {
            self.constructor = constructor
            self.filter = filter
            self.descriptors = descriptors
        }
    
    func subscribe(in queue: DispatchQueue) -> Self {
        .init(constructor: constructor, filter: filter, descriptors: descriptors)
    }
    
    func filter(by condition: @escaping (T.EntityType) -> Bool) -> Self {
        .init(constructor: constructor, filter: condition, descriptors: descriptors)
    }
    
    func sort(by descriptors: [SortDescriptor<T.EntityType>]) -> Self {
        .init(constructor: constructor, filter: filter, descriptors: descriptors)
    }
    
    func receive<S>(subscriber: S) where S : Subscriber, Failure == S.Failure, [T] == S.Input {
        let fetcher = constructor(.init(filter: filter, descriptors: descriptors))
        subscriber.receive(subscription: fetcher)
        fetcher.start(with: subscriber)
    }
}

struct StorageQuery<T: Storable> {
    let filter: (T.EntityType) -> Bool
    let descriptors: [SortDescriptor<T.EntityType>]
}

