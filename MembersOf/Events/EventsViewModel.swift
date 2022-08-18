

import Foundation

extension EventsView {
    
    @MainActor
    final class ViewModel: ObservableObject {
        
        private let storage: Storage = .shared
        private var eventsFetcher: Storage.Fetcher<Event>?
        private let sort: [SortDescriptor<Event.Entity>] = [
            .init(\.createDate, order: .reverse),
            .init(\.startDate, order: .reverse)
        ]
        @Published var events: [Event] = []
        
        init() {
            eventsFetcher = storage.fetch()
                .assign(to: \.events, on: self)
                .run(sort: sort)
        }
        
        func delete(_ event: Event) {
            Task {
                try await self.storage.delete(event)
            }
        }
    }
    
    enum Sheet: Identifiable {
        case new
        
        var id: Self { self }
    }
}
