

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
        @Published var progress: Progress
        
        init(event: Event) {
            self.event = event
            if event.startDate < .now {
                self.progress = .ongoing
            } else {
                self.progress = .upcoming
            }
            visitsFetcher = storage.fetch()
                .assign(to: \.visits, on: self)
                .filter(by: {$0.event.id == event.id})
                .run(sort: sort)
        }
        
        var startDate: String {
            if Calendar.current.isDateInToday(event.startDate) {
                return event.startDate.formatted(.dateTime.hour().minute())
            }
            return event.startDate.formatted(.dateTime)
        }
        
        func end(with date: Date) {
            
        }
        
        func delete(_ visit: Visit) {
            Task {
                try await storage.delete(visit)
            }
        }
    }
    
    enum Sheet: Identifiable {
        case addMember
        case endDate
        
        var id: Self { self }
    }
    
    enum Progress: String, Identifiable {
        case upcoming = "Upcoming"
        case ongoing = "Ongoing"
        case ended = "Ended"
        
        var id: Self { self }
    }
}
