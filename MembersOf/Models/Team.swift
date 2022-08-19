

import Foundation

public struct Team: Codable, Hashable, Identifiable {
    
    public let id: UUID
    public let name: String
    public let brief: String
    public let createDate: Date
    public let social: [Social]
    public let crew: [Supervisor]
}

extension Team {
    static var loading: Self {
        .init(id: UUID(), name: "Loading...", brief: "", createDate: .now, social: [], crew: [])
    }
}


