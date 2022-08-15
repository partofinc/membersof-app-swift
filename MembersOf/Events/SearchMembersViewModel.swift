//
//  SearchMembersViewModel.swift
//  MembersOf
//
//  Created by Ravil Khusainov on 8/9/22.
//

import Foundation
import Combine

extension SearchMembersView {
    
    @MainActor
    final class ViewModel: ObservableObject {
        
        let team: Team
        let event: Event
        private let storage: Storage = .shared
        private var membersFetcher: Storage.Fetcher<Member>?
        private var sort: [NSSortDescriptor] = [.init(keyPath: \Member.Entity.firstName, ascending: false)]
        
        init(team: Team, event: Event) {
            self.team = team
            self.event = event
            search()
        }
        
        @Published var pattern: String = ""
        @Published var members: [Member] = [
            .init(id: UUID(), firstName: "Fedoretto", lastName: "Sukhovinskiy-Ivanov-Drago-Tyson")
        ]
        
        func search() {
            membersFetcher = storage.fetch()
                .assign(to: \.members, on: self)
                .filter(with: .init(format: "firstName CONTAINS[cd] %@", pattern), skip: pattern.isEmpty)
                .filter(with: .init(format: "lastName CONTAINS[cd] %@", pattern), type: .or, skip: pattern.isEmpty)
                .run(sort: sort)
        }
        
        func delete(_ member: Member) {
            Task {
                try await storage.delete(member)
            }
        }
    }
}
