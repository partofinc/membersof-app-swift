

import Foundation

extension EventsView {
    
    @MainActor
    final class ViewModel: ObservableObject {
        
        private let storage: Storage = .shared
        private var eventsFetcher: Storage.Fetcher<Event>?
        private let sort: [NSSortDescriptor] = [
            .init(keyPath: \Event.Entity.createDate, ascending: false),
            .init(keyPath: \Event.Entity.startDate, ascending: false)
        ]
        @Published var events: [Event] = []
        
        init() {
            eventsFetcher = storage.fetch()
                .assign(to: \.events, on: self)
                .run(sort: sort)
        }
    }
    
    enum Sheet: Identifiable {
        case new
        
        var id: Self { self }
    }
}
