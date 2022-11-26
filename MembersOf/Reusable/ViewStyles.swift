//
//  ViewStyles.swift
//  MembersOf
//
//  Created by Ravil Khusainov on 2022-11-04.
//

import SwiftUI

extension View {
    func cardStyle() -> some View {
        self
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.systemBackground)
                .shadow(color: .primary.opacity(0.12), radius: 3, y: 1)
        )
    }
}

