

import Foundation
import Combine

extension TeamsView {
    
    @MainActor
    final class ViewModel: ObservableObject {
        
        @Published var creatingNew: Bool = false
        
        @Published var teams: [Team] = Mock.teams
        
        
        func add(_ team: Team) {
            creatingNew = false
            teams.insert(team, at: 0)
        }
    }
}
