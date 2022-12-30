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
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundColor(.accentColor)
            .primaryButtonStyle(padding: padding, cornerRadius: cornerRadius, maxWidth: maxWidth)
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
    
    @ViewBuilder
    func primaryButtonStyle(padding: CGFloat?, cornerRadius: CGFloat, maxWidth: CGFloat? = nil) -> some View {
        let bg = RoundedRectangle(cornerRadius: cornerRadius)
            .fill(Color.primaryButtonColor.gradient)
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
        Button(action: { print("Pressed") }) {
            Label("Press Me", systemImage: "star")
        }
        .buttonStyle(.plain)
    }
}
