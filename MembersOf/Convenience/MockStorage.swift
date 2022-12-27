//
//  MockStorage.swift
//  MembersOf
//
//  Created by Ravil Khusainov on 2022-11-30.
//

import Foundation
import Models
import Combine

final class MockStorage: Storage {
    
    func fetch<T>(_ type: T.Type) -> StoragePublisher<T> where T : Storable {
        .init(fetcher: MockFetcher(storage: self))
    }
    
    func delete(_ entities: [any Storable]) async throws {
        
    }
    
    func delete(_ entity: some Storable) async throws {
        
    }
    
    func save(_ entities: [any Storable]) async throws {
        
    }
    
    func save(_ entity: some Storable) async throws {
        
    }
    
    
    private(set) var teams: [Team] = []
    private(set) var members: [Member] = []
    
    init() {
        
        let durov: Member = .init(id: UUID(), firstName: "Elon", lastName: "Dirov")
        let cook: Member = .init(id: UUID(), firstName: "John", lastName: "Cook")
        let yanis: Member = .init(id: UUID(), firstName: "Yanis", lastName: "Yanakdis")
        let murat: Member = .init(id: UUID(), firstName: "Murat", lastName: "Azbergenov")
        members = [durov, cook, yanis, murat]
        
        let strela: Team = .init(
            id: UUID(),
            name: "Strela Kazan",
            brief: "The best Jiu Jitsu team in Kazan",
            createDate: .now,
            social: [],
            crew: [
                .init(id: UUID(), role: .owner, order: 0, member: yanis, teamId: nil)
            ]
        )
        
        let kimura: Team = .init(
            id: UUID(),
            name: "Kimura Jiu Jitsu",
            brief: "The best Jiu Jitsu team in Alanya",
            createDate: .now,
            social: [],
            crew: [
                .init(id: UUID(), role: .owner, order: 0, member: murat, teamId: nil)
            ]
        )
        
        teams = [strela, kimura]
    }
}

struct MockFetcher<E: Storable>: Fetcher {
    
    typealias T = E
    
    let storage: MockStorage
    
    func sink(receiveValue: @escaping ([E]) -> Void, in queue: DispatchQueue, failure: @escaping (Error) -> Void, query: StorageQuery<E>) -> AnyCancellable {
        let subject: PassthroughSubject<[T.EntityType], Error> = .init()
        return subject.eraseToAnyPublisher()
            .sink { completion in
                
            } receiveValue: { output in
                
            }
    }
}
