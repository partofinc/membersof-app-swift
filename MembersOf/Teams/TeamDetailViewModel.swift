

import Foundation
import Combine
import Models

extension TeamDetailView {
    
    @MainActor
    final class ViewModel: ObservableObject {
        
        @Published var invites: [Invite] = []
        
        let team: Team
        let storage: Storage
        
        init(_ team: Team, storage: Storage) {
            self.storage = storage
            self.team = team
        }
    }
}
