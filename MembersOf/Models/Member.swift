

import Foundation

public struct Member: Codable, Hashable, Identifiable {
    
    public let id: UUID
    public let firstName: String
    public let lastName: String?
    
    public static let local: Self = .init(id: .init(uuidString: "CDF48ADE-D35D-421B-8164-7BEBEFF64461")!, firstName: "Me", lastName: nil)
}

public extension Member {
    
    var fullName: String {
        if let lastName {
            return firstName + " " + lastName
        }
        return firstName
    }
}
