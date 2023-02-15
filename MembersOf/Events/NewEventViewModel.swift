

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
        
        @Published var startDate: Date = .now
        @Published var duration: TimeInterval = 90.minutes.timeInterval
        @Published var me: Member = .local
        
        @Published var startTime: Date = .now
        @Published var endTime: Date = .now.addingTimeInterval(90.minutes.timeInterval)
        var durationRange: Range<Date> {
            startTime..<endTime
        }
        var endTimeRange: PartialRangeFrom<Date> {
            startTime.addingTimeInterval(10.minutes.timeInterval)...
        }
        
        let storage: Storage
        let signer: Signer
        
        private var subs: Set<AnyCancellable> = []
        
        var canCreate: Bool {
            name.count > 2 && !selectedMemberships.isEmpty
        }
        
        init(_ signer: Signer) {
            self.signer = signer
            self.storage = signer.storage
            
            subscribe()
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
            
            $startTime
                .sink { [unowned self] date in
                    endTime = date.addingTimeInterval(duration)
                }
                .store(in: &subs)
            
            $endTime
                .sink { [unowned self] date in
                    duration = (endTime - startTime).timeInterval
                }
                .store(in: &subs)
            
            $startDate
                .sink { [unowned self] date in
                    updateStartTime(with: date)
                }
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
                        startDate: startTime,
                        duration: duration,
                        finished: false,
                        team: team,
                        memberships: self.memberships.filter({self.selectedMemberships.contains($0.id)})
                    )
                )
            }
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
        
        fileprivate func updateStartTime(with date: Date) {
            guard let d = startTime.changing(date: date) else { return }
            startTime = d
            endTime = d.addingTimeInterval(duration)
        }
    }
}
