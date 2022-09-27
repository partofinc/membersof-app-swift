//
//  EventEditViwModel.swift
//  MembersOf
//
//  Created by Ravil Khusainov on 9/27/22.
//

import Foundation

extension EventEditView {
    
    @MainActor
    final class ViewModel: ObservableObject {
        
        let event: Event
        
        @Published var name: String
        
        init(event: Event) {
            self.event = event
            self.name = event.name
        }
    }
}
