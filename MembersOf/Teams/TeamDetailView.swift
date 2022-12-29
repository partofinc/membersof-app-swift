//
//  ClubDetailView.swift
//  MembersOf
//
//  Created by Ravil Khusainov on 8/3/22.
//

import SwiftUI
import Models

struct TeamDetailView: View {
    
    @StateObject var viewModel: ViewModel
    @State var subscribed = false

    @Environment(\.dismiss) private var dismiss
    @State private var editMode: Bool = false
    
    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading) {
                HStack {
                    Text(viewModel.team.brief)
                        .font(.title2)
                    Spacer()
                }
                .cardStyle()
                if !viewModel.team.social.isEmpty {
                    socialMedia
                }
                subscription
                crew
            }
            .padding()
        }
        .edit($editMode) {
            TeamDetailsEditView(viewModel: .init(viewModel.team, storage: viewModel.storage), editMode: $editMode)
        }
        .scrollDismissesKeyboard(.immediately)
        .navigationTitle(viewModel.team.name)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                EditButton(editMode: $editMode)
            }
        }
    }
    
    @ViewBuilder
    private var socialMedia: some View {
        VStack(alignment: .leading) {
            HStack {
                Text("Social media")
                    .font(.headline)
                Spacer()
            }
            ForEach(viewModel.team.social) { social in
                SocialMediaRow(social, style: .fancy)
                .padding(.bottom, 5)
            }
        }
        .cardStyle()
    }
    
    @ViewBuilder
    private var subscription: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text("Subscription")
                .font(.headline)
            HStack {
                Text("Tier")
                Spacer()
                Text(subscribed ? "$5/Month" : "Free")
                    .font(.headline)
            }
            if subscribed {
                HStack {
                    Text("Next payment")
                    Spacer()
                    Text("December 22")
                        .font(.headline)
                }
                HStack {
                    Text("Managed by")
                    Spacer()
                    Text("Yanis Y.")
                        .font(.headline)
                }
            } else {
                Button {
                    subscribed.toggle()
                } label: {
                    Label("Upgrade", systemImage: "lock.open")
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color.red.opacity(0.5).gradient)
                                .shadow(radius: 3)
                        )
                }
                .foregroundColor(.white)
            }
        }
        .cardStyle()
    }
    
    @ViewBuilder
    private var paymentSection: some View {
        VStack {
            Text("Payment")
                .font(.title2)
                .padding(.top)
            Button {
                
            } label: {
                Label("Connect Stripe", systemImage: "link")
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color.red.opacity(0.5).gradient)
                            .shadow(radius: 3)
                    )
            }
            .foregroundColor(.white)
        }
        .cardStyle()
    }
    
    @ViewBuilder
    private var crew: some View {
        VStack {
            HStack {
                Text("Crew")
                    .font(.headline)
                Spacer()
            }
            ForEach(viewModel.team.crew) { supervisor in
                    HStack {
                        Text(supervisor.member.fullName)
                            .font(.headline)
                        Spacer()
                        Text(supervisor.role.rawValue.capitalized)
                            .font(.body)
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color.purple.opacity(0.7).gradient)
                            .shadow(radius: 3)
                    )
            }
            ForEach(viewModel.invites) { invite in
                Button {
                    
                } label: {
                    HStack {
                        Text(invite.title)
                            .font(.headline)
                        Spacer()
                        Text(invite.role!.rawValue.capitalized)
                            .font(.body)
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color.purple.opacity(0.4).gradient)
                            .shadow(radius: 3)
                    )
                }
                .buttonStyle(.plain)
            }
        }
        .cardStyle()
        .disabled(!subscribed)
        .opacity(subscribed ? 1 : 0.5)
    }
}

struct ClubDetailView_Previews: PreviewProvider {
    static let storage = MockStorage()
    static var previews: some View {
        NavigationStack {
            TeamDetailView(viewModel: .init(storage.teams.first!, storage: storage))
        }
    }
}
