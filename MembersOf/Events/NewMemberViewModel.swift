//
//  NewMemberViewModel.swift
//  MembersOf
//
//  Created by Ravil Khusainov on 8/9/22.
//

import Foundation

extension NewMemberView {
    
    @MainActor
    final class ViewModel: ObservableObject {
        
        let team: Team
        let event: Event
        
        @Published var firstName: String = ""
        @Published var lastName: String = ""
        @Published var membership: Membership?
        @Published var memberships: [Membership] = []
        @Published var starting: Date = .now
        @Published var visits: Int = 0
        @Published var payment: String = ""
        
        fileprivate let storage: Storage = .shared
        fileprivate var membershipsFetcher: Storage.Fetcher<Membership>?
        
        init(team: Team, event: Event) {
            self.team = team
            self.event = event
            membershipsFetcher = storage.fetch()
                .assign(to: \.memberships, on: self)
                .filter(by: {$0.team.id == team.id})
                .run(sort: [.init(\.createDate, order: .reverse)])
        }
        
        var title: String {
            firstName.isEmpty ? "New" : firstName
        }
        
        var canConfirm: Bool {
            !firstName.isEmpty && !lastName.isEmpty && membership != nil
        }
        
        func create() {
            Task {
                let member = Member(id: UUID(), firstName: firstName, lastName: lastName)
                let visit = Visit(id: UUID(), member: member, checkInDate: .now, eventId: event.id)
                try await storage.save(visit)
            }
        }
        
        func select(_ ship: Membership) {
            membership = ship
            visits = ship.visits
            starting = .now
        }
    
        func isSelected(_ ship: Membership) -> Bool {
            guard let membership else { return false }
            return ship.id == membership.id
        }
    }
}
