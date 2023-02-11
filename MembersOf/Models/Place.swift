//
//  Place.swift
//  MembersOf
//
//  Created by Ravil Khusainov on 2023-01-31.
//

import Foundation

public struct Place: Codable, Identifiable, Hashable {
    
    public let id: UUID
    public let name: String
    public let latitude: Double
    public let longitude: Double
}
