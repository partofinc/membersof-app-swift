//
//  NewSupervisorView.swift
//  MembersOf
//
//  Created by Ravil Khusainov on 8/26/22.
//

import SwiftUI

struct NewSupervisorView: View {
    
    @StateObject var viewModel: ViewModel
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        Form {
            Section {
                TextField("Name (optional)", text: $viewModel.name)
                Picker("Role", selection: $viewModel.role) {
                    ForEach(viewModel.roles) { role in
                        Text(role.rawValue.capitalized)
                    }
                }
            } footer: {
                Text("You should explicitly send invitation link to the person")
            }
            Section {
                ShareLink(item: viewModel.url) {
                    Label("Invite", systemImage: "square.and.arrow.up")
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle("Supervisor")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Save") {
                    viewModel.save()
                    dismiss()
                }
            }
        }
    }
}

struct NewSupervisorView_Previews: PreviewProvider {
    static let storage = MockStorage()
    static var previews: some View {
        NewSupervisorView(viewModel: .init(storage.teams.first!, storage: storage))
    }
}
