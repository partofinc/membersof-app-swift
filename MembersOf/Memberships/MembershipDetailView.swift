//
//  MembershipDetailView.swift
//  MembersOf
//
//  Created by Ravil Khusainov on 8/23/22.
//

import SwiftUI

struct MembershipDetailView: View {
    
    @StateObject var viewModel: ViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var editMode: Bool = false
    
    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading) {
                team
                restrictions
                pricing
            }
            .padding()
        }
        .navigationTitle(viewModel.membership.name)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                EditButton(editMode: $editMode)
            }
        }
    }
    
    @ViewBuilder
    private var team: some View {
        HStack {
            Text("Team")
                .font(.headline)
            Spacer()
            NavigationLink {
                TeamDetailView(viewModel: .init(viewModel.team, storage: viewModel.storage))
            } label: {
                HStack {
                    Text(viewModel.team.name)
                    Image(systemName: "chevron.right")
                }
            }
            .buttonStyle(.primarySmall)
        }
        .cardStyle()
    }
    
    @ViewBuilder
    private var restrictions: some View {
        VStack {
            HStack {
                Text("Restrictions")
                    .font(.headline)
                    .padding(.bottom)
                Spacer()
            }
            HStack {
                Text("Visits")
                Spacer()
                Text(viewModel.membership.visits.formatted())
            }
            HStack {
                Text("Period")
                Spacer()
                Text(viewModel.membership.length.formatted())
                Text(viewModel.membership.period.rawValue)
            }
        }
        .cardStyle()
    }
    
    @ViewBuilder
    private var pricing: some View {
        if viewModel.membership.pricing.isEmpty {
            EmptyView()
        } else {
            VStack(alignment: .leading) {
                HStack {
                    Text("Pricing")
                        .font(.headline)
                        .padding(.bottom)
                    Spacer()
                }
                ForEach(viewModel.membership.pricing) { price in
                    Text(price.formatted)
                }
            }
            .cardStyle()
        }
    }
}

struct MembershipDetailView_Previews: PreviewProvider {
    static let storage = MockStorage()
    static var previews: some View {
        NavigationStack {
            MembershipDetailView(viewModel: .init(storage.memberships.first!, storage: storage))
        }
    }
}
