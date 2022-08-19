

import Foundation
import Combine

extension NewMembershipView {
    
    @MainActor
    final class ViewModel: ObservableObject {
        
        @Published var name: String = ""
        @Published var autoName: String = "Unlimited"
        
        @Published var teamIdx: Int = 0
        @Published var teams: [Team] = [
            .init(id: UUID(), name: "Loading...", brief: "", createDate: .now, social: [], crew: [])
        ]
        
        @Published var period: Membership.Period = .unlimited
        let periods: [Membership.Period] = [
            .unlimited,
            .day,
            .week,
            .month,
            .year
        ]
        
        @Published var length: Int = 1
        @Published var periodText: String?
        
        @Published var visits: Int = 0
        @Published var visitsText: String = "Unlimited visits"
        
        @Published var price: String = ""
        
        private let storage: Storage
        private var teamsFetcher: Storage.Fetcher<Team>?
        
        init() {
            storage = .shared
            teamsFetcher = storage.fetch()
                .assign(to: \.teams, on: self)
                .run(sort: [.init(\.createDate, order: .reverse)])
        }
        
        func calculatePeriod() {
            guard period != .unlimited else {
                periodText = nil
                length = 1
                return
            }
            periodText = "\(length) " + period.rawValue.capitalized
        }
        
        func calculateVisits() {
            guard visits != 0 else {
                visitsText = "Unlimited visits"
                return
            }
            visitsText = "\(visits) Visits"
        }
        
        func create() {
            Task {
                let membership = Membership(
                    id: UUID(),
                    name: name,
                    visits: visits,
                    period: period,
                    length: length,
                    createDate: .now,
                    teamId: teams[teamIdx].id
                )
                try await self.storage.save(membership)
            }
        }
    }
}

