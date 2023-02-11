

import Foundation
import Combine
import Models

extension VisitorView {
    
    @MainActor
    final class ViewModel: ObservableObject {
        
        let member: Member
        let event: Event
        
        let storage: Storage
        
        private var cancellers: Set<AnyCancellable> = []
        
        @Published var subscription: Models.Subscription?
        
        @Published var starting: Date = .now
        @Published var visits: Int = 0
        @Published var payment: String = ""
        @Published var membership: Membership?
        @Published var memberships: [Membership] = []
        
        init(member: Member, event: Event, storage: Storage) {
            self.member = member
            self.event = event
            self.storage = storage
            
            storage.fetch(Membership.self)
                .filter(by: {$0.team.id == event.team.id})
                .sort(by: [.init(\.createDate, order: .reverse)])
                .catch{_ in Just([])}
                .assign(to: \.memberships, on: self)
                .store(in: &cancellers)

            storage.fetch(Subscription.self)
                .filter(by: {$0.member.id == member.id && $0.membership.team.id == event.team.id})
                .sort(by: [.init(\.startDate)])
                .catch{_ in Just([])}
                .sink { [unowned self] subs in
                    self.subscription = subs.last
                }
                .store(in: &cancellers)
        }
        
        func select(_ ship: Membership) {
            membership = ship
            visits = ship.visits
            starting = .now
        }
    
        func isSelected(_ ship: Membership) -> Bool {
            guard let membership else { return false }
            return ship.id == membership.id
        }
        
        func checkIn() {
//            Task {
//                try await self.storage.save(Visit(id: UUID(), member: member, checkInDate: .now, event: event))
//            }
        }
    }
}
