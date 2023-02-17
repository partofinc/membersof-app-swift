//
//  TeamDetailsEditView.swift
//  MembersOf
//
//  Created by Ravil Khusainov on 2022-12-20.
//

import SwiftUI

struct TeamDetailsEditView: View {
    
    @StateObject var viewModel: ViewModel
    @Binding var editMode: Bool
    
    @State private var sheet: Sheet?
    @FocusState private var addingSocial: Bool
    
    
    var body: some View {
        Form {
            Section {
                TextField("Name", text: $viewModel.name)
                TextField("Introduction", text: $viewModel.brief, axis: .vertical)
            }
            socialMedia
            crew
            Section("") {
                Button(role: .destructive) {
                    
                } label: {
                    Label("Delete", systemImage: "trash")
                }
            }
        }
        .safeAreaInset(edge: .bottom) {
            Button("Save") {
                viewModel.save()
                editMode.toggle()
            }
            .buttonStyle(.primary)
            .padding()
            .background(.ultraThinMaterial)
        }
        .sheet(item: $sheet) { sheet in
            switch sheet {
            case .supervisor(let supervisor):
                NavigationStack {
                    SupervisorView(viewModel: .init(supervisor), save: {viewModel.update($0)}, delete: {viewModel.delete($0)})
                }
                .presentationDetents([.medium])
            case .newSupervisor:
                NavigationStack {
                    NewSupervisorView(viewModel: .init(viewModel.team, storage: viewModel.storage))
                }
                .presentationDetents([.medium])
            }
        }
        .animation(.easeInOut, value: viewModel.socials)
    }
    
    @ViewBuilder
    private var crew: some View {
        Section("Crew") {
            ForEach(viewModel.crew) { supervisor in
                Button {
                    sheet = .supervisor(supervisor)
                } label: {
                    HStack {
                        Text(supervisor.member.fullName)
                        Spacer()
                        Text(supervisor.role.rawValue)
                            .font(.headline)
                    }
                }
                .buttonStyle(.plain)
            }
            ForEach(viewModel.invites) { invite in
                Button {
                    
                } label: {
                    HStack {
                        Text(invite.title)
                        Spacer()
                        Text(invite.role.rawValue)
                            .font(.headline)
                    }
                }
                .buttonStyle(.plain)
            }
            Button {
                sheet = .newSupervisor
            } label: {
                Label("Add", systemImage: "plus")
            }
        }
    }
    
    @ViewBuilder
    private var socialMedia: some View {
        Section("Social media") {
            ForEach(viewModel.socials) { media in
                SocialMediaRow(media) {
                    viewModel.delete(media)
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
                }
                HStack {
                    Button {
                        viewModel.addSocial()
                    } label: {
                        Label("Save", systemImage: "checkmark")
                    }
                    .buttonStyle(.plain)
                    .foregroundColor(.accentColor)
                    .frame(maxWidth: .infinity)
                    .disabled(viewModel.account.count < 3)
                    Button(role: .destructive) {
                        viewModel.media = nil
                        viewModel.account = ""
                    } label: {
                        Label("Cancel", systemImage: "xmark")
                    }
                    .buttonStyle(.plain)
                    .foregroundColor(.red)
                    .frame(maxWidth: .infinity)
                }
            } else if !viewModel.socialMedias.isEmpty {
                Menu {
                    ForEach(viewModel.socialMedias) { media in
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

