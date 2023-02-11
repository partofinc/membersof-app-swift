//
//  ButtonStyles.swift
//  MembersOf
//
//  Created by Ravil Khusainov on 2022-11-03.
//

import SwiftUI

struct PrimaryButtonStyle: ButtonStyle {
    
    let padding: CGFloat?
    let cornerRadius: CGFloat
    let maxWidth: CGFloat?
    
    @Environment(\.colorScheme) var colorScheme
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundColor(.white)
            .bold()
            .primaryButtonStyle(padding: padding, cornerRadius: cornerRadius, maxWidth: maxWidth, colorScheme: colorScheme)
            .opacity(configuration.isPressed ? 0.2 : 1)
    }
}

extension ButtonStyle where Self == PrimaryButtonStyle {
    static var primarySmall: PrimaryButtonStyle {
        .init(padding: 6, cornerRadius: 4, maxWidth: nil)
    }
    
    static var primary: PrimaryButtonStyle {
        .init(padding: nil, cornerRadius: 6, maxWidth: .infinity)
    }
}

struct PrimaryMenuStyle: MenuStyle {
    
    let padding: CGFloat?
    let cornerRadius: CGFloat
    let maxWidth: CGFloat?
    
    @Environment(\.colorScheme) var colorScheme
    
    func makeBody(configuration: Configuration) -> some View {
        Menu(configuration)
            .foregroundColor(.white)
            .bold()
            .primaryButtonStyle(padding: padding, cornerRadius: cornerRadius, maxWidth: maxWidth, colorScheme: colorScheme)
    }
}

extension MenuStyle where Self == PrimaryMenuStyle {
    static var primarySmall: PrimaryMenuStyle {
        .init(padding: 6, cornerRadius: 4, maxWidth: nil)
    }
    
    static var primary: PrimaryMenuStyle {
        .init(padding: nil, cornerRadius: 6, maxWidth: .infinity)
    }
}


private extension View {
    
    @ViewBuilder
    func primaryButtonStyle(padding: CGFloat?, cornerRadius: CGFloat, maxWidth: CGFloat? = nil, colorScheme: ColorScheme = .dark) -> some View {
        let bg = RoundedRectangle(cornerRadius: cornerRadius)
            .fill(LinearGradient.primary(colorScheme: colorScheme))
        if let padding {
            self
                .padding(padding)
                .frame(maxWidth: maxWidth)
                .background(bg)
        } else {
            self
                .padding(.horizontal)
                .padding(.vertical, 10)
                .frame(maxWidth: maxWidth)
                .background(bg)
        }
    }
}

struct SecondaryActive_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            Button(action: { print("Pressed") }) {
                Label("Press Me", systemImage: "star")
            }
            .buttonStyle(.primary)
            .padding()
        }
    }
}
