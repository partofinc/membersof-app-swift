
import Foundation
import Combine
import Models

final class AppSigner: ObservableObject, Signer {
                
    let me: CurrentValueSubject<Member, Never> = .init(.local)
    var signedIn: Bool {
        userId != nil
    }
    
    let storage: any Storage
    
    @LightStorage(key: .userId)
    private var userId: String?
    
    private var fetcher: CoreDataStorage.Fetcher<Member>?
    
    init(_ storage: some Storage) {
        self.storage = storage
        fetch()
    }
        
    func signIn(_ member: Member) {
        userId = member.id.uuidString
        fetch()
    }
    
    func signOut() {
        userId = nil
        fetcher = nil
        me.send(.local)
    }
    
    private func fetch() {
        guard let userId, let id = UUID(uuidString: userId) else { return }
        fetcher = storage.fetch()
            .filter(by: {$0.id == id})
            .sink(receiveValue: { [unowned self] users in
                if let first = users.first {
                    self.me.send(first)
                }
            })
            .run(sort: [.init(\.firstName)])
    }
}

extension Signer {
    
    static var app: AppSigner {
        .init(CoreDataStorage("CoreModel"))
    }
}
