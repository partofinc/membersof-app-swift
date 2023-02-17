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
        private var socialsToDelete: [Social] = []
        
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
                .sort(by: [.init(\.createDate)])
                .catch{_ in Just([])}
                .sink { [unowned self] socials in
                    self.socials = socials.filter{!self.socialsToDelete.contains($0)}
                }
                .store(in: &cancellers)
            
            storage.fetch(Supervisor.self)
                .filter(by: {$0.team.id == self.team.id})
                .sort(by: [.init(\.order)])
                .catch{_ in Just([])}
                .assign(to: \.crew, on: self)
                .store(in: &cancellers)
            
            storage.fetch(Invite.self)
                .filter(by: {$0.team?.id == self.team.id})
                .sort(by: [.init(\.createDate)])
                .catch{_ in Just([])}
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
            if let idx = socials.firstIndex(of: social) {
                socials.remove(at: idx)
            }
            socialsToDelete.append(social)
            socialMedias.insert(social.media, at: 0)
        }
        
        func deleteTeam() {
            Task {
                try await storage.delete(team)
            }
        }
        
        func addSocial() {
            guard let media, account.count > 2 else { return }
            let social = Social(id: UUID(), media: media, account: account, createDate: .now, memberId: nil, teamId: team.id)
            Task {
                try await self.storage.save(social)
            }
            socialMedias.removeAll(where: {$0 == media})
            discardSocial()
        }
        
        func discardSocial() {
            media = nil
            account = ""
        }
        
        func save() {
            Task {
                try await storage.delete(socialsToDelete)
                let team = Team(id: team.id, name: name, brief: brief, createDate: team.createDate, social: socials, crew: crew)
                try await storage.save(team)
            }
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
