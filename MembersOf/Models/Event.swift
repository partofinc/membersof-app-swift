
import Foundation

public struct Event: Codable, Hashable, Identifiable {
    
    public let id: UUID
    public let name: String
    public let createDate: Date
    public let startDate: Date?
    public let endDate: Date?
    public let team: Team
}

