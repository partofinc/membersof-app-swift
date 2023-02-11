

import Foundation
import Combine
import Models

extension TeamsView {
    
    @MainActor
    final class ViewModel: ObservableObject {
                
        @Published private(set) var teams: [Team] = []
        @Published private(set) var me: Member = .local
        
        let storage: Storage
        let signer: Signer
        
        private var cancellers: Set<AnyCancellable> = []
        
        init(_ signer: Signer) {
            self.signer = signer
            self.storage = signer.storage
            
            signer.me
                .sink { [unowned self] member in
                    self.me = member
                    self.fetchTeams()
                }
                .store(in: &cancellers)
        }
        
        private func fetchTeams() {
            storage.fetch(Team.self)
                .filter(by: { [unowned self] team in
                    team.isAccessable(by: me)
                })
                .sort(by: [.init(\.createDate, order: .reverse)])
                .catch{_ in Just([])}
                .assign(to: \.teams, on: self)
                .store(in: &cancellers)
        }
    }
}
