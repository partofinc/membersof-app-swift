

import Foundation

extension EventDetailView {
    
    @MainActor
    final class ViewModel: ObservableObject {
        
        let event: Event
        @Published var visits: [Event.Visit] = []
        
        init(event: Event) {
            self.event = event
        }
        
        func checkIn(_ member: Member) {
            visits.insert(.init(id: UUID(), member: member, checkedIn: Date(), eventId: event.id), at: 0)
        }
        
        func checkOut(_ member: Member) {
            visits.removeAll(where: {$0.member.id == member.id})
        }
    }
    
    enum Sheet: Identifiable {
        case addMember
        
        var id: Self { self }
    }
}
