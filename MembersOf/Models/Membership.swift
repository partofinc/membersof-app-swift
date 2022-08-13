
import Foundation


public struct Membership: Codable, Hashable, Equatable, Identifiable {
    
    public let id: UUID
    public let name: String
    public let clubId: UUID
    public let visits: Int
    public let period: Period
    public let length: Int
}


public extension Membership {
    
    enum Period: String, Codable, Hashable, Identifiable {
        
        case unlimited
        case day
        case week
        case month
        case year
        
        public var id: Self { self }
    }
}

