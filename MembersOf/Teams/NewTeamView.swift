//
//  NewClubView.swift
//  MembersOf
//
//  Created by Ravil Khusainov on 8/2/22.
//

import SwiftUI

struct NewTeamView: View {
    
    @StateObject var viewModel = ViewModel()
    @Binding var team: Team?
    
    var body: some View {
        VStack {
            HStack {
                Text("Team")
                Spacer()
                Button("Create") {
                    team = viewModel.create()
                }
            }
            .padding(.horizontal)
            .frame(height: 44)
            .font(.headline)
            Form {
                HStack {
                    Text("Name")
                    TextField("", text: $viewModel.name)
                        .multilineTextAlignment(.trailing)
                }
                TextEditor(text: $viewModel.brief)
                Section("social media") {
                    ForEach(viewModel.socials) { social in
                        HStack {
                            Text(social.media.rawValue.capitalized)
                            Spacer()
                            Text(social.account)
                            Button {
                                viewModel.remove(social)
                            } label: {
                                Image(systemName: "trash")
                                    .font(.title2)
                            }
                            .buttonStyle(.plain)
                            .foregroundColor(.red)
                        }
                    }
                    if !viewModel.medias.isEmpty {
                        HStack {
                            Picker("", selection: $viewModel.media) {
                                ForEach(viewModel.medias) {
                                    Text($0.rawValue.capitalized)
                                }
                            }
                            .labelsHidden()
                            TextField("Account", text: $viewModel.account)
                                .keyboardType(.emailAddress)
                                .textInputAutocapitalization(.never)
                                .multilineTextAlignment(.trailing)
                            Button {
                                viewModel.addSocial()
                            } label: {
                                Image(systemName: "checkmark.circle")
                                    .font(.title2)
                            }
                            .buttonStyle(.plain)
                            .foregroundColor(.accentColor)
                            .disabled(viewModel.account.count < 3)
                        }
                    }
                }
            }
        }
    }
}

struct NewTeamView_Previews: PreviewProvider {
    @State static var creatingNew = true
    @State static var team: Team?
    
    static var previews: some View {
        VStack {
            Spacer()
            Button {
                creatingNew.toggle()
            } label: {
                Label("New", systemImage: "plus")
            }
            .padding()
        }
        .sheet(isPresented: $creatingNew) {
            NewTeamView(team: $team)
                .presentationDetents([.fraction(0.6)])
        }
    }
}
