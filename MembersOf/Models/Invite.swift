//
//  Invite.swift
//  MembersOf
//
//  Created by Ravil Khusainov on 8/26/22.
//

import Foundation

public struct Invite: Codable, Identifiable, Hashable {
    
    public let id: UUID
    public let createDate: Date
    public let name: String?
    public let role: String?
    public let teamId: String?
}
