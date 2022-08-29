//
//  NewSupervisorViewModel.swift
//  MembersOf
//
//  Created by Ravil Khusainov on 8/26/22.
//

import Foundation

extension NewSupervisorView {
    
    @MainActor
    final class ViewModel: ObservableObject {
        
        let team: Team
        
        @Published var name: String = ""
        @Published var role: Supervisor.Role = .admin
        @Published var roles: [Supervisor.Role] = .all
        var url: URL {
            .init(string: "https://partof.team/invite/\(id.uuidString)")!
        }
        
        private let id: UUID = .init()
        private let storage: Storage = .shared
        
        init(_ team: Team) {
            self.team = team
        }
        
        func save() {
            Task {
                let invite = Invite(id: id, createDate: .now, name: name.isEmpty ? nil : name, role: role, teamId: team.id)
                try await self.storage.save(invite)
            }
        }
    }
}
