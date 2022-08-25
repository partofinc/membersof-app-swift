//
//  ProfileView.swift
//  MembersOf
//
//  Created by Ravil Khusainov on 8/5/22.
//

import SwiftUI
import AuthenticationServices

struct ProfileView: View {
    
    @StateObject private var viewModel: ViewModel = .init()
    @State private var edit: Bool = false
    @State private var sheet: Sheet?
    @State private var deleteSocialMedia: Bool = false
    @State private var deletingSocial: Social?
    @FocusState private var addingSocial: Bool
//    @State private var exitDetents: [PresentationDetent] = [.fraction(0.3)]
    
    var body: some View {
        NavigationStack {
            Group {
                if viewModel.userId == nil {
                    VStack {
                        SignInWithAppleButton { request in
                            request.requestedScopes = [.fullName, .email]
                        } onCompletion: { result in
                            
                        }
                        .frame(height: 44)
                        Button {
                            viewModel.singIn(.init(id: UUID(), firstName: "Ravil", lastName: nil))
                        } label: {
                            Text("G Sign In with google")
                        }
                        .frame(height: 44)
                    }
                    .padding()
                } else {
                    signedIn
                        .redacted(reason: viewModel.me == .local ? .placeholder : .init())
                }
            }
            .navigationTitle("Profile")
            .toolbar {
                ToolbarItem {
                    if viewModel.me != .local {
                        if edit {
                            Button("Done") {
                                viewModel.save()
                                edit.toggle()
                            }
                        } else {
                            Button("Edit") {
                                edit.toggle()
                            }
                        }
                    }
                }
            }
            .task {
                viewModel.fetch()
            }
            .sheet(item: $sheet) { item in
                switch item {
                case .exit:
                    ExitDialogView()
                        .presentationDetents([.fraction(0.3)])
                }
            }
            .confirmationDialog(
                deletingSocial == nil ? "" : deletingSocial!.title,
                isPresented: $deleteSocialMedia,
                titleVisibility: .visible,
                presenting: deletingSocial) { social in
                    Button("Delete", role: .destructive) {
                        viewModel.delete(social)
                    }
                    Button("Cancel", role: .cancel) {}
                }
                .animation(.easeInOut, value: viewModel.social)
        }
    }
    
    @ViewBuilder
    private var signedIn: some View {
        List {
            if edit {
                Section("") {
                    TextField("First Name", text: $viewModel.firstName)
                        .textContentType(.givenName)
                    TextField("Last Name", text: $viewModel.lastName)
                        .textContentType(.familyName)
                }
                Section("Social media") {
                    ForEach(viewModel.social) { media in
                        HStack {
                            Text(media.media.rawValue)
                            Spacer()
                            Text(media.account)
                                .font(.headline)
                            Button(role: .destructive) {
                                deletingSocial = media
                                deleteSocialMedia.toggle()
                            } label: {
                                Image(systemName: "trash")
                            }
                            .buttonStyle(.plain)
                            .foregroundColor(.red)
                        }
                    }
                    if let media = viewModel.addingMedia {
                        HStack {
                            Text(media.rawValue)
                            Spacer()
                            TextField("Account", text: $viewModel.addingAccount)
                                .multilineTextAlignment(.trailing)
                                .keyboardType(.emailAddress)
                                .textContentType(.nickname)
                                .autocorrectionDisabled()
                                .autocapitalization(.none)
                            #if os(iOS)
                                .focused($addingSocial)
                            #endif
                            Button {
                                viewModel.addSocial()
                            } label: {
                                Image(systemName: "checkmark.circle")
                            }
                            .buttonStyle(.plain)
                            .foregroundColor(.accentColor)
                            .disabled(viewModel.addingAccount.count < 3)
                        }
                    } else if !viewModel.missingMedia.isEmpty {
                        Menu {
                            ForEach(viewModel.missingMedia) { media in
                                Button(media.rawValue) {
                                    viewModel.addingMedia = media
                                    addingSocial = true
                                }
                            }
                        } label: {
                            Label("Add", systemImage: "plus")
                        }
                    }
                }
                Section {
                    Button {
                        sheet = .exit
                    } label: {
                        Label("Exit", systemImage: "door.left.hand.open")
                    }
                }
            } else {
                Section("") {
                    HStack {
                        Circle()
                            .fill(Color.red.gradient)
                            .frame(width: 34, height: 34)
                        Text(viewModel.me.fullName)
                            .font(.title)
                            .padding(5)
                    }
                }
                Section("Social media") {
                    ForEach(viewModel.social) { media in
                        Button {
                            
                        } label: {
                            HStack {
                                Text(media.media.rawValue)
                                Spacer()
                                Text(media.account)
                                    .font(.headline)
                            }
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView()
    }
}
