

import Foundation
import Models

extension VisitorView {
    
    @MainActor
    final class ViewModel: ObservableObject {
        
        let member: Member
        let event: Event
        
        fileprivate let storage: Storage = .shared
        fileprivate var membershipsFetcher: Storage.Fetcher<Membership>?
        fileprivate var subscriptionsFetcher: Storage.Fetcher<Subscription>?
        
        @Published var subscription: Subscription?
        
        @Published var starting: Date = .now
        @Published var visits: Int = 0
        @Published var payment: String = ""
        @Published var membership: Membership?
        @Published var memberships: [Membership] = []
        
        init(member: Member, event: Event) {
            self.member = member
            self.event = event
            
            membershipsFetcher = storage.fetch()
                .filter(by: {$0.team.id == event.team.id})
                .assign(to: \.memberships, on: self)
                .run(sort: [.init(\.createDate, order: .reverse)])
            
            subscriptionsFetcher = storage.fetch()
                .filter(with: .init(format: "member.id == %@", member.id.uuidString))
                .filter(with: .init(format: "membership.team.id == %@", event.team.id.uuidString))
                .sink(receiveValue: { [unowned self] subs in
                    self.subscription = subs.last
                })
                .run(sort: [.init(\.startDate)])
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
