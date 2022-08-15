

import Foundation

public struct Social: Codable, Hashable, Identifiable {
    
    public let id: UUID
    public let media: Media
    public let account: String
}

public extension Social {
    
    enum Media: String, Codable, Hashable, Identifiable {
        
        case instagram
        case telegram
        case twitter
        case facebook
        
        public var id: Self { self }
    }
}

extension Array where Element == Social.Media {
    static var all: [Element] {
        [
            .instagram,
            .telegram,
            .twitter,
            .facebook
        ]
    }
}
