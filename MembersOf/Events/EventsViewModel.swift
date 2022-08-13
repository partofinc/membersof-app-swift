

import Foundation

extension EventsView {
    
    @MainActor
    final class ViewModel: ObservableObject {
        
        @Published var events: [Event] = []
        
        func create(_ event: Event) {
            events.insert(event, at: 0)
        }
    }
    
    enum Sheet: Identifiable {
        case new
        
        var id: Self { self }
    }
}
