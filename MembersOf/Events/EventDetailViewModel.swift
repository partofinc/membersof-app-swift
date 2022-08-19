

import Foundation

extension EventDetailView {
    
    @MainActor
    final class ViewModel: ObservableObject {
        
        let event: Event
        private let storage: Storage = .shared
        private var visitsFetcher: Storage.Fetcher<Visit>?
        private var sort: [SortDescriptor<Visit.Entity>] = [
            .init(\.checkInDate, order: .reverse)
        ]
        @Published var visits: [Visit] = []
        
        init(event: Event) {
            self.event = event
            visitsFetcher = storage.fetch()
                .assign(to: \.visits, on: self)
                .filter(by: \.event.id, value: event.id)
                .run(sort: sort)
        }
        
        func delete(_ visit: Visit) {
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
