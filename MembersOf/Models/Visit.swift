

import Foundation

public struct Visit: Codable, Hashable, Identifiable {
    
    public let id: UUID
    public let member: Member
    public let checkInDate: Date
    public let eventId: UUID
}
