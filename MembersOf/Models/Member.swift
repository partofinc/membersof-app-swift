

import Foundation

public struct Member: Codable, Hashable, Identifiable {
    
    public let id: UUID
    public let firstName: String
    public let lastName: String?
}

public extension Member {
    
    var fullName: String {
        if let lastName {
            return firstName + " " + lastName
        }
        return firstName
    }
}
