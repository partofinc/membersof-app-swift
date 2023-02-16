//
//  ScheduleRow.swift
//  MembersOf
//
//  Created by Ravil Khusainov on 2023-01-30.
//

import SwiftUI

struct ScheduleRow: View {
    
    let schedule: Schedule
    let timing: [String]
    
    init(schedule: Schedule) {
        self.schedule = schedule
        var tm: [String] = []
        for rep in schedule.repeats {
            guard let day = Calendar.localized.weekdaySymbol(by: rep.weekday) else { continue }
            tm.append("\(day) \(rep.start)-\(rep.end)")
        }
        self.timing = tm
    }
    
    var body: some View {
        GroupBox {
            HStack(alignment: .bottom) {
                VStack(alignment: .leading) {
                    ForEach(timing, id: \.self) { time in
                        Text(time)
                    }
                }
                Spacer()
                Image(systemName: "mappin")
                    .font(.footnote)
            }
        } label: {
            HStack {
                Text(schedule.name)
                Spacer()
            }
        }
    }
}

//struct ScheduleRow_Previews: PreviewProvider {
//    static var previews: some View {
//        ScheduleRow(schedule: .init(id: UUID(), name: "Basic GI", location: "Migros MMM", team: "Kimura Jiu Jitsu", repeats: [
//            .init(weekday: 1, start: "20:00", end: "22:00"),
//            .init(weekday: 0, start: "20:00", end: "22:00")],
//            nearestDate: nil)
//        )
//    }
//}
