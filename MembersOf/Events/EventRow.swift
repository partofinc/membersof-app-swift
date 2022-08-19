//
//  EventRow.swift
//  MembersOf
//
//  Created by Ravil Khusainov on 8/9/22.
//

import SwiftUI

struct EventRow: View {
    
    let event: Event
    
    var body: some View {
        VStack {
            Text(event.name)
            Spacer()
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.pink.opacity(0.4).gradient)
                .shadow(radius: 5)
        )
    }
}

struct EventRow_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            HStack {
                EventRow(event: .init(id: UUID(), name: "Open mat", createDate: .now, startDate: nil, endDate: nil, team: Mock.teams.first!))
            }
        }
        .padding()
    }
}
