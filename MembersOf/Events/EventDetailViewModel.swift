

import Foundation
import SwiftDate

extension EventDetailView {
    
    @MainActor
    final class ViewModel: ObservableObject {
        
        let event: Event
        
        @Published var visits: [Visit] = []
        @Published var progress: Progress = .upcoming
        @Published var duration: String = ""
        
        private let storage: Storage = .shared
        private var visitsFetcher: Storage.Fetcher<Visit>?
        private var sort: [SortDescriptor<Visit.Entity>] = [
            .init(\.checkInDate, order: .reverse)
        ]
        
        init(event: Event) {
            self.event = event
            calculateProgress()
            calculateDuration()
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
        
        var endDateString: String {
            let end = event.endDate ?? event.estimatedEndDate
            guard let date = end else { return "-" }
            return date.formatted(.dateTime.hour().minute())
        }
        
        func end(with date: Date) {
            
        }
        
        func delete(_ visit: Visit) {
            Task {
                try await storage.delete(visit)
            }
        }
        
        private func calculateProgress() {
            if event.endDate != nil {
                progress = .ended
            } else {
                if event.startDate > .now {
                    progress = .upcoming
                } else {
                    progress = .ongoing
                }
            }
        }
        
        private func calculateDuration() {
            let endDate: Date
            if let end = event.endDate {
                endDate = end
            } else if event.startDate < .now {
                endDate = .now
            } else if let end = event.estimatedEndDate {
                endDate = end
            } else {
                duration = ""
                return
            }
            let components = endDate - event.startDate
            #warning("Formatter needs to bee applied")
            duration = "30s"
        }
    }
    
    enum Sheet: Identifiable {
        case addMember
        case endDate
        case addMembership
        
        var id: Self { self }
    }
    
    enum Progress: String, Identifiable {
        case upcoming = "Upcoming"
        case ongoing = "Ongoing"
        case ended = "Ended"
        
        var id: Self { self }
    }
}
