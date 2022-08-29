//
//  ExitDialogView.swift
//  MembersOf
//
//  Created by Ravil Khusainov on 8/24/22.
//

import SwiftUI

struct ExitDialogView: View {
    
    @StateObject var viewModel: ViewModel = .init()
    @Environment(\.dismiss) private var dismiss
        
    var body: some View {
        List {
            Section {
                Button("Sign Out"){
                    viewModel.signOut()
                    dismiss()
                }
            } header: {
                Text("")
            } footer: {
                Button(role: .destructive) {

                } label: {
                    HStack {
                        Spacer()
                        Label("Delete account", systemImage: "trash")
                        Spacer()
                    }
                }
                .padding()
            }
        }
    }
}

extension ExitDialogView {
    
    @MainActor
    final class ViewModel: ObservableObject {
        
        private let signer: Signer = .shared
        
        func signOut() {
            signer.signOut()
        }
    }
}

struct ExitDialogView_Previews: PreviewProvider {
    @State static var detents: [PresentationDetent] = [.large]
    static var previews: some View {
        ExitDialogView()
    }
}
