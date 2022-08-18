

import Foundation
import Combine

extension TeamsView {
    
    @MainActor
    final class ViewModel: ObservableObject {
                
        @Published var teams: [Team] = []
        
        fileprivate let storage: Storage
        fileprivate var teamsFetcher: Storage.Fetcher<Team>?
        
        init(storage: Storage = .shared) {
            self.storage = storage
            teamsFetcher = storage.fetch()
                .assign(to: \.teams, on: self)
                .run(sort: [.init(\.createDate)])
        }
    }
}
