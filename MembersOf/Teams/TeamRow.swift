//
//  ClubRow.swift
//  MembersOf
//
//  Created by Ravil Khusainov on 8/3/22.
//

import SwiftUI
import Models

struct TeamRow: View {
    
    let team: Team
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(team.name)
                .font(.title3)
            HStack {
                if let owner = team.crew.first(where: {$0.role == .owner}) {
                    Text(owner.member.fullName)
                }
                Spacer()
                Image(systemName: "person")
                Text("67")
            }
            .font(.footnote)
        }
        .foregroundColor(.white)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(LinearGradient(colors: [.teal, .cyan], startPoint: .topLeading, endPoint: .bottomTrailing))
                .shadow(radius: 3)
        )
    }
}

struct ClubRow_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            TeamRow(team: Mock.teams.first!)
                .padding()
        }
    }
}
