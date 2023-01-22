//
//  NewEventView.swift
//  MembersOf
//
//  Created by Ravil Khusainov on 8/5/22.
//

import SwiftUI

struct NewEventView: View {
    
    @StateObject var viewModel: ViewModel
    @Environment(\.dismiss) private var dismiss
    @FocusState private var nameFocus
    
    var body: some View {
        NavigationStack {
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
                                NewTeamView(viewModel: .init(viewModel.signer), team: $viewModel.team)
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
                                    Text(team.name).tag(team)
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
                        Menu {
                            NavigationLink {
                                NewTeamView(viewModel: .init(viewModel.signer), team: $viewModel.team)
                            } label: {
                                Label("Team", systemImage: "person.3")
                            }
                            NavigationLink {
                                NewMembershipView(viewModel: .init(team: viewModel.team, signer: viewModel.signer))
                            } label: {
                                Label("Membership", systemImage: "creditcard")
                            }
                        } label: {
                            Label("Add", systemImage: "plus")
                        }
                    }
                }
            }
            .onChange(of: viewModel.team) { _ in
                viewModel.fetchMemberships()
            }
            .navigationTitle("Event")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(.visible, for: .navigationBar)
            #endif
            .toolbar {
                ToolbarItem {
                    Button("Create") {
                        viewModel.create()
                        dismiss()
                    }
                    .disabled(!viewModel.canCreate)
                }
            }
            .onAppear {
                nameFocus.toggle()
                // NOTE: changing date picker minute interval
                #if os(iOS)
                UIDatePicker.appearance().minuteInterval = 5
                #endif
            }
        }
    }
}

//struct NewEventView_Previews: PreviewProvider {
//    static var previews: some View {
//        NewEventView(viewModel: .init(.init(.init("CoreModel"))))
//    }
//}
