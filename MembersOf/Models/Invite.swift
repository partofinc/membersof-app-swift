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
    public let role: Supervisor.Role?
    public let teamId: UUID?
}

extension Invite {
    var title: String {
        let name = self.name ?? "Noname"
        return name + "(Pending)"
    }
}
