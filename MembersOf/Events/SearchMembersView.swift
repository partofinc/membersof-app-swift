//
//  SearchMembersView.swift
//  MembersOf
//
//  Created by Ravil Khusainov on 8/9/22.
//

import SwiftUI

struct SearchMembersView: View {
    
    @StateObject var viewModel: ViewModel
    let select: (Member) -> Void
    
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            List {
                Button {
//                    withAnimation {
//                        viewModel.members.insert(.init(id: UUID(), firstName: "Animated", lastName: "me"), at: 0)
//                    }
                    viewModel.storage.save([Member(id: UUID(), firstName: "Later", lastName: "On")])
//                    NewMemberView(viewModel: .init(team: viewModel.team)) { member in
//                        select(member)
//                        dismiss()
//                    }
                } label: {
                    Label("New", systemImage: "plus")
                }
                ForEach(viewModel.members) { member in
                    NavigationLink {
                        MemberConfirmationView(viewModel: .init(member: member)) {
                            select(member)
                            dismiss()
                        }
                    } label: {
                        Label(member.fullName, systemImage: "person")
                    }
                    .swipeActions {
                        Button(role: .destructive) {
                            viewModel.storage.delete([member])
                        } label: {
                            Image(systemName: "trash")
                        }
//                        .tint(.red)
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
        SearchMembersView(viewModel: .init(team: Mock.teams.first!)) {_ in}
    }
}
