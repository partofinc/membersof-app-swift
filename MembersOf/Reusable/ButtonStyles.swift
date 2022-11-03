//
//  ButtonStyles.swift
//  MembersOf
//
//  Created by Ravil Khusainov on 2022-11-03.
//

import SwiftUI

struct PrimaryButtonStyle: ButtonStyle {
    
    let padding: CGFloat
    let cornerRadius: CGFloat
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundColor(.accentColor)
            .primaryButtonStyle(padding: padding, cornerRadius: cornerRadius)
            .opacity(configuration.isPressed ? 0.2 : 1)
    }
}

extension ButtonStyle where Self == PrimaryButtonStyle {
    static var primarySmall: PrimaryButtonStyle {
        .init(padding: 6, cornerRadius: 8)
    }
}

struct PrimaryMenuStyle: MenuStyle {
    
    let padding: CGFloat
    let cornerRadius: CGFloat
    
    func makeBody(configuration: Configuration) -> some View {
        Menu(configuration)
            .primaryButtonStyle(padding: padding, cornerRadius: cornerRadius)
    }
}

extension MenuStyle where Self == PrimaryMenuStyle {
    static var primarySmall: PrimaryMenuStyle {
        .init(padding: 6, cornerRadius: 8)
    }
}


private extension View {
    func primaryButtonStyle(padding: CGFloat, cornerRadius: CGFloat) -> some View {
        self
            .padding(padding)
            .background(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(Color.accentColor.gradient.opacity(0.1))
                    .shadow(radius: 3)
            )
    }
}

struct SecondaryActive_Previews: PreviewProvider {
    static var previews: some View {
        Button(action: { print("Pressed") }) {
            Label("Press Me", systemImage: "star")
        }
        .buttonStyle(.plain)
    }
}
