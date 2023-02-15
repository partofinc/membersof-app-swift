//
//  EventRow.swift
//  MembersOf
//
//  Created by Ravil Khusainov on 8/9/22.
//

import SwiftUI
import Models

struct EventRow: View {
    
    let event: Event
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(event.team.name)
                        .font(.footnote)
                Text(event.name)
                    .font(.title2)
                Spacer()
                Text(event.startDate, format: .relative(presentation: .numeric))
                    .font(.caption)
            }
            Spacer()
        }
        .frame(maxWidth: .infinity)
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
            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    EventRow(event: .init(id: UUID(), name: "Open mat", createDate: .now, startDate: .now, duration: 36000, finished: false, team: Mock.teams.first!, memberships: []))
                        .frame(minWidth: 150)
                }
                .padding()
            }
            .frame(height: 100)
            Spacer()
        }
    }
}
