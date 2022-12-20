//
//  MembershipDetailViewModel.swift
//  MembersOf
//
//  Created by Ravil Khusainov on 8/23/22.
//

import Foundation
import Models

extension MembershipDetailView {
    
    @MainActor
    final class ViewModel: ObservableObject {
        
        let membership: Membership
        let storage: any Storage
        
        @Published var team: Team = .loading
        
        private var teamFetcher: CoreDataStorage.Fetcher<Team>?
        
        init(_ membership: Membership, storage: some Storage) {
            self.storage = storage
            self.membership = membership
            
            teamFetcher = storage.fetch()
                .filter(by: {$0.id == membership.teamId})
                .sink { [unowned self] teams in
                    guard let t = teams.first else { return }
                    self.team = t
                }
                .run(sort: [.init(\.createDate)])
        }
        
        func delete() {
            Task {
                try await storage.delete(membership)
            }
        }
    }
}
