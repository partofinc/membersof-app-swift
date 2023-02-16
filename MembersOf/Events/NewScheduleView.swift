//
//  NewScheduleView.swift
//  MembersOf
//
//  Created by Ravil Khusainov on 2023-01-30.
//

import SwiftUI
import SwiftDate

struct NewScheduleView: View {
    
    @StateObject var viewModel: ViewModel
    @Environment(\.dismiss) private var dismiss
    @FocusState private var nameFocus
        
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Name", text: $viewModel.name)
#if os(iOS)
                        .focused($nameFocus)
#endif
                    ForEach(viewModel.days, id: \.self) { day in
                        HStack {
                            Button {
                                viewModel.toggle(day)
                            } label: {
                                Label(day, systemImage: viewModel.isSelected(day) ? "checkmark.circle.fill" : "circle")
                            }
                        }
                        if viewModel.isSelected(day) {
                            let (start, end) = viewModel.dates[day]!
                            HStack {
                                DatePicker("Start time", selection: viewModel.binding(for: day).0, displayedComponents: [.hourAndMinute])
                                    .labelsHidden()
                                Spacer()
                                Text(start..<end, format: .components(style: .condensedAbbreviated))
                                Spacer()
                                DatePicker("End time", selection: viewModel.binding(for: day).1, in: start.addingTimeInterval(10.minutes.timeInterval)..., displayedComponents: [.hourAndMinute])
                                    .labelsHidden()
                            }
                        }
                    }
                }
                Section {
                    Picker("Team", selection: $viewModel.team) {
                        ForEach(viewModel.teams, id: \.self) { team in
                            Text(team.name).tag(team)
                        }
                    }
                    Picker("Place", selection: $viewModel.place) {
                        ForEach(viewModel.places, id: \.self) { place in
                            Text(place.name).tag(place)
                        }
                    }
                    Text("Memberships")
                    Button {
                        
                    } label: {
                        Label("Add", systemImage: "plus")
                    }
                }
            }
            .navigationTitle("Schedule")
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

//struct NewScheduleView_Previews: PreviewProvider {
//    static var previews: some View {
//        NewScheduleView()
//    }
//}


