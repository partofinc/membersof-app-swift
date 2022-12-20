//
//  EditViewModifier.swift
//  MembersOf
//
//  Created by Ravil Khusainov on 2022-12-19.
//

import SwiftUI

struct EditViewModifier<Value: View>: ViewModifier {
    
    @Binding var editMode: Bool
    let editView: Value
    
    func body(content: Content) -> some View {
        if editMode {
            editView
        } else {
            content
        }
    }
}

extension View {
    
    func edit(_ editMode: Binding<Bool>, content: () -> some View) -> some View {
        self.modifier(EditViewModifier(editMode: editMode, editView: content()))
    }
}
