//
//  ScheduleRow.swift
//  MembersOf
//
//  Created by Ravil Khusainov on 2023-01-30.
//

import SwiftUI

struct ScheduleRow: View {
    
    let schedule: Schedule
    let timing: [(String, Date, Date)]
    
    init(schedule: Schedule) {
        self.schedule = schedule
        var tm: [(String, Date, Date)] = []
        let start = Calendar.localized.startOfDay(for: .now)
        for rep in schedule.repeats {
            guard let day = Calendar.localized.weekdaySymbol(by: rep.weekday) else { continue }
            tm.append((day, start.addingTimeInterval(rep.start), start.addingTimeInterval(rep.start + rep.duration)))
        }
        self.timing = tm
    }
    
    var body: some View {
        GroupBox {
            HStack(alignment: .bottom) {
                VStack(alignment: .leading) {
                    ForEach(timing, id: \.0) { (day, start, end) in
                        Text("\(day) \(start...end)")
                    }
                }
                Spacer()
                Image(systemName: "mappin")
                    .font(.footnote)
                Text("Migros MMM")
                    .font(.footnote)
            }
        } label: {
            HStack {
                Text(schedule.name)
                Spacer()
                Text("Kimura Jiu Jitsu")
            }
        }
    }
}

struct ScheduleRow_Previews: PreviewProvider {
    static var previews: some View {
        ScheduleRow(schedule: .init(id: UUID(), name: "Basic GI", team: .loading, repeats: [
            .init(weekday: 1, start: 72000, duration: 7200),
            .init(weekday: 0, start: 72000, duration: 7200)],
            nearestDate: nil, memeberships: [])
        )
        .padding()
    }
}
