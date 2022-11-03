//
//  EventEditViwModel.swift
//  MembersOf
//
//  Created by Ravil Khusainov on 9/27/22.
//

import Foundation

extension EventEditView {
    
    @MainActor
    final class ViewModel: ObservableObject {
        
        let event: Event
        
        @Published var name: String
        @Published var startDate: Date
        var endDate: Date?
        @Published var memberships: [Membership]
        @Published var isEnded: Bool
        @Published var selectedShips: [UUID]
        
        private let storage: Storage = .shared
        private var shipsFetcher: Storage.Fetcher<Membership>?
        
        init(event: Event) {
            self.event = event
            self.name = event.name
            self.startDate = event.startDate
            self.endDate = event.endDate ?? event.estimatedEndDate
            self.memberships = event.memberships
            self.selectedShips = event.memberships.map(\.id)
            self.isEnded = event.endDate != nil
            
            self.shipsFetcher = storage.fetch()
                .filter(with: .init(format: "team.id = %@", event.team.id.uuidString))
                .assign(to: \.memberships, on: self)
                .run(sort: [.init(\.createDate)])
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
                estimatedEndDate: isEnded ? event.estimatedEndDate : endDate,
                endDate: isEnded ? endDate : nil,
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
