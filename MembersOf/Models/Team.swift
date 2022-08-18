

import Foundation

public struct Team: Codable, Hashable, Identifiable {
    
    public let id: UUID
    public let name: String
    public let brief: String
    public let createDate: Date
    public let social: [Social]
    public let crew: [Supervisor]
}


