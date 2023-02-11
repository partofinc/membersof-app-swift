//
//  Operators.swift
//  MembersOf
//
//  Created by Ravil Khusainov on 2023-01-22.
//

import Foundation

infix operator ~~

func ==<T, V: Equatable>(lhs: KeyPath<T, V>, rhs: V) -> (T) -> Bool {
    return { $0[keyPath: lhs] == rhs }
}

func ~~<T>(lhs: KeyPath<T, String>, rhs: String) -> (T) -> Bool {
    return { $0[keyPath: lhs].localizedCaseInsensitiveContains(rhs) }
}
