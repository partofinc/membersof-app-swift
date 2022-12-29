//
//  Storage.swift
//  MembersOf
//
//  Created by Ravil Khusainov on 2022-11-30.
//

import Foundation
import Combine
import Models

protocol Storage {

    func fetch<T: Storable>(_ type: T.Type) -> StoragePublisher<T>
    func delete(_ entities: [any Storable]) async throws
    func delete(_ entity: some Storable) async throws
    func save(_ entities: [any Storable]) async throws
    func save(_ entity: some Storable) async throws
}

protocol Fetcher<T>: Combine.Subscription {
    
    associatedtype T: Storable
    func start<S: Subscriber>(with subscriber: S) where S.Input == [T], S.Failure == Error
}

protocol Signer: AnyObject {
        
    var me: CurrentValueSubject<Member, Never> {get}
    var signedIn: Bool {get}
    var storage: any Storage {get}
    
    func signIn(_ member: Member)
    func signOut()
}

