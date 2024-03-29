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
                GroupBox {
                    HStack {
                        Text(viewModel.team.brief)
                            .font(.title3)
                        Spacer()
                    }
                }
                if !viewModel.team.social.isEmpty {
                    socialMedia
                }
                members
                events
            }
            .padding()
        }
        .edit($editMode) {
            TeamDetailsEditView(viewModel: .init(viewModel.team, storage: viewModel.storage), editMode: $editMode)
        }
        .scrollDismissesKeyboard(.immediately)
        .navigationTitle(viewModel.team.name)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                EditButton(editMode: $editMode)
            }
        }
    }
    
    @ViewBuilder
    private var socialMedia: some View {
        GroupBox("Social media") {
            ForEach(viewModel.team.social) { social in
                SocialMediaRow(social, style: .fancy)
            }
        }
    }
    
    @ViewBuilder
    private var members: some View {
        GroupBox {
            VStack(spacing: 10) {
                HStack {
                    Button {
                        
                    } label: {
                        Label("New Member", systemImage: "plus")
                    }
                    .buttonStyle(.primarySmall)
                    Spacer()
                }
            }
        } label: {
            NavigationLink {
                Text("All members")
            } label: {
                HStack {
                    Text("Members")
                    Image(systemName: "chevron.right")
                    Spacer()
                    Text("67")
                }
                .font(.headline)
            }
            .buttonStyle(.plain)
        }
    }
    
    @ViewBuilder
    private var events: some View {
        GroupBox {
            
        } label: {
            NavigationLink {
                Text("All events")
            } label: {
                HStack {
                    Text("Events")
                    Image(systemName: "chevron.right")
                    Spacer()
                    Text("12")
                }
            }
            .buttonStyle(.plain)
            .font(.headline)
        }
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
                        Text(invite.role.rawValue.capitalized)
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
