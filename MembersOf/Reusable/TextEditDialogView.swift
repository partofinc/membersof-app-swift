//
//  TeamBriefEditView.swift
//  MembersOf
//
//  Created by Ravil Khusainov on 8/4/22.
//

import SwiftUI

struct TextEditDialogView: View {
    
    let title: LocalizedStringKey
    @State var text: String
    let save: (String) -> Void
    
    @Environment(\.dismiss) private var dismiss
    @FocusState private var focus
    
    var body: some View {
        VStack {
            HStack {
                Text(title)
                Spacer()
                Button("Done") {
                    save(text)
                    dismiss()
                }
            }
            .padding(.horizontal)
            .frame(height: 44)
            .font(.headline)
            TextEditor(text: $text)
                .font(.headline)
                .focused($focus)
                .padding()
        }
        .onAppear {
            focus = true
        }
    }
}

struct TeamBriefEditView_Previews: PreviewProvider {
    static var previews: some View {
        TextEditDialogView(title: "Here I am", text: "Some text") {_ in}
    }
}
