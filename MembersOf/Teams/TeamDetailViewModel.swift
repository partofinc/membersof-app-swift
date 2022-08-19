

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
        
        @Published var socialMedias: [Social.Media]
        @Published var media: Social.Media?
        @Published var account: String = ""
        
        fileprivate let storage: Storage
        fileprivate var socialFetcher: Storage.Fetcher<Social>?
        fileprivate var crewFetcher: Storage.Fetcher<Supervisor>?
        
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
                .filter(by: \.team!.id, value: team.id)
                .assign(to: \.socials, on: self)
                .run(sort: [.init(\.order, order: .reverse)])
            crewFetcher = storage.fetch()
                .filter(by: \.team.id, value: team.id)
                .assign(to: \.crew, on: self)
                .run(sort: [.init(\.order)])
        }
        
        func update(_ brief: String) {
            self.brief = brief
        }
        
        func update(_ supervisor: Supervisor) {
            if let idx = crew.firstIndex(where: {$0.id == supervisor.id}) {
                crew[idx] = supervisor
            }
        }
        
        func delete(_ supervisor: Supervisor) {
            
        }
        
        func delete(_ social: Social) {
            Task {
                try await storage.delete(social)
            }
//            socials.removeAll(where: {$0 == social})
//            socialMedias.insert(social.media, at: 0)
        }
        
        func addSocial() {
            guard let media, account.count > 2 else { return }
            let order = socials.last?.order ?? 0
            let a = account
            Task {
                try await self.storage.save(Social(id: UUID(), media: media, account: a, order: order, memberId: nil, teamId: team.id))
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
        
        case brief
        case supervisor(Supervisor)
        
        var id: Int {
            switch self {
            case .brief:
                return 1
            case .supervisor:
                return 2
            }
        }
    }
}
