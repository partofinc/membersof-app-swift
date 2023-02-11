//
//  NewScheduleView.swift
//  MembersOf
//
//  Created by Ravil Khusainov on 2023-01-30.
//

import SwiftUI

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
                            HStack {
                                DatePicker("Start time", selection: binding(for: day).0, displayedComponents: [.hourAndMinute])
                                    .labelsHidden()
                                Spacer()
                                Text("2 hours")
                                Spacer()
                                DatePicker("End time", selection: binding(for: day).1, displayedComponents: [.hourAndMinute])
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
    
    func rep(for day: String) -> Schedule.Repeat? {
        guard let idx = Calendar.localized.indexOfWeek(day: day) else { return nil }
        return .init(weekday: idx, start: "20:00", end: "22:00")
    }
    
    private func binding(for day: String) -> Binding<(Date, Date)> {
        Binding(
            get: {
                return viewModel.dates[day] ?? (.now, .now)
            },
            set: {
                viewModel.dates[day] = $0
            }
        )
    }
}

//struct NewScheduleView_Previews: PreviewProvider {
//    static var previews: some View {
//        NewScheduleView()
//    }
//}


extension Calendar {
    
    static var localized: Self {
        var cal = Self.current
        cal.locale = .autoupdatingCurrent
        return cal
    }
    
    var localizedWeekdaySymbols: [String] {
        Array(weekdaySymbols.rotatingLeft(positions: firstWeekday - 1))
    }
    
    func indexOfWeek(day: String) -> Int? {
        weekdaySymbols.firstIndex(of: day)
    }
    
    func weekdaySymbol(by index: Int) -> String? {
        guard weekdaySymbols.indices.contains(index) else { return nil }
        return weekdaySymbols[index]
    }
}

extension RangeReplaceableCollection {
    
    func rotatingLeft(positions: Int) -> SubSequence {
        let index = self.index(startIndex, offsetBy: positions, limitedBy: endIndex) ?? endIndex
        return self[index...] + self[..<index]
    }
    
    mutating func rotateLeft(positions: Int) {
        let index = self.index(startIndex, offsetBy: positions, limitedBy: endIndex) ?? endIndex
        let slice = self[..<index]
        removeSubrange(..<index)
        insert(contentsOf: slice, at: endIndex)
    }
    
    func rotatingRight(positions: Int) -> SubSequence {
        let index = self.index(endIndex, offsetBy: -positions, limitedBy: startIndex) ?? startIndex
        return self[index...] + self[..<index]
    }
    
    mutating func rotateRight(positions: Int) {
        let index = self.index(endIndex, offsetBy: -positions, limitedBy: startIndex) ?? startIndex
        let slice = self[index...]
        removeSubrange(index...)
        insert(contentsOf: slice, at: startIndex)
    }
}
