

import Foundation
import Combine

extension NewMembershipView {
    
    @MainActor
    final class ViewModel: ObservableObject {
        
        @Published var name: String = ""
        @Published var autoName: String = "Unlimited"
        
        @Published var clubTag: Int = 0
        let clubs: [Team] = Mock.teams
        
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
        
        func create() -> Membership {
            .init(id: UUID(), name: name, clubId: clubs[clubTag].id, visits: visits, period: period, length: length)
        }
    }
}

