

import Foundation

extension EventDetailView {
    
    @MainActor
    final class ViewModel: ObservableObject {
        
        let event: Event
        fileprivate let storage: Storage = .shared
        fileprivate var visitsFetcher: Storage.Fetcher<Event.Visit>?
        fileprivate var sort: [NSSortDescriptor] = [
            .init(keyPath: \Event.Visit.Entity.checkInDate, ascending: false)
        ]
        @Published var visits: [Event.Visit] = []
        
        init(event: Event) {
            self.event = event
            visitsFetcher = storage.fetch()
                .assign(to: \.visits, on: self)
                .filter(with: NSPredicate(format: "event.id == %@", event.id.uuidString))
                .run(sort: sort)
        }
        
//        func checkIn(_ member: Member) {
//            visits.insert(.init(id: UUID(), member: member, checkInDate: Date(), eventId: event.id), at: 0)
//        }
        
        func delete(_ visit: Event.Visit) {
            Task {
                try await storage.delete(visit)
            }
        }
    }
    
    enum Sheet: Identifiable {
        case addMember
        
        var id: Self { self }
    }
}
