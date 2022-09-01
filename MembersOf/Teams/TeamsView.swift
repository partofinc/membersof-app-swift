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
    @State private var creatingNew: Bool = false
    
    var body: some View {
        NavigationStack(path: $path) {
            VStack {
                ScrollView {
                    LazyVStack(alignment: .leading) {
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
                    creatingNew.toggle()
                } label: {
                    Label("New", systemImage: "plus")
                }
                .padding()
            }
            .sheet(isPresented: $creatingNew) {
                NavigationStack {
                    NewTeamView()
                }
                    .presentationDetents([.medium, .large])
            }
            .navigationTitle("Teams")
            .animation(.easeInOut, value: viewModel.teams)
        }
    }
}

struct ClubsView_Previews: PreviewProvider {
    static var previews: some View {
        TeamsView()
    }
}
