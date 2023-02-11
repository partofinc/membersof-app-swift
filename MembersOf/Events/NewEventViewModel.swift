

import Foundation
import Combine
import SwiftDate
import Models

extension NewEventView {
    
    @MainActor
    final class ViewModel: ObservableObject {
        
        @Published private(set) var teams: [Team] = [.loading]
        @Published var team: Team = .loading
        @Published var schedule: Schedule = .none
        @Published private(set) var scheduled: [Schedule] = []
        @Published private(set) var places: [Place] = [.none]
        @Published var place: Place = .none
        
        @Published private(set) var memberships: [Membership] = []
        @Published private(set) var selectedMemberships: [UUID] = []
        @Published var name: String = ""
        
        @Published var startDate: Date
        @Published var endDate: Date
        @Published var endDefined: Bool = false
        @Published var durationTitle: String = ""
        @Published var duration: Int = 90*60 //Duration of event in seconds
        @Published var me: Member = .local
        
        let storage: Storage
        let signer: Signer
        
        private var subs: Set<AnyCancellable> = []
        
        var canCreate: Bool {
            name.count > 2 && !selectedMemberships.isEmpty
        }
        
        init(_ signer: Signer) {
            self.signer = signer
            self.storage = signer.storage
            
            let date = Date.now.dateRoundedAt(at: .toCeil5Mins)
            startDate = date
            endDate = date + 90.minutes
            
            subscribe()
            
            calculateDuration()
            fetchTeams()
        }
        
        func subscribe() {
            
            signer.me
                .sink { [unowned self] member in
                    self.me = member
                    self.fetchTeams()
                }
                .store(in: &subs)
            
            $schedule
                .sink { [unowned self] sched in
                    if sched == .none {
                        name = ""
                    } else {
                        name = sched.name
                        if let date = sched.nearestDate {
                            startDate = date
                        }
                    }
                }
                .store(in: &subs)
            
            $team
                .sink { [unowned self] _ in
                    self.fetchMemberships()
                }
                .store(in: &subs)
            
            storage.fetch(Schedule.self)
                .sort(by: [.init(\.name)])
                .catch({_ in Just([])})
                .map{ [Schedule.none] + $0 }
                .assign(to: \.scheduled, on: self)
                .store(in: &subs)
        }
        
        func isSelected(_ membership: Membership) -> Bool {
            selectedMemberships.contains(membership.id)
        }
        
        func toggle(_ membership: Membership) {
            Task {
                if let idx = selectedMemberships.firstIndex(of: membership.id) {
                    selectedMemberships.remove(at: idx)
                } else {
                    selectedMemberships.append(membership.id)
                }
            }
        }
        
        func selectMemberships() {
            selectedMemberships = memberships.map(\.id)
        }
        
        func deselectMemberships() {
            selectedMemberships.removeAll()
        }
        
        func fetchMemberships() {
            storage.fetch(Membership.self)
                .filter(by: { [unowned self] ship in
                    ship.team.id == self.team.id
                })
                .sort(by: [.init(\.createDate)])
                .catch{_ in Just([])}
                .assign(to: \.memberships, on: self)
                .store(in: &subs)
                
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
            durationTitle = (startDate..<endDate).formatted(.components(style: .condensedAbbreviated))
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
            storage.fetch(Team.self)
                .filter(by: { [unowned self] team in
                    team.isAccessable(by: me)
                })
                .sort(by: [.init(\.createDate, order: .reverse)])
                .catch{_ in Just([])}
                .sink { [unowned self] teams in
                    if !teams.contains(self.team), let first = teams.first {
                        self.team = first
                        self.fetchMemberships()
                    }
                    self.teams = teams
                }
                .store(in: &subs)
        }
    }
}
