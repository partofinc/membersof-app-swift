//
//  Schedule.swift
//  MembersOf
//
//  Created by Ravil Khusainov on 2023-01-30.
//

import Foundation
import Models
import SwiftDate

public struct Schedule: Codable, Hashable, Identifiable {
    
    public let id: UUID
    public let name: String
    public let team: Team
    public let repeats: [Repeat]
    public var nearestDate: Date?
    public let memberships: [Membership]
    
    init(id: UUID, name: String, team: Team, repeats: [Repeat], nearestDate: Date?, memeberships: [Membership]) {
        self.id = id
        self.name = name
        self.team = team
        self.repeats = repeats
        self.nearestDate = nearestDate
        self.memberships = memeberships
        if nearestDate == nil {
            calculateNearestDate()
        }
    }
    
    mutating private func calculateNearestDate() {
        let curentDate: Date = .now
        let startOfDay: Date = Calendar.localized.startOfDay(for: curentDate)
        let secondsFromDayStart = curentDate.timeIntervalSince(startOfDay)
        
        let components = Calendar.localized.dateComponents([.year, .month, .day, .weekday, .hour, .minute], from: .now)
    
        var daysToAdd: Int = 14
        var timeToAdd = secondsFromDayStart
        
        let weekday: Int
        if let c = components.weekday {
            weekday = c - 1
        } else {
            weekday = 0
        }

        for rep in repeats {
            let day = rep.weekday
            let time = rep.start
            
            if day == weekday {
                daysToAdd = 0
                if time > secondsFromDayStart {
                    timeToAdd = time
                    break
                } else {
                    daysToAdd = 14
                }
            }
            if day > weekday {
                daysToAdd = day - weekday
                timeToAdd = time
                break
            }
            if day < weekday {
                let toAdd = day + 7 - weekday
                guard toAdd < daysToAdd else { continue }
                daysToAdd = toAdd
                timeToAdd = time
                continue
            }
        }
        
        self.nearestDate = startOfDay.addingTimeInterval(daysToAdd.days.timeInterval + timeToAdd)
    }
}

extension Schedule {
     
    public struct Repeat: Codable, Hashable {
        
        public let weekday: Int
        public let start: TimeInterval
        public let duration: TimeInterval
    }
}
