

import Foundation

public struct Payment: Codable, Hashable, Identifiable {
    
    public let id: UUID
    public let currency: String
    public let amount: Decimal
    public let date: Date
    public let debt: Debt?
}
