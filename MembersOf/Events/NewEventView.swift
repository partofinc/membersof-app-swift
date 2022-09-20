//
//  NewEventView.swift
//  MembersOf
//
//  Created by Ravil Khusainov on 8/5/22.
//

import SwiftUI

struct NewEventView: View {
    
    @StateObject private var viewModel: ViewModel = .init()
    @Environment(\.dismiss) private var dismiss
    @FocusState private var nameFocus
    
    var body: some View {
        VStack {
            Form {
                Section {
                    TextField("Name", text: $viewModel.name)
                        .focused($nameFocus)
                    DatePicker("Start", selection: $viewModel.startDate)
                        .onChange(of: viewModel.startDate) { date in
                            viewModel.startChanged(date: date)
                        }
                    if viewModel.endDefined {
                        DatePicker("End", selection: $viewModel.endDate, in: viewModel.startDate...)
                            .onChange(of: viewModel.endDate) { date in
                                viewModel.endChanged(date: date)
                            }
                        Stepper(viewModel.durationTitle, value: $viewModel.duration, step: 30*60, onEditingChanged: { _ in
                            viewModel.durationChanged()
                        })
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
                        Picker("Team", selection: $viewModel.team) {
                            ForEach(viewModel.teams, id: \.self) { team in
                                Text(team.name).tag(team.id)
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
                        NewMembershipView(viewModel: .init())
                    } label: {
                        Label("Add", systemImage: "plus")
                    }
                }
            }
        }
        .onChange(of: viewModel.team) { _ in
            viewModel.teamChanged()
        }
        .onChange(of: viewModel.teams) { _ in
            viewModel.teamChanged()
        }
        .onChange(of: viewModel.me) { _ in
            viewModel.fetchTeams()
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
        .onAppear {
            nameFocus.toggle()
            // NOTE: changing date picker minute interval
            UIDatePicker.appearance().minuteInterval = 5
        }
    }
}

struct NewEventView_Previews: PreviewProvider {
    static var previews: some View {
        NewEventView()
    }
}
