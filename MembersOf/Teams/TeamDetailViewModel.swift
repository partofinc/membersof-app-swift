

import Foundation
import Combine

extension TeamDetailView {
    
    @MainActor
    final class ViewModel: ObservableObject {
        
        let team: Team
        
        @Published var name: String
        @Published var brief: String
        @Published var socials: [Social]
        @Published var crew: [Supervisor]
        @Published var invites: [Invite] = []
        
        @Published var socialMedias: [Social.Media]
        @Published var media: Social.Media?
        @Published var account: String = ""
        
        fileprivate let storage: Storage
        fileprivate var socialFetcher: Storage.Fetcher<Social>?
        fileprivate var crewFetcher: Storage.Fetcher<Supervisor>?
        fileprivate var inviteFetcher: Storage.Fetcher<Invite>?
        
        init(team: Team) {
            self.storage = .shared
            self.team = team
            self.name = team.name
            self.brief = team.brief
            self.crew = team.crew
            self.socials = team.social
            self.socialMedias = .all
            self.socialMedias.removeAll(where: {socials.map(\.media).contains($0)})
            socialFetcher = storage.fetch()
//                .filter(by: \.team!.id, value: team.id)
                .assign(to: \.socials, on: self)
                .run(sort: [.init(\.order)])
            crewFetcher = storage.fetch()
                .filter(by: \.team.id, value: team.id)
                .assign(to: \.crew, on: self)
                .run(sort: [.init(\.order)])
            inviteFetcher = storage.fetch()
                .assign(to: \.invites, on: self)
                .run(sort: [.init(\.createDate)])
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
        
        case name
        case brief
        case supervisor(Supervisor)
        case newSupervisor
        
        var id: Int {
            switch self {
            case .name:
                return 0
            case .brief:
                return 1
            case .supervisor:
                return 2
            case .newSupervisor:
                return 3
            }
        }
    }
}
