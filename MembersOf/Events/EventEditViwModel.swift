//
//  EventEditViwModel.swift
//  MembersOf
//
//  Created by Ravil Khusainov on 9/27/22.
//

import Foundation
import Combine
import Models

extension EventEditView {
    
    @MainActor
    final class ViewModel: ObservableObject {
        
        let event: Event
        
        @Published var name: String
        @Published var startDate: Date
        @Published var memberships: [Membership]
        @Published var finished: Bool
        @Published var selectedShips: [UUID]
                
        let storage: Storage
        private var subs: Set<AnyCancellable> = []
        
        init(event: Event, storage: Storage) {
            self.storage = storage
            self.event = event
            self.name = event.name
            self.startDate = event.startDate
            self.memberships = event.memberships
            self.selectedShips = event.memberships.map(\.id)
            self.finished = event.finished
            
            storage.fetch(Membership.self)
                .filter(by: {$0.team.id == event.team.id})
                .sort(by: [.init(\.createDate)])
                .catch{ _ in Just([])}
                .assign(to: \.memberships, on: self)
                .store(in: &subs)
        }
        
        func toggle(_ ship: Membership) {
            Task {
                if let idx = selectedShips.firstIndex(of: ship.id) {
                    selectedShips.remove(at: idx)
                } else {
                    selectedShips.append(ship.id)
                }
            }
        }
        
        func isSelected(_ ship: Membership) -> Bool {
            selectedShips.contains(ship.id)
        }
        
        func save() {
            let new: Event = .init(
                id: event.id,
                name: name,
                createDate: event.createDate,
                startDate: startDate,
                duration: 90.minutes.timeInterval,
                finished: finished,
                team: event.team,
                memberships: memberships.filter({selectedShips.contains($0.id)})
            )
            guard new != event else { return }
            Task {
                try await storage.save(new)
            }
        }
    }
    
    enum Sheet: Identifiable {
        case addMembership
        
        var id: Self { self }
    }
}
