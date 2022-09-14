

import Foundation
import Combine

extension NewEventView {
    
    @MainActor
    final class ViewModel: ObservableObject {
        
        @Published private(set) var teams: [Team] = [.loading]
        @Published var teamIndex: Int = 0
        
        @Published private(set) var memberships: [Membership] = []
        @Published private(set) var selectedMemberships: [UUID] = []
        @Published var name: String = ""
        
        @Published var startDate: Date = .now
        @Published var endDate: Date = .now.addingTimeInterval(2000000)
        @Published var endDefined: Bool = false
        @Published var durationTitle: String = ""
        @Published var duration: Double = 1.0
        @Published var me: Member = .local {
            didSet {
                fetch()
            }
        }
        
        private let storage: Storage = .shared
        private let signer: Signer = .shared
        private var teamsFetcher: Storage.Fetcher<Team>?
        private var membershipsFetcher: Storage.Fetcher<Membership>?
        private var memberFetcher: AnyCancellable?
        
        var canCreate: Bool {
            name.count > 2 && !selectedMemberships.isEmpty
        }
        
        var selectedTeam: Team? {
            teams.isEmpty ? nil : teams[teamIndex]
        }
        
        init() {
            memberFetcher = signer.me
                .eraseToAnyPublisher()
                .assign(to: \.me, on: self)
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
                .filter(by: { [unowned self] ship in
                    ship.team.id == self.teams[self.teamIndex].id
                })
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
                        startDate: startDate,
                        endDate: endDefined ? endDate : nil,
                        team: teams[teamIndex],
                        memberships: self.memberships.filter({self.selectedMemberships.contains($0.id)})
                    )
                )
            }
        }
        
        func calculateDuration() {
            
        }
        
        private func fetch() {
            teamsFetcher = storage.fetch()
                .filter(by: { [unowned self] team in
                    team.accessable(by: me)
                })
                .assign(to: \.teams, on: self)
                .run(sort: [.init(\.createDate)])
        }
    }
}
