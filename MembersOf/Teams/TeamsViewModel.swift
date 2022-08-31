

import Foundation
import Combine

extension TeamsView {
    
    @MainActor
    final class ViewModel: ObservableObject {
                
        @Published private(set) var teams: [Team] = []
        @Published private(set) var me: Member = .local
        
        private let storage: Storage = .shared
        private let signer: Signer = .shared
        private var teamsFetcher: Storage.Fetcher<Team>?
        private var userFetcher: AnyCancellable?
        
        init() {
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
                    guard let crew = team.crew else { return false }
                    return crew.contains(where: {$0.member.id == self.me.id})
                })
                .run(sort: [.init(\.createDate, order: .reverse)])
        }
    }
}
