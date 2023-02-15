//
//  ConvenienceExtensions.swift
//  MembersOf
//
//  Created by Ravil Khusainov on 15.02.2023.
//

import Foundation

extension Date {
    //Update only the Date part (Not toucing time)
    func changing(date: Date) -> Date? {
        let calendar = Calendar.current
        var comp = calendar.dateComponents([.day, .month, .year], from: date)
        let hm = calendar.dateComponents([.hour, .minute], from: self)
        comp.hour = hm.hour
        comp.minute = hm.minute
        guard let date = calendar.date(from: comp) else { return nil }
        return date
    }
}
