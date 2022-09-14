

import Foundation

public struct Debt: Codable, Hashable, Identifiable {
    
    public let id: UUID
    public let currency: String
    public let amount: Decimal
}
