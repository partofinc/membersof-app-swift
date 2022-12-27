//
//  TeamDetailsEditViewModel.swift
//  MembersOf
//
//  Created by Ravil Khusainov on 2022-12-20.
//

import Foundation
import Combine
import Models

extension TeamDetailsEditView {
    
    @MainActor
    final class ViewModel: ObservableObject {
        
        @Published var name: String
        @Published var brief: String
        @Published var socials: [Social]
        @Published var crew: [Supervisor]
        @Published var invites: [Invite] = []
        
        @Published var socialMedias: [Social.Media]
        @Published var media: Social.Media?
        @Published var account: String = ""
        
        let team: Team
        let storage: Storage
        
        private var cancellers: Set<AnyCancellable> = []
        
        init(_ team: Team, storage: Storage) {
            self.storage = storage
            self.team = team
            self.name = team.name
            self.brief = team.brief
            self.crew = team.crew
            self.socials = team.social
            self.socialMedias = .all
            self.socialMedias.removeAll(where: {socials.map(\.media).contains($0)})
            fetch()
        }
        
        private func fetch() {
            storage.fetch(Social.self)
                .filter(by: {$0.team?.id == self.team.id})
                .sort(by: [.init(\.order)])
                .assign(to: \.socials, on: self)
                .store(in: &cancellers)
            storage.fetch(Supervisor.self)
                .filter(by: {$0.team.id == self.team.id})
                .sort(by: [.init(\.order)])
                .assign(to: \.crew, on: self)
                .store(in: &cancellers)
            storage.fetch(Invite.self)
                .filter(by: {$0.team?.id == self.team.id})
                .sort(by: [.init(\.createDate)])
                .assign(to: \.invites, on: self)
                .store(in: &cancellers)
        }
        
        func update(brief: String) {
            self.brief = brief
        }
        
        func update(name: String) {
            self.name = name
        }
        
        func update(_ supervisor: Supervisor) {
            if let idx = crew.firstIndex(where: {$0.id == supervisor.id}) {
                crew[idx] = supervisor
            }
        }
        
        func delete(_ supervisor: Supervisor) {
            Task {
                try await storage.delete(supervisor)
            }
        }
        
        func delete(_ social: Social) {
            Task {
                try await storage.delete(social)
            }
        }
        
        func deleteTeam() {
            Task {
                try await storage.delete(team)
            }
        }
        
        func addSocial() {
            guard let media, account.count > 2 else { return }
            let order = socials.last?.order ?? 0
            let a = account
            Task {
                try await self.storage.save(Social(id: UUID(), media: media, account: a, order: order + 1, memberId: nil, teamId: team.id))
            }
            socialMedias.removeAll(where: {$0 == media})
            discardSocial()
        }
        
        func discardSocial() {
            media = nil
            account = ""
        }
    }
    
    enum Sheet: Identifiable {
        
        case supervisor(Supervisor)
        case newSupervisor
        
        var id: Int {
            switch self {
            case .supervisor:
                return 2
            case .newSupervisor:
                return 3
            }
        }
    }
}
