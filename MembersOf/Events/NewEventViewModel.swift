

import Foundation

extension NewEventView {
    
    @MainActor
    final class ViewModel: ObservableObject {
        
        @Published fileprivate(set) var teams: [Team] = [.loading]
        @Published var teamIndex: Int = 0
        
        @Published fileprivate(set) var memberships: [Membership] = []
        @Published fileprivate(set) var selectedMemberships: [UUID] = []
        @Published var name: String = ""
        
        fileprivate let storage: Storage
        fileprivate var teamsFetcher: Storage.Fetcher<Team>?
        fileprivate var membershipsFetcher: Storage.Fetcher<Membership>?
        
        init() {
            storage = .shared
            teamsFetcher = storage.fetch()
                .assign(to: \.teams, on: self)
                .run(sort: [.init(\.createDate)])
        }
        
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
        
        func teamChanged() {
            membershipsFetcher = storage.fetch()
                .assign(to: \.memberships, on: self)
                .filter(by: {$0.team.id == self.teams[self.teamIndex].id})
                .run(sort: [.init(\.createDate)])
            selectedMemberships.removeAll()
        }
        
        func create() {
            Task {
                try await self.storage.save(
                    Event(
                        id: UUID(),
                        name: name,
                        createDate: .now,
                        startDate: nil,
                        endDate: nil,
                        team: teams[teamIndex],
                        memberships: self.memberships.filter({self.selectedMemberships.contains($0.id)})
                    )
                )
            }
        }
    }
}
