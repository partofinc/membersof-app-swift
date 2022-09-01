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
            Form {
                Section {
                    TextField("Name", text: $viewModel.name)
                    DatePicker("Start", selection: $viewModel.startDate)
                        .onChange(of: viewModel.startDate) { _ in
                            viewModel.calculateDuration()
                        }
                    if viewModel.endDefined {
                        DatePicker("End", selection: $viewModel.startDate)
                            .onChange(of: viewModel.startDate) { _ in
                                viewModel.calculateDuration()
                            }
                        Stepper(viewModel.durationTitle, value: $viewModel.duration)
                    } else {
                        Button {
                            viewModel.endDefined.toggle()
                        } label: {
                            Label("End", systemImage: "plus")
                        }
                    }
                }
                Section {
                    if viewModel.teams.isEmpty {
                        NavigationLink {
                            NewTeamView()
                        } label: {
                            HStack {
                                Text("Team")
                                Spacer()
                                Text("New")
                                    .foregroundColor(.accentColor)
                            }
                        }
                    } else {
                        Picker("Team", selection: $viewModel.teamIndex) {
                            ForEach(0..<viewModel.teams.count, id: \.self) { idx in
                                Text(viewModel.teams[idx].name).tag(idx)
                            }
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
                    NavigationLink {
                        NewMembershipView(viewModel: .init(viewModel.selectedTeam))
                    } label: {
                        Label("Add", systemImage: "plus")
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
        .navigationTitle("Event")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem {
                Button("Create") {
                    viewModel.create()
                    dismiss()
                }
                .disabled(!viewModel.canCreate)
            }
        }
        .toolbarBackground(.visible, for: .navigationBar)
    }
}

struct NewEventView_Previews: PreviewProvider {
    static var previews: some View {
        NewEventView()
    }
}
