//
//  Subscription.swift
//  MembersOf
//
//  Created by Ravil Khusainov on 8/10/22.
//

import Foundation

public struct Subscription: Codable, Hashable, Identifiable {
    
    public let id: UUID
    public let member: Member
    public let membership: Membership
    public let startedAt: Date
    public let expiresAt: Date?
    public let visits: Int
}
