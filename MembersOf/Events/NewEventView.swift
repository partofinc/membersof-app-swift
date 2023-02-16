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
                    Picker("Schedule", selection: $viewModel.schedule) {
                        ForEach(viewModel.scheduled, id: \.self) { sched in
                            Text(sched.name).tag(sched)
                        }
                    }
                }
                NewTeamSectionView(
                    signer: viewModel.signer,
                    teams: $viewModel.teams,
                    team: $viewModel.team,
                    places: $viewModel.places,
                    place: $viewModel.place,
                    memberships: $viewModel.memberships,
                    selectedMemberships: $viewModel.selectedMemberships
                )
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
