//
//  SearchMembersViewModel.swift
//  MembersOf
//
//  Created by Ravil Khusainov on 8/9/22.
//

import Foundation
import Combine
import Models

extension SearchMembersView {
    
    @MainActor
    final class ViewModel: ObservableObject {
        
        let event: Event
        private let storage: Storage = .shared
        private var membersFetcher: Storage.Fetcher<Member>?
        private var sort: [SortDescriptor<Member.Entity>] = [.init(\.firstName)]
        
        init(_ event: Event) {
            self.event = event
            search()
        }
        
        @Published var pattern: String = ""
        @Published var members: [Member] = []
        
        func search() {
            guard !pattern.isEmpty else {
                members = []
                return
            }
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
