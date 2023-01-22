//
//  NewTeamView.swift
//  MembersOf
//
//  Created by Ravil Khusainov on 8/2/22.
//

import SwiftUI
import Models

struct NewTeamView: View {
    
    @StateObject var viewModel: ViewModel
    @Binding var team: Team // Communicate back newly created team
    
    @Environment(\.dismiss) private var dismiss
    @FocusState private var addingSocial
    @FocusState private var editingName
    
    var body: some View {
        VStack {
            Form {
                Section {
                    TextField("Name", text: $viewModel.name)
                        .focused($editingName)
                    TextField("Introduction", text: $viewModel.brief, axis: .vertical)
                } footer: {
                    Text("Briefly describe yor team")
                }
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
                            }
                            .buttonStyle(.plain)
                            .foregroundColor(.red)
                        }
                    }
                    if let media = viewModel.media {
                        HStack {
                            Text(media.rawValue)
                            TextField("Account", text: $viewModel.account)
                                .textContentType(.username)
                            #if os(iOS)
                                .keyboardType(.emailAddress)
                                .textInputAutocapitalization(.never)
                            #endif
                                .autocorrectionDisabled()
                                .multilineTextAlignment(.trailing)
                                .focused($addingSocial)
                            Button {
                                viewModel.addSocial()
                            } label: {
                                Image(systemName: "checkmark.circle")
                            }
                            .buttonStyle(.plain)
                            .foregroundColor(.accentColor)
                            .disabled(viewModel.account.count < 3)
                        }
                    } else if !viewModel.medias.isEmpty {
                        Menu {
                            ForEach(viewModel.medias) { media in
                                Button(media.rawValue) {
                                    viewModel.media = media
                                    addingSocial.toggle()
                                }
                            }
                        } label: {
                            Label("Add", systemImage: "plus")
                        }
                    }
                }
            }
        }
        .onAppear {
            editingName.toggle()
        }
        .navigationTitle("Team")
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(.visible, for: .navigationBar)
        #endif
        .toolbar {
            ToolbarItem {
                Button("Create") {
                    team = viewModel.create()
                    dismiss()
                }
                .disabled(!viewModel.canCreate)
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
            NewTeamView(viewModel: .init(PreviewSigner.default), team: .constant(.loading))
                .presentationDetents([.fraction(0.6)])
        }
    }
}
