

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
        
        private var teamsFetcher: CoreDataStorage.Fetcher<Team>?
        private var userFetcher: AnyCancellable?
        
        init(_ signer: Signer) {
            self.signer = signer
            self.storage = signer.storage
            
            userFetcher = signer.me
                .sink { [unowned self] member in
                    self.me = member
                    self.fetchTeams()
                }
        }
        
        private func fetchTeams() {
            teamsFetcher = storage.fetch()
                .assign(to: \.teams, on: self)
                .filter(by: { [unowned self] team in
                    team.isAccessable(by: me)
                })
                .run(sort: [.init(\.createDate, order: .reverse)])
        }
    }
}
