//
//  SearchMembersView.swift
//  MembersOf
//
//  Created by Ravil Khusainov on 8/9/22.
//

import SwiftUI

struct SearchMembersView: View {
    
    @StateObject var viewModel: ViewModel
    
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            List {
                NavigationLink {
                    NewMemberView(viewModel: .init(team: viewModel.team, event: viewModel.event), dismiss: dismiss)
                } label: {
                    Label("New", systemImage: "plus")
                }
                ForEach(viewModel.members) { member in
                    NavigationLink {
                        MemberConfirmationView(viewModel: .init(member: member, event: viewModel.event))
                    } label: {
                        Label(member.fullName, systemImage: "person")
                    }
                    .swipeActions {
                        Button(role: .destructive) {
                            viewModel.delete(member)
                        } label: {
                            Image(systemName: "trash")
                        }
                    }
                }
            }
            .animation(.easeOut, value: viewModel.members)
            .searchable(text: $viewModel.pattern, prompt: "Name")
            .onChange(of: viewModel.pattern, perform: { newValue in
                viewModel.search()
            })
            .navigationTitle("Members")
        }
    }
}

struct SearchMembersView_Previews: PreviewProvider {
    static var previews: some View {
        SearchMembersView(viewModel: .init(team: Mock.teams.first!, event: .init(id: UUID(), name: "Tested event", createDate: .now, startDate: nil, endDate: nil, team: Mock.teams.first!)))
    }
}
