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
        let storage: Storage
        
        private var cancellers: Set<AnyCancellable> = []
        
        init(_ event: Event, storage: Storage) {
            self.storage = storage
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
            storage.fetch(Member.self)
                .filter(by: \.fullName ~~ pattern)//{$0.name(contains: self.pattern)}
                .sort(by:  [.init(\.firstName)])
                .catch{_ in Just([])}
                .assign(to: \.members, on: self)
                .store(in: &cancellers)
        }
        
        func delete(_ member: Member) {
            Task {
                try await storage.delete(member)
            }
        }
    }
}

extension Member.Entity {
    func name(contains pattern: String) -> Bool {
        let normal = pattern.lowercased()
        let last = lastName ?? ""
        return firstName.lowercased().contains(normal) || last.lowercased().contains(normal)
    }
}
