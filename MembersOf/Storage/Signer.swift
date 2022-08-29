
import Foundation
import Combine

final class Signer {
    
    static let shared = Signer()
    
    let me: CurrentValueSubject<Member, Never> = .init(.local)
    private let storage: Storage = .shared
    
    var signedIn: Bool {
        userId != nil
    }
    
    @LightStorage(key: .userId)
    private var userId: String?
    
    private var fetcher: Storage.Fetcher<Member>?
    
    private init() {
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
        guard let userId else { return }
        fetcher = storage.fetch()
            .filter(by: \.id, value: .init(uuidString: userId)!)
            .sink(receiveValue: { [unowned self] users in
                if let first = users.first {
                    self.me.send(first)
                }
            })
            .run(sort: [.init(\.firstName)])
    }
}
