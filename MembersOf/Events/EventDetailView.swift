//
//  EventDetailView.swift
//  MembersOf
//
//  Created by Ravil Khusainov on 8/9/22.
//

import SwiftUI

struct EventDetailView: View {
    
    @StateObject var viewModel: ViewModel
    @State var sheet: Sheet?
    
    var body: some View {
        VStack {
            ScrollView {
                VStack(alignment: .leading) {
                    Text(viewModel.event.startDate.formatted(date: .abbreviated, time: .shortened))
                    NavigationLink {
                        TeamDetailView(viewModel: .init(team: viewModel.event.team))
                    } label: {
                        Text(viewModel.event.team.name)
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.accentColor.gradient.opacity(0.1))
                            .shadow(radius: 3)
                    )
                    HStack {
                        Text("Members(\(viewModel.visits.count))")
                            .font(.title2)
                        Spacer()
                    }
                    ForEach(viewModel.visits) { visit in
                        HStack {
                            Text(visit.member.fullName)
                                .font(.headline)
                            Spacer()
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color.purple.opacity(0.7).gradient)
                                .shadow(radius: 3)
                        )
                        .contextMenu {
                            Button(role: .destructive) {
                                viewModel.delete(visit)
                            } label: {
                                Label("Chedk Out", systemImage: "xmark")
                            }
                        }
                    }
                }
                .padding()
            }
            Button {
                sheet = .addMember
            } label: {
                Label("Check in", systemImage: "plus")
            }
            .padding()
        }
        .navigationTitle(viewModel.event.name)
        .sheet(item: $sheet) { sheet in
            switch sheet {
            case .addMember:
                SearchMembersView(viewModel: .init(viewModel.event))
                    .presentationDetents([.large])
            }
        }
        .animation(.easeInOut, value: viewModel.visits)
    }
}

struct EventDetailView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            EventDetailView(viewModel: .init(event: .init(id: UUID(), name: "Open mat", createDate: .now, startDate: .now, endDate: nil, team: Mock.teams.first!, memberships: [])))
        }
    }
}
