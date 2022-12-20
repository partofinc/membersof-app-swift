//
//  EditButton.swift
//  MembersOf
//
//  Created by Ravil Khusainov on 2022-12-19.
//

import SwiftUI

struct EditButton: View {
    
    @Binding var editMode: Bool
    
    var body: some View {
        Button(editMode ? "Cancel" : "Edit") {
            editMode.toggle()
        }
    }
}

