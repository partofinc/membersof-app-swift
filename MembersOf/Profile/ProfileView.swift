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
    
    var body: some View {
        NavigationStack {
            Group {
                if let me = viewModel.me {
                    List {
                        Text(me.fullName)
                            .font(.title2)
                    }
                } else {
                    VStack {
                        SignInWithAppleButton { request in
                            request.requestedScopes = [.fullName, .email]
                        } onCompletion: { result in
                            
                        }
                        .frame(height: 44)
                        Button {
                            
                        } label: {
                            Text("G Sign In with google")
                        }
                        .frame(height: 44)
                    }
                }
            }
            .padding()
            .navigationTitle("Profile")
            .toolbar {
                ToolbarItem {
                    if viewModel.me != nil {
                        if edit {
                            Button("Save") {
                                
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
        }
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView()
    }
}
