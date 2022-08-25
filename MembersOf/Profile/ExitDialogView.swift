//
//  ExitDialogView.swift
//  MembersOf
//
//  Created by Ravil Khusainov on 8/24/22.
//

import SwiftUI

struct ExitDialogView: View {
    
//    @Binding var detents: [PresentationDetent]
    
    var body: some View {
        List {
            Section {
                Button("Sign Out"){}
            } header: {
                Text("")
            } footer: {
                Button(role: .destructive) {
//                    if detents.contains(.large) {
//                        detents = [.fraction(0.3)]
//                    } else {
//                        detents = [.large]
//                    }
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
        ExitDialogView()
    }
}
