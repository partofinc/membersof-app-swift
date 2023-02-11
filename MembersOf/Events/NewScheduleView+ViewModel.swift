//
//  NewScheduleView+ViewModel.swift
//  MembersOf
//
//  Created by Ravil Khusainov on 2023-02-07.
//

import Foundation
import Combine
import Models

extension NewScheduleView {
    
    @MainActor
    final class ViewModel: ObservableObject {
        
        let storage: Storage
        
        init(storage: Storage) {
            self.storage = storage
            subscribe()
        }
        
        let days: [String] = Calendar.localized.localizedWeekdaySymbols
        
        @Published var name: String = ""
        @Published var selectedDays: Set<String> = []
        @Published var dates: [String: (Date, Date)] = [:]
        
        @Published private(set) var teams: [Team] = [.loading]
        @Published var team: Team = .loading
        @Published private(set) var places: [Place] = [.none]
        @Published var place: Place = .none
        
        @Published private(set) var memberships: [Membership] = []
        @Published private(set) var selectedMemberships: [UUID] = []
        
        private var subs: Set<AnyCancellable> = []
        
        private func subscribe() {
            
            storage.fetch(Team.self)
                .sort(by: [.init(\.createDate)])
                .catch({_ in Just([])})
                .assign(to: \.teams, on: self)
                .store(in: &subs)
        }
        
        var canCreate: Bool { false }
        
        func create() {
            
        }
        
        func toggle(_ day: String) {
            if selectedDays.contains(day) {
                selectedDays.remove(day)
                dates.removeValue(forKey: day)
            } else {
                selectedDays.insert(day)
                dates[day] = (.now, .now)
            }
        }
        
        func isSelected(_ day: String) -> Bool {
            selectedDays.contains(day)
        }
    }
}
