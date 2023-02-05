//
//  NewScheduleView.swift
//  MembersOf
//
//  Created by Ravil Khusainov on 2023-01-30.
//

import SwiftUI

struct NewScheduleView: View {
    
    @State var name: String = ""
    @State var days: [String] = Calendar.localized.localizedWeekdaySymbols
    @State var selectedDays: Set<String> = []
    @State var startDate: Date = .now
    @State var endDate: Date = .now
    @Environment(\.dismiss) var dismiss
    
    let storage: Storage
    
    var body: some View {
        Form {
            TextField("Name", text: $name)
            Section("Day") {
                ForEach(days, id: \.self) { day in
                    HStack {
                        Button {
                            if selectedDays.contains(day) {
                                selectedDays.remove(day)
                            } else {
                                selectedDays.insert(day)
                            }
                        } label: {
                            Label(day, systemImage: selectedDays.contains(day) ? "checkmark.circle.fill" : "circle")
                        }
                    }
                    if selectedDays.contains(day) {
                        HStack {
                            DatePicker("Start time", selection: $startDate, displayedComponents: [.hourAndMinute])
                                .labelsHidden()
                            Spacer()
                            Text("2 hours")
                            Spacer()
                            DatePicker("End time", selection: $startDate, displayedComponents: [.hourAndMinute])
                                .labelsHidden()
                        }
                    }
                }
            }
        }
        .safeAreaInset(edge: .bottom) {
            Button("Save") {
                Task {
                    let repeats = selectedDays.compactMap(rep(for:))
                    let sched = Schedule(id: UUID(), name: name, location: "Old Scool", team: "Kimura Jiu Jitsu", repeats: repeats, nearestDate: nil)
                    try await storage.save(sched)
                }
                dismiss()
            }
            .buttonStyle(.primary)
            .padding()
        }
    }
    
    func rep(for day: String) -> Schedule.Repeat? {
        guard let idx = Calendar.localized.indexOfWeek(day: day) else { return nil }
        return .init(weekday: idx, start: "20:00", end: "22:00")
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
