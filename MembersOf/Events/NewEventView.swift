//
//  NewEventView.swift
//  MembersOf
//
//  Created by Ravil Khusainov on 8/5/22.
//

import SwiftUI
import Models

struct NewEventView: View {
    
    @StateObject var viewModel: ViewModel
    @Environment(\.dismiss) private var dismiss
    @FocusState private var nameFocus
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Name", text: $viewModel.name)
                        .focused($nameFocus)
                    DatePicker("Date", selection: $viewModel.startDate, displayedComponents: .date)
                    HStack {
                        DatePicker("Start time", selection: $viewModel.startTime, displayedComponents: [.hourAndMinute])
                            .labelsHidden()
                        Spacer()
                        Text(viewModel.durationRange, format: .components(style: .condensedAbbreviated))
                        Spacer()
                        DatePicker("End time", selection: $viewModel.endTime, in: viewModel.endTimeRange, displayedComponents: [.hourAndMinute])
                            .labelsHidden()
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
                        Picker("Schedule", selection: $viewModel.schedule) {
                            ForEach(viewModel.scheduled, id: \.self) { sched in
                                Text(sched.name).tag(sched)
                            }
                        }
                        Picker("Place", selection: $viewModel.place) {
                            ForEach(viewModel.places, id: \.self) { place in
                                Text(place.name).tag(place)
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
                        NavigationLink {
                            Text("New place")
                        } label: {
                            Label("Place", systemImage: "mappin.and.ellipse")
                        }
                    } label: {
                        Label("Add", systemImage: "plus")
                    }
                }
            }
            .navigationTitle("Event")
#if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(.visible, for: .navigationBar)
#endif
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .primaryAction) {
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

struct NewEventView_Previews: PreviewProvider {
    static let signer = PreviewSigner.default
    static var previews: some View {
        NewEventView(viewModel: .init(signer))
    }
}
