

import Foundation
import Combine
import Models

extension EventsView {
    
    @MainActor
    final class ViewModel: ObservableObject {
        
        @Published private(set) var events: [Event] = []
        @Published private(set) var me: Member = .local
        
        let signer: any Signer
        let storage: any Storage
        
        private var eventsFetcher: CoreDataStorage.Fetcher<Event>?
        private var memberFetcher: AnyCancellable?
        
        private let sort: [SortDescriptor<Event.Entity>] = [
            .init(\.createDate, order: .reverse),
            .init(\.startDate, order: .reverse)
        ]
        
        init(_ signer: some Signer) {
            self.signer = signer
            self.storage = signer.storage
            
            memberFetcher = signer.me
                .sink { [unowned self] member in
                    self.me = member
                    self.fetch()
                }
        }
        
        private func fetch() {
            eventsFetcher = storage.fetch()
                .filter(by: { [unowned self] event in
                    guard let crew = event.team.crew else { return false }
                    return crew.contains(where: {$0.member.id == self.me.id})
                })
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
