

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
        private let calendar: Calendar = .current
        
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
            let start = event.startDate
            let time = start.formatted(.dateTime.hour().minute())
            guard calendar.isDateInToday(start) else {
                return start.formatted(.relative(presentation: .named)) + " " + time
            }
            return time
        }
        
        var endDate: String {
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
            let now: Date = .now
            var end: Date = event.endDate ?? now
            let start: Date = event.startDate
            
            if now < start, let estimate = event.estimatedEndDate {
                end = estimate
            }
            guard end > start else {
                duration = ""
                return
            }
            duration = (start..<end).formatted(.components(style: .condensedAbbreviated, fields: [.hour, .minute]))
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
