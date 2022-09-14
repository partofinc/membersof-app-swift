

import Foundation

public struct Visit: Codable, Hashable, Identifiable {
    
    public let id: UUID
    public let checkInDate: Date
    public let event: Event
    public let member: Member
    public let subscription: Subscription
}
