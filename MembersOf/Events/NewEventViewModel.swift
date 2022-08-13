

import Foundation

extension NewEventView {
    
    @MainActor
    final class ViewModel: ObservableObject {
        
        let teams: [Team] = Mock.teams
        
        @Published var teamIndex: Int = 0
        @Published var memberships: [Membership] = [
            .init(id: UUID(), name: "ONE time", clubId: UUID(), visits: 1, period: .unlimited, length: 0),
            .init(id: UUID(), name: "Monthly (12 visits)", clubId: UUID(), visits: 12, period: .month, length: 1),
            .init(id: UUID(), name: "Monthly (Unlimited)", clubId: UUID(), visits: 0, period: .month, length: 1)
        ]
        @Published var selectedMemberships: [UUID] = []
        @Published var name: String = ""
        
        func isSelected(_ membership: Membership) -> Bool {
            selectedMemberships.contains(membership.id)
        }
        
        func toggle(_ membership: Membership) {
            if let idx = selectedMemberships.firstIndex(of: membership.id) {
                selectedMemberships.remove(at: idx)
            } else {
                selectedMemberships.append(membership.id)
            }
        }
        
        func selectMemberships() {
            selectedMemberships = memberships.map(\.id)
        }
        
        func deselectMemberships() {
            selectedMemberships.removeAll()
        }
        
        func create() -> Event {
            .init(id: UUID(), name: name, startDate: nil, endDate: nil, visits: [])
        }
    }
}
