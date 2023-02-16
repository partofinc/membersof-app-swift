//
//  ModelExtensions.swift
//  MembersOf
//
//  Created by Ravil Khusainov on 2022-11-30.
//

import Foundation
import Models

extension Team {
    static var loading: Team {
        .init(id: .zero, name: "Loading...", brief: "", createDate: .now, social: [], crew: [])
    }
}

extension Member {
    static var local: Member {
        .init(id: .zero, firstName: "Me", lastName: nil)
    }
}

extension Schedule {
    static var none: Schedule {
        .init(id: .zero, name: "None", team: .loading, repeats: [], nearestDate: nil, memeberships: [])
    }
}

extension Place {
    static var none: Place {
        .init(id: .zero, name: "None", latitude: 0, longitude: 0)
    }
}

extension [Supervisor.Role] {
    static var all: [Element] {[
        .owner,
        .admin,
        .manager
    ]}
}

extension [Social.Media] {
    static var all: [Element] {[
            .instagram,
            .telegram,
            .twitter,
            .facebook
        ]
    }
}

extension Invite {
    var title: String {
        let name = self.name ?? "Noname"
        return name + "(Pending)"
    }
}

extension UUID {
    static var zero: Self {
        .init(uuidString: "00000000-0000-0000-0000-000000000000")!
    }
}
