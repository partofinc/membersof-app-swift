

import Foundation

public struct Price: Codable, Hashable, Identifiable {
    
    public let id: UUID
    public let currency: String
    public let value: Decimal
}
