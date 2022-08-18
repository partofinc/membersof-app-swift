//
//  SupervisorView.swift
//  MembersOf
//
//  Created by Ravil Khusainov on 8/4/22.
//

import SwiftUI

struct SupervisorView: View {
    
    @StateObject var viewModel: ViewModel
    let save: (Supervisor) -> Void
    let delete: (Supervisor) -> Void
    @Environment(\.dismiss) var dismiss
    @State private var removalConfirmation = false
    
    var body: some View {
        VStack {
            HStack {
                Text("Supervisor")
                Spacer()
                Button("Save") {
                    save(viewModel.save())
                    dismiss()
                }
                .disabled(!viewModel.canSave)
            }
            .padding(.horizontal)
            .frame(height: 44)
            .font(.headline)
            Form {
                Section {
                    Text(viewModel.supervisor.member.fullName)
                        .font(.title2)
                    Picker("Role", selection: $viewModel.role) {
                        ForEach(Supervisor.Role.allCases) { role in
                            Text(role.rawValue.capitalized)
                        }
                    }
//                    Button {
//                        
//                    } label: {
//                        Label("Telegram", systemImage: "paperplane")
//                    }
//                    Button {
//                        
//                    } label: {
//                        Label("Instagram", systemImage: "paperplane")
//                    }
                }
                Button {
                    removalConfirmation = true
                } label: {
                    Label("Delete", systemImage: "trash")
                }
                .foregroundColor(.red)
            }
            .confirmationDialog("Please confirm supervisor removal", isPresented: $removalConfirmation, titleVisibility: .visible) {
                Button("Confrim", role: .destructive) {
                    delete(viewModel.supervisor)
                    dismiss()
                }
                Button("Cancel", role: .cancel) {}
            }
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
