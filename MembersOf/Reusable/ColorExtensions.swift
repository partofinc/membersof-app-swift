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

extension LinearGradient {
    
    static func primary(colorScheme: ColorScheme) -> Self {
        switch colorScheme {
        case .dark:
            return .init(colors: [.indigo, .blue], startPoint: .bottomLeading, endPoint: .topTrailing)
        case .light:
            return .init(colors: [.cyan, .teal], startPoint: .bottomLeading, endPoint: .topTrailing)
        @unknown default:
            return .init(colors: [.teal, .blue], startPoint: .bottomLeading, endPoint: .topTrailing)
        }
        
    }
}
