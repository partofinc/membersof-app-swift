
import Foundation

public struct Event: Codable, Hashable, Identifiable {
    
    public let id: UUID
    public let name: String
    public let team: Team
    public let startedAt: Date?
    public let endedAt: Date?
    public let visits: [Visit]
}

public extension Event {
    
    struct Visit: Codable, Hashable, Identifiable {
        
        public let id: UUID
        public let member: Member
        public let checkedIn: Date
        public let eventId: UUID
    }
}
