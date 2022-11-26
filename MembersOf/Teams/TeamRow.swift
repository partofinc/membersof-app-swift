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
        HStack {
            Text(team.name)
            Spacer()
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.blue.opacity(0.4).gradient)
                .shadow(radius: 5)
        )
    }
}

struct ClubRow_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            TeamRow(team: Mock.teams.first!)
        }
    }
}
