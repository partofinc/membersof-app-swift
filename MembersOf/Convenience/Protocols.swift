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

    func sub<T: Storable>(_ type: T.Type) -> AnyFetcher<T>
    func fetch<T>() -> CoreDataStorage.Fetcher<T>
    func delete(_ entities: [any Storable]) async throws
    func delete(_ entity: some Storable) async throws
    func save(_ entities: [any Storable]) async throws
    func save(_ entity: some Storable) async throws
}

protocol Signer: AnyObject {
        
    var me: CurrentValueSubject<Member, Never> {get}
    var signedIn: Bool {get}
    var storage: any Storage {get}
    
    func signIn(_ member: Member)
    func signOut()
}

