//
//  ColorExtensions.swift
//  MembersOf
//
//  Created by Ravil Khusainov on 2022-11-04.
//

#if os(iOS)
import UIKit
#else
import AppKit
#endif
import SwiftUI

extension Color {
    static var systemBackground: Color {
        #if os(iOS)
        .init(uiColor: .systemBackground)
        #else
        .init(nsColor: .black)
        #endif
    }
    static var primaryButtonColor: Color {
        .init("PrimaryButtonColor")
    }
}
