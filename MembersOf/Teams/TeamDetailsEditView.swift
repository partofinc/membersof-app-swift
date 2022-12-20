//
//  TeamDetailsEditView.swift
//  MembersOf
//
//  Created by Ravil Khusainov on 2022-12-20.
//

import SwiftUI

struct TeamDetailsEditView: View {
    
    @StateObject var viewModel: ViewModel
    @Binding var editMode: Bool
    
    @State private var sheet: Sheet?
    @FocusState private var addingSocial: Bool
    
    
    var body: some View {
        Form {
            Section {
                TextField("Name", text: $viewModel.name)
                TextField("Introduction", text: $viewModel.brief, axis: .vertical)
            }
            Section("Social media") {
                Button {
                    
                } label: {
                    Label("Add", systemImage: "plus")
                }
            }
            Section("Crew") {
                Button {
                    
                } label: {
                    Label("Add", systemImage: "plus")
                }
            }
            Section("") {
                Button(role: .destructive) {
                    
                } label: {
                    Label("Delete", systemImage: "trash")
                }
            }
        }
        .safeAreaInset(edge: .bottom) {
            Button {
                editMode.toggle()
            } label: {
                Text("Save")
            }
            .buttonStyle(.primary)
            .padding()
        }
        .sheet(item: $sheet) { sheet in
            switch sheet {
            case .supervisor(let supervisor):
                SupervisorView(viewModel: .init(supervisor), save: {viewModel.update($0)}, delete: {viewModel.delete($0)})
                    .presentationDetents([.medium])
            case .newSupervisor:
                NewSupervisorView(viewModel: .init(viewModel.team, storage: viewModel.storage))
                    .presentationDetents([.medium])
            }
        }
    }
}

