//
//  MembershipDetailView.swift
//  MembersOf
//
//  Created by Ravil Khusainov on 8/23/22.
//

import SwiftUI

struct MembershipDetailView: View {
    
    @StateObject var viewModel: ViewModel
    
    var body: some View {
        VStack {
            List {
                ForEach(viewModel.membership.pricing) { price in
                    Text(viewModel.format(price))
                }
            }
        }
        .navigationTitle(viewModel.membership.name)
    }
}

struct MembershipDetailView_Previews: PreviewProvider {
    static var previews: some View {
        MembershipDetailView(viewModel:
                .init(
                    .init(
                        id: UUID(),
                        name: "One Time",
                        visits: 1,
                        period: .day,
                        length: 1,
                        createDate: .now,
                        teamId: nil,
                        pricing: [
                            .init(id: UUID(), currency: "USD", value: 50)
                        ]))
        )
    }
}
