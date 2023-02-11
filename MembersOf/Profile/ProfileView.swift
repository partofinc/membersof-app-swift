//
//  ProfileView.swift
//  MembersOf
//
//  Created by Ravil Khusainov on 8/5/22.
//

import SwiftUI
import AuthenticationServices

struct ProfileView: View {
    
    @StateObject var viewModel: ViewModel
    @State private var editing: Bool = false
    @State private var sheet: Sheet?
    @State private var deletingSocial: Bool = false
    
    var body: some View {
        NavigationStack {
            Group {
                if viewModel.signedIn {
                    signedIn
                        .redacted(reason: viewModel.me == .local ? .placeholder : .init())
                } else {
                    signedOut
                }
            }
            .onChange(of: viewModel.me, perform: { newValue in
                if !viewModel.signedIn && editing {
                    editing.toggle()
                }
            })
            .navigationTitle("Profile")
            .toolbar {
                ToolbarItem {
                    toolbar
                }
            }
            .sheet(item: $sheet) { item in
                switch item {
                case .exit:
                    ExitDialogView(signOut: viewModel.signer.signOut)
                        .presentationDetents([.fraction(0.3)])
                }
            }
            .confirmationDialog(
                viewModel.socialConfirmationTitle,
                isPresented: $deletingSocial,
                titleVisibility: .visible,
                presenting: viewModel.deletingSocial) { social in
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
            if editing {
                edit
            } else {
                regular
            }
        }
    }
    
    @ViewBuilder
    private var signedOut: some View {
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
    }
    
    @ViewBuilder
    private var toolbar: some View {
        if viewModel.me != .local {
            if editing {
                Button("Done") {
                    viewModel.save()
                    editing.toggle()
                }
            } else {
                Button("Edit") {
                    editing.toggle()
                }
            }
        }
    }
    
    @ViewBuilder
    private var regular: some View {
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
    
    @ViewBuilder
    private var edit: some View {
        Section("") {
            TextField("First Name", text: $viewModel.firstName)
            #if os(iOS)
                .textContentType(.givenName)
            #endif
            TextField("Last Name", text: $viewModel.lastName)
            #if os(iOS)
                .textContentType(.familyName)
            #endif
        }
        Section("Social media") {
            ForEach(viewModel.social) { media in
                SocialMediaRow(media) {
                    viewModel.deletingSocial = media
                    deletingSocial.toggle()
                }
            }
            if let media = viewModel.addingMedia {
                NewSocialMediaRow(media: media, account: $viewModel.addingAccount) {
                    viewModel.addSocial()
                }
            } else if !viewModel.missingMedia.isEmpty {
                Menu {
                    ForEach(viewModel.missingMedia) { media in
                        Button(media.rawValue) {
                            viewModel.addingMedia = media
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
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView(viewModel: .init(PreviewSigner.default))
    }
}
