

import Foundation
import Combine
import SwiftDate

extension NewEventView {
    
    @MainActor
    final class ViewModelChecker: ObservableObject {
        
        @Published private(set) var teams: [Team] = [.loading]
        @Published var team: Team = .loading
        
        @Published private(set) var memberships: [Membership] = []
        @Published private(set) var selectedMemberships: [UUID] = []
        @Published var name: String = ""
        
        @Published var startDate: Date
        @Published var endDate: Date
        @Published var endDefined: Bool = false
        @Published var durationTitle: String = ""
        @Published var duration: Int = 90*60 //Duration of event in seconds
        @Published var me: Member = .local
        
        private let storage: Storage = .shared
        private let signer: Signer = .shared
        private var teamsFetcher: Storage.Fetcher<Team>?
        private var membershipsFetcher: Storage.Fetcher<Membership>?
        private var memberFetcher: AnyCancellable?
        private let durationFormatter: DateComponentsFormatter = {
            let formatter = DateComponentsFormatter()
            formatter.allowedUnits = [.day, .hour, .minute]
            formatter.zeroFormattingBehavior = .dropAll
            formatter.unitsStyle = .abbreviated
            return formatter
        }()
        
        var canCreate: Bool {
            name.count > 2 && !selectedMemberships.isEmpty
        }
        
        init() {
            let date = Date.now.dateRoundedAt(at: .toCeil5Mins)
            startDate = date
            endDate = date + 90.minutes
            memberFetcher = signer.me
                .eraseToAnyPublisher()
                .sink(receiveValue: { [unowned self] member in
                    self.me = member
                })
            calculateDuration()
            fetchTeams()
        }
        
        deinit {
            print("some")
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
            if !teams.contains(where: {$0.id == team.id}), let team = teams.first {
                self.team = team
            }
            membershipsFetcher = storage.fetch()
                .assign(to: \.memberships, on: self)
                .filter(by: { [unowned self] ship in
                    ship.team.id == self.team.id
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
                        estimatedEndDate: endDefined ? endDate : nil,
                        endDate: nil,
                        team: team,
                        memberships: self.memberships.filter({self.selectedMemberships.contains($0.id)})
                    )
                )
            }
        }
        
        func calculateDuration(offset: Int = 0) {
            let d = endDate - startDate
            durationTitle = durationFormatter.string(from: d + offset.seconds)!
        }
        
        func startChanged(date: Date) {
            endDate = date + duration.seconds
        }
        
        func endChanged(date: Date) {
            duration = Int((date - startDate).timeInterval)
            calculateDuration(offset: 1)
        }
        
        func durationChanged() {
            endDate = startDate + duration.seconds
            calculateDuration()
        }
        
        func fetchTeams() {
            teamsFetcher = storage.fetch()
                .filter(by: { [unowned self] team in
                    team.isAccessable(by: me)
                })
                .sink { [unowned self] teams in
                    self.teams = teams
                }
//                .assign(to: \.teams, on: self)
                .run(sort: [.init(\.createDate)])
        }
    }
}
