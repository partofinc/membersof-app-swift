//
//  MembershipRow.swift
//  MembersOf
//
//  Created by Ravil Khusainov on 17.02.2023.
//

import SwiftUI
import Models

struct MembershipRow: View {
    
    let membership: Membership
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text(membership.name)
                    .font(.title3)
                Spacer()
                Text(membership.team.name)
                    .font(.callout)
                    .bold()
            }
            HStack {
                ForEach(membership.pricing) { price in
                    Text(price.value, format: .currency(code: price.currency))
                    if let last = membership.pricing.last, price.id != last.id {
                        Text("|")
                    }
                }
            }
            .font(.footnote)
        }
        .foregroundColor(.white)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(LinearGradient(colors: [.cyan, .teal], startPoint: .bottom, endPoint: .top))
                .shadow(radius: 3)
        )
    }
}

struct MembershipRow_Previews: PreviewProvider {
    static let storage = MockStorage()
    static var previews: some View {
        VStack {
            MembershipRow(membership: storage.memberships.first!)
                .padding()
        }
    }
}
