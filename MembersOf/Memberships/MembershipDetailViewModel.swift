//
//  MembershipDetailViewModel.swift
//  MembersOf
//
//  Created by Ravil Khusainov on 8/23/22.
//

import Foundation
import Combine
import Models

extension MembershipDetailView {
    
    @MainActor
    final class ViewModel: ObservableObject {
        
        let membership: Membership
        let storage: any Storage
        
        @Published var team: Team = .loading
        
        private var teamCanceller: AnyCancellable?
        
        init(_ membership: Membership, storage: some Storage) {
            self.storage = storage
            self.membership = membership
            
            teamCanceller = storage.fetch(Team.self)
                .filter(by: {$0.id == membership.team.id})
                .sort(by: [.init(\.createDate)])
                .catch{_ in Just([])}
                .sink { [unowned self] teams in
                    guard let t = teams.first else { return }
                    self.team = t
                }
        }
        
        func delete() {
            Task {
                try await storage.delete(membership)
            }
        }
    }
}
