//
//  ExitDialogView.swift
//  MembersOf
//
//  Created by Ravil Khusainov on 8/24/22.
//

import SwiftUI

struct ExitDialogView: View {
    
    let signOut: () -> Void
    @Environment(\.dismiss) private var dismiss
        
    var body: some View {
        List {
            Section {
                Button("Sign Out"){
                    signOut()
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


struct ExitDialogView_Previews: PreviewProvider {
    @State static var detents: [PresentationDetent] = [.large]
    static var previews: some View {
        ExitDialogView(signOut: {})
    }
}
