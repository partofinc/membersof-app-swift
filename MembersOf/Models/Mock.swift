

import Foundation
import Models

enum Mock {
    
    static let teams: [Team] = [
        .init(
            id: UUID(),
            name: "Team Strela Kazan",
            brief: "The strongest jiu jitsu team in kazan. Lead by the great black belt Yanis Yanakidis",
            createDate: .now,
            social: [
                .init(id: UUID(), media: .instagram, account: "teamstrelakzn", order: 0, memberId: nil, teamId: nil),
                .init(id: UUID(), media: .telegram, account: "teamstrelakzn", order: 1, memberId: nil, teamId: nil)
            ],
            crew: [
                .init(id: UUID(), role: .owner, order: 0, member: members[1], teamId: nil)
            ]
        ),
        .init(id: UUID(), name: "Bars Profi Kazan", brief: "", createDate: .now, social: [], crew: []),
        .init(id: UUID(), name: "Kimura Jiu-Jitsu Alanya", brief: "", createDate: .now, social: [], crew: [])
    ]
    
    static let members: [Member] = [
        .init(id: UUID(), firstName: "Ravil", lastName: "Khusainov"),
        .init(id: UUID(), firstName: "Yanis", lastName: "Yanakidis"),
        .init(id: UUID(), firstName: "Guzel", lastName: "Nurieva")
    ]
}


