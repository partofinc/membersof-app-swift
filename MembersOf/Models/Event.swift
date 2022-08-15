
import Foundation

public struct Event: Codable, Hashable, Identifiable {
    
    public let id: UUID
    public let name: String
    public let createDate: Date
    public let startDate: Date?
    public let endDate: Date?
//    public let visits: [Visit] = []
}

public extension Event {
    
    struct Visit: Codable, Hashable, Identifiable {
        
        public let id: UUID
        public let member: Member
        public let checkInDate: Date
        public let eventId: UUID
    }
}
