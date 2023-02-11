//
//  SupervisorView.swift
//  MembersOf
//
//  Created by Ravil Khusainov on 8/4/22.
//

import SwiftUI
import Models

struct SupervisorView: View {
    
    @StateObject var viewModel: ViewModel
    let save: (Supervisor) -> Void
    let delete: (Supervisor) -> Void
    @Environment(\.dismiss) private var dismiss
    @State private var removalConfirmation = false
    
    var body: some View {
        Form {
            Section {
                Text(viewModel.supervisor.member.fullName)
                    .font(.title2)
                Picker("Role", selection: $viewModel.role) {
                    ForEach([Supervisor.Role].all) { role in
                        Text(role.rawValue.capitalized)
                    }
                }
            }
            Button {
                removalConfirmation = true
            } label: {
                Label("Delete", systemImage: "trash")
            }
            .foregroundColor(.red)
        }
        .navigationTitle("Supervisor")
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button("Save") {
                    save(viewModel.save())
                    dismiss()
                }
                .disabled(!viewModel.canSave)
            }
        }
        .confirmationDialog("Please confirm supervisor removal", isPresented: $removalConfirmation, titleVisibility: .visible) {
            Button("Confrim", role: .destructive) {
                delete(viewModel.supervisor)
                dismiss()
            }
            Button("Cancel", role: .cancel) {}
        }
    }
    
    @MainActor
    final class ViewModel: ObservableObject {
        
        let supervisor: Supervisor
        @Published var role: Supervisor.Role
        
        init(_ supervisor: Supervisor) {
            self.supervisor = supervisor
            self.role = supervisor.role
        }
        
        var canSave: Bool {
            role != supervisor.role
        }
        
        func save() -> Supervisor {
            .init(id: supervisor.id, role: role, order: supervisor.order, member: supervisor.member, teamId: nil)
        }
    }
}

struct SupervisorView_Previews: PreviewProvider {
    static var previews: some View {
        SupervisorView(viewModel: .init(Mock.teams.first!.crew.first!), save: {_ in}, delete: {_ in})
    }
}
