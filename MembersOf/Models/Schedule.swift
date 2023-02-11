//
//  Schedule.swift
//  MembersOf
//
//  Created by Ravil Khusainov on 2023-01-30.
//

import Foundation

public struct Schedule: Codable, Hashable, Identifiable {
    
    public let id: UUID
    public let name: String
    public let location: String
    public let team: String
    public let repeats: [Repeat]
    public var nearestDate: Date?
    
    init(id: UUID, name: String, location: String, team: String, repeats: [Repeat], nearestDate: Date?) {
        self.id = id
        self.name = name
        self.location = location
        self.team = team
        self.repeats = repeats
        self.nearestDate = nearestDate
        if nearestDate == nil {
            calculateNearestDate()
        }
    }
    
    mutating private func calculateNearestDate() {
        var components = Calendar.localized.dateComponents([.year, .month, .day, .weekday, .hour, .minute], from: .now)
    
        var hours: Int = 0
        var minutes: Int = 0
        var daysToAdd: Int = 14
        
        let weekday: Int
        if let c = components.weekday {
            weekday = c - 1
        } else {
            weekday = 0
        }
        
        func parse(hours: inout Int, minutes: inout Int, from time: String) {
            let array = time.components(separatedBy: ":").compactMap(Int.init)
            guard array.count == 2 else { return }
            hours = array[0]
            minutes = array[1]
        }

        for rep in repeats {
            let day = rep.weekday
            let time = rep.start
            
            if day == weekday {
                daysToAdd = 0
                parse(hours: &hours, minutes: &minutes, from: time)
                let t = String(format: "%d:%02d", components.hour!, components.minute!)
                print(t)
                if time > t {
                    break
                } else {
                    daysToAdd = 14
                }
            }
            if day > weekday {
                daysToAdd = day - weekday
                parse(hours: &hours, minutes: &minutes, from: time)
                break
            }
            if day < weekday {
                let toAdd = day + 7 - weekday
                guard toAdd < daysToAdd else { continue }
                daysToAdd = toAdd
                parse(hours: &hours, minutes: &minutes, from: time)
                continue
            }
        }
        
        components.day = components.day! + daysToAdd
        components.hour = hours
        components.minute = minutes
        
        self.nearestDate = Calendar.current.date(from: components)
    }
}

extension Schedule {
     
    public struct Repeat: Codable, Hashable {
        
        public let weekday: Int
        public let start: String // HH:mm
        public let end: String
    }
}
