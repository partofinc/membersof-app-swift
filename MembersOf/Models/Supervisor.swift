

import Foundation

public struct Supervisor: Codable, Hashable, Identifiable {
    
    public let id: UUID
    public let role: Role
    public let order: Int
    public let member: Member
    public let teamId: UUID?
}

public extension Supervisor {
    
    enum Role: String, Codable, Hashable, Identifiable, CaseIterable {
        
        case owner
        case admin
        case manager
        
        public var id: Self { self }
    }
}
