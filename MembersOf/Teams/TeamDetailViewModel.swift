

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
        @Published var newMedia: Social.Media?
        @Published var newAccount: String = ""
        
        init(team: Team) {
            self.team = team
            self.name = team.name
            self.brief = team.brief
            self.crew = team.crew
            self.socials = team.social
            self.socialMedias = .all
            
            self.socialMedias.removeAll(where: {socials.map(\.media).contains($0)})
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
            socials.removeAll(where: {$0 == social})
            socialMedias.insert(social.media, at: 0)
        }
        
        func addSocial() {
            guard let newMedia, newAccount.count > 2 else { return }
            socials.append(.init(id: UUID(), media: newMedia, account: newAccount))
            socialMedias.removeAll(where: {$0 == newMedia})
            discardSocial()
        }
        
        func discardSocial() {
            newMedia = nil
            newAccount = ""
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
