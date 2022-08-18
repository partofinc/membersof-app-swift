

import Foundation

extension EventDetailView {
    
    @MainActor
    final class ViewModel: ObservableObject {
        
        let event: Event
        fileprivate let storage: Storage = .shared
        fileprivate var visitsFetcher: Storage.Fetcher<Event.Visit>?
        fileprivate var sort: [SortDescriptor<Event.Visit.Entity>] = [
            .init(\.checkInDate, order: .reverse)
        ]
        @Published var visits: [Event.Visit] = []
        
        init(event: Event) {
            self.event = event
            visitsFetcher = storage.fetch()
                .assign(to: \.visits, on: self)
                .filter(by: \.event!.id!, value: event.id)
                .run(sort: sort)
        }
        
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
