

import Foundation

enum Mock {
    
    static let teams: [Team] = [
        .init(
            id: UUID(),
            name: "Team Strela Kazan",
            brief: "The strongest jiu jitsu team in kazan. Lead by the great black belt Yanis Yanakidis",
            social: [
                .init(id: UUID(), media: .instagram, account: "teamstrelakzn"),
                .init(id: UUID(), media: .telegram, account: "teamstrelakzn")
            ],
            crew: [
                .init(id: UUID(), role: .owner, order: 0, member: members[1])
            ]
        ),
        .init(id: UUID(), name: "Bars Profi Kazan", brief: "", social: [], crew: []),
        .init(id: UUID(), name: "Kimura Jiu-Jitsu Alanya", brief: "", social: [], crew: [])
    ]
    
    static let members: [Member] = [
        .init(id: UUID(), firstName: "Ravil", lastName: "Khusainov"),
        .init(id: UUID(), firstName: "Yanis", lastName: "Yanakidis"),
        .init(id: UUID(), firstName: "Guzel", lastName: "Nurieva")
    ]
}
