//
//  CoreDataFetcher.swift
//  MembersOf
//
//  Created by Ravil Khusainov on 2022-12-03.
//

import Foundation
import Combine
import CoreData

final class CoreDataSubscription<T: Storable>: Subscription {

    typealias Output = T

    let context: NSManagedObjectContext
    let subject: PassthroughSubject<[Output.EntityType], Error> = .init()

    init(context: NSManagedObjectContext) {
        self.context = context
    }

    func request(_ demand: Subscribers.Demand) {
        print("Demand", demand)
    }

    func cancel() {
        
    }
}


struct AnyFetcher<V: Storable>: Publisher {
    
    typealias Output = V
    typealias Failure = Error

    let subscription: CoreDataSubscription<Output>
    let descriptors: [SortDescriptor<Output.EntityType>]
    let filter: (Output.EntityType) -> Bool
    
    init(subscription: CoreDataSubscription<Output>, descriptors: [SortDescriptor<Output.EntityType>] = [], filter: @escaping (Output.EntityType) -> Bool = {_ in true}) {
        self.subscription = subscription
        self.descriptors = descriptors
        self.filter = filter
    }
    
    func sort(_ descriptors: [SortDescriptor<Output.EntityType>]) -> Self {
        .init(subscription: subscription, descriptors: self.descriptors + descriptors, filter: filter)
    }
    
    func `catch`(_ failure: @escaping (Failure) -> Void) -> Self {
        .init(subscription: subscription, descriptors: descriptors, filter: filter)
    }
    
    func filter(_ isIncluded: @escaping (Output.EntityType) -> Bool) -> Self {
        .init(subscription: subscription, descriptors: self.descriptors + descriptors, filter: isIncluded)
    }
    
    func sink(_ receiveValue: @escaping ([Output]) -> Void) -> AnyCancellable {
        subscription.subject
            .map { $0.compactMap { e in
                guard self.filter(e) else { return nil }
                return Output(e)
            } }
            .sink { com in

            } receiveValue: { val in
                receiveValue(val)
            }
    }
    
    func receive<S>(subscriber: S) where S : Subscriber, Failure == S.Failure, V == S.Input {
        subscriber.receive(subscription: subscription)
    }
}


//import Models
//
//class Testing {
//
//    var can: AnyCancellable?
//
//    func start() {
//        can = AnyFetcher(subscription: CoreDataSubscription<Event>(context: .init(concurrencyType: .mainQueueConcurrencyType)))
//            .sort([.init(\.id)])
//            .sink { v in
//                print(v.id)
//            }
//    }
//}
