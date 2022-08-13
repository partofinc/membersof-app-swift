//
//  TeamBriefEditView.swift
//  MembersOf
//
//  Created by Ravil Khusainov on 8/4/22.
//

import SwiftUI

struct TeamBriefEditView: View {
    
    @State var brief: String
    let save: (String) -> Void
    @Environment(\.dismiss) var dismiss
    @FocusState private var focus
    
    var body: some View {
        VStack {
            HStack {
                Text("Brief")
                Spacer()
                Button("Save") {
                    save(brief)
                    dismiss()
                }
            }
            .padding(.horizontal)
            .frame(height: 44)
            .font(.headline)
            TextEditor(text: $brief)
                .focused($focus)
                .padding()
                .task {
                    do {
                        try await Task.sleep(nanoseconds: 100_000_000)
                    focus = true
                } catch {
                    
                }
            }
        }
    }
}

struct TeamBriefEditView_Previews: PreviewProvider {
    static var previews: some View {
        TeamBriefEditView(brief: "Some text") {_ in}
    }
}
