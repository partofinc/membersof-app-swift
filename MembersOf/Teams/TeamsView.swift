//
//  ClubsView.swift
//  MembersOf
//
//  Created by Ravil Khusainov on 8/3/22.
//

import SwiftUI

struct TeamsView: View {
    
    @StateObject var viewModel: ViewModel
    @State private var creatingNew: Bool = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(alignment: .leading) {
                    ForEach(viewModel.teams) { team in
                        NavigationLink {
                            TeamDetailView(viewModel: .init(team, storage: viewModel.storage))
                        } label: {
                            TeamRow(team: team)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding()
            }
            .safeAreaInset(edge: .bottom) {
                Button {
                    creatingNew.toggle()
                } label: {
                    Label("New", systemImage: "plus")
                }
                .buttonStyle(.primary)
                .padding()
            }
            .sheet(isPresented: $creatingNew) {
                NavigationStack {
                    NewTeamView(viewModel: .init(viewModel.signer))
                }
                    .presentationDetents([.medium, .large])
            }
            .navigationTitle("Teams")
            .animation(.easeInOut, value: viewModel.teams)
        }
    }
}

//struct ClubsView_Previews: PreviewProvider {
//    static var previews: some View {
//        TeamsView()
//    }
//}
