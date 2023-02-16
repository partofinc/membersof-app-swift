//
//  NewScheduleView+ViewModel.swift
//  MembersOf
//
//  Created by Ravil Khusainov on 2023-02-07.
//

import Foundation
import Combine
import Models
import SwiftDate
import SwiftUI

extension NewScheduleView {
    
    @MainActor
    final class ViewModel: ObservableObject {
        
        let signer: Signer
        let storage: Storage
        
        init(signer: Signer) {
            self.signer = signer
            self.storage = signer.storage
            subscribe()
        }
        
        let days: [String] = Calendar.localized.localizedWeekdaySymbols
        
        @Published var name: String = ""
        @Published var selectedDays: Set<String> = []
        @Published var dates: [String: (Date, Date)] = [:]
        
        @Published var teams: [Team] = [.loading]
        @Published var team: Team = .loading
        @Published var places: [Place] = [.none]
        @Published var place: Place = .none
        
        @Published var memberships: [Membership] = []
        @Published var selectedMemberships: [UUID] = []
        @Published var me: Member = .local
        
        private var subs: Set<AnyCancellable> = []
        private var lastTime: (Date, Date) = (.now, .now + 90.minutes)
        private var lastDuration: TimeInterval = 90.minutes.timeInterval
        
        func subscribe() {
            
            signer.me
                .sink { [unowned self] member in
                    self.me = member
                    self.fetchTeams()
                }
                .store(in: &subs)
            
            $team
                .sink { [unowned self] _ in
                    self.fetchMemberships()
                }
                .store(in: &subs)
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
        
        var canCreate: Bool {
            name.count > 2 && !selectedMemberships.isEmpty && !selectedDays.isEmpty
        }
        
        func create() {
            Task {
                let schedule = Schedule(
                    id: .init(),
                    name: name,
                    team: team,
                    repeats: repeats(),
                    nearestDate: nil,
                    memeberships: memberships.filter({selectedMemberships.contains($0.id)})
                )
                try await storage.save(schedule)
            }
        }
        
        func toggle(_ day: String) {
            if selectedDays.contains(day) {
                selectedDays.remove(day)
                dates.removeValue(forKey: day)
            } else {
                selectedDays.insert(day)
                dates[day] = lastTime
            }
        }
        
        func isSelected(_ day: String) -> Bool {
            selectedDays.contains(day)
        }
        
        func binding(for day: String) -> Binding<(Date, Date)> {
            Binding(
                get: {
                    return self.dates[day] ?? self.lastTime
                },
                set: {
                    var modified = $0
                    if let existing = self.dates[day], existing.0 != modified.0 {
                        modified.1 = modified.0.addingTimeInterval(self.lastDuration)
                    }
                    self.lastDuration = (modified.1 - modified.0).timeInterval
                    self.lastTime = modified
                    self.dates[day] = modified
                }
            )
        }
        
        fileprivate func repeats() -> [Schedule.Repeat] {
            return dates.compactMap { (day, time) -> Schedule.Repeat? in
                guard let weekday = Calendar.localized.indexOfWeek(day: day) else { return nil }
                let start = time.0.timeIntervalSince(Calendar.localized.startOfDay(for: time.0))
                let duration = time.1.timeIntervalSince(time.0)
                return Schedule.Repeat(weekday: weekday, start: start, duration: duration)
            }.sorted(by: \.weekday)
        }
    }
}
