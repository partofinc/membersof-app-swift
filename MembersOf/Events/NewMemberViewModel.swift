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
        let storage: Storage = .shared
        
        @Published var firstName: String = ""
        @Published var lastName: String = ""
        @Published var membership: Membership?
        @Published var memberships: [Membership] = [
            .init(id: UUID(), name: "ONE time", clubId: UUID(), visits: 1, period: .unlimited, length: 0),
            .init(id: UUID(), name: "Monthly (12 visits)", clubId: UUID(), visits: 12, period: .month, length: 1),
            .init(id: UUID(), name: "Monthly (Unlimited)", clubId: UUID(), visits: 0, period: .month, length: 1)
        ]
        @Published var starting: Date = .now
        @Published var visits: Int = 0
        @Published var payment: String = ""
        
        var title: String {
            firstName.isEmpty ? "New" : firstName
        }
        
        init(team: Team) {
            self.team = team
        }
        
        var canConfirm: Bool {
            !firstName.isEmpty && !lastName.isEmpty && membership != nil
        }
        
        func create() {
            let member = Member(id: UUID(), firstName: firstName, lastName: lastName)
            storage.save([member])
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
