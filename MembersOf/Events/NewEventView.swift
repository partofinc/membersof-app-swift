//
//  NewEventView.swift
//  MembersOf
//
//  Created by Ravil Khusainov on 8/5/22.
//

import SwiftUI

struct NewEventView: View {
    
    @StateObject fileprivate var viewModel: ViewModel = .init()
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack {
            HStack {
                Text("Event")
                Spacer()
                Button("Create") {
                    viewModel.create()
                    dismiss()
                }
            }
            .padding(.horizontal)
            .frame(height: 44)
            .font(.headline)
            Form {
                HStack {
                    Text("Name")
                    TextField("No name", text: $viewModel.name)
                        .multilineTextAlignment(.trailing)
                }
                Section {
                    Picker("Team", selection: $viewModel.teamIndex) {
                        ForEach(0..<viewModel.teams.count, id: \.self) { idx in
                            Text(viewModel.teams[idx].name).tag(idx)
                        }
                    }
                    HStack {
                        Text("Memberships")
                        Spacer()
                        Button("All") {
                            viewModel.selectMemberships()
                        }
                        .buttonStyle(.plain)
                        .foregroundColor(.accentColor)
                        Text("|")
                        Button("None") {
                            viewModel.deselectMemberships()
                        }
                        .buttonStyle(.plain)
                        .foregroundColor(.accentColor)
                    }
                    ForEach(viewModel.memberships) { ship in
                        Button {
                            viewModel.toggle(ship)
                        } label: {
                            Label(ship.name, systemImage: viewModel.isSelected(ship) ? "checkmark.circle.fill" : "circle")
                        }
                    }
                }
            }
        }
        .onChange(of: viewModel.teamIndex) { _ in
            viewModel.teamChanged()
        }
        .onChange(of: viewModel.teams) { _ in
            viewModel.teamChanged()
        }
    }
}

struct NewEventView_Previews: PreviewProvider {
    static var previews: some View {
        NewEventView()
    }
}
