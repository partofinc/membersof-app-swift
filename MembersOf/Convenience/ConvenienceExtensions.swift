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

