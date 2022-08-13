//
//  ClubsView.swift
//  MembersOf
//
//  Created by Ravil Khusainov on 8/3/22.
//

import SwiftUI

struct TeamsView: View {
    
    @StateObject var viewModel = ViewModel()
    @State private var path: [Team] = []
    @State private var newTeam: Team?
    
    var body: some View {
        NavigationStack(path: $path) {
            VStack {
                ScrollView {
                    VStack(alignment: .leading) {
                        ForEach(viewModel.teams) { team in
                            TeamRow(team: team)
                                .onTapGesture {
                                    path = [team]
                                }
                        }
                    }
                    .padding()
                    .navigationDestination(for: Team.self) {
                        TeamDetailView(viewModel: .init(team: $0))
                    }
                }
                Spacer()
                Button {
                    viewModel.creatingNew.toggle()
                } label: {
                    Label("New", systemImage: "plus")
                }
                .padding()
            }
            .sheet(isPresented: $viewModel.creatingNew) {
                NewTeamView(team: $newTeam)
                    .presentationDetents([.medium, .large])
            }
            .onChange(of: newTeam) { team in
                guard let team else { return }
                viewModel.add(team)
                path = [team]
            }
            .navigationTitle("Teams")
        }
    }
}

struct ClubsView_Previews: PreviewProvider {
    static var previews: some View {
        TeamsView()
    }
}
