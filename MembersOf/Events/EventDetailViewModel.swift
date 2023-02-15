

import Foundation
import Combine
import Models

extension EventDetailView {
    
    @MainActor
    final class ViewModel: ObservableObject {
        
        @Published var visits: [Visit] = []
        @Published var progress: Progress = .upcoming
        @Published var duration: String = ""
        @Published var event: Event
        
        let signer: Signer
        let storage: Storage
        
        private var subscriptions: Set<AnyCancellable> = []
        private let calendar: Calendar = .current
        
        init(event: Event, signer: Signer) {
            self.event = event
            self.signer = signer
            self.storage = signer.storage
            calculateProgress()
            calculateDuration()
            
            storage.fetch(Visit.self)
                .sort(by: [.init(\.checkInDate, order: .reverse)])
                .filter(by: \.event.id == event.id)
                .catch{ _ in Just([])}
                .assign(to: \.visits, on: self)
                .store(in: &subscriptions)
            
            storage.fetch(Event.self)
                .first(where: \.id == event.id)
                .assign(to: \.event, on: self)
                .store(in: &subscriptions)
        }
        
        var startDate: String {
            let start = event.startDate
            let time = start.formatted(.dateTime.hour().minute())
            guard calendar.isDateInToday(start) else {
                return start.formatted(.relative(presentation: .named)) + " " + time
            }
            return time
        }
        
        func end(with date: Date) {
            
        }
        
        func delete(_ visit: Visit) {
            Task {
                try await storage.delete(visit)
            }
        }
        
        private func calculateProgress() {

        }
        
        private func calculateDuration() {
//            let now: Date = .now
//            var end: Date = event.endDate ?? now
//            let start: Date = event.startDate
//
//            if now < start, let estimate = event.estimatedEndDate {
//                end = estimate
//            }
//            guard end > start else {
//                duration = ""
//                return
//            }
//            duration = (start..<end).formatted(.components(style: .condensedAbbreviated, fields: [.hour, .minute]))
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
