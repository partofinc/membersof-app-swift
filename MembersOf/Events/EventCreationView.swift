//
//  EventCreationView.swift
//  MembersOf
//
//  Created by Ravil Khusainov on 2023-01-30.
//

import SwiftUI
import Models

struct EventCreationView: View {
    
    @State private var creation: Event.Creation = .event
    @Environment(\.dismiss) private var dismiss
    let signer: any Signer
    
    var body: some View {
        NavigationStack {
            Group {
                switch creation {
                case .event:
                    NewEventView(viewModel: .init(signer))
                case .schedule:
                    NewScheduleView(storage: signer.storage)
                }
            }
            .navigationTitle(creation.rawValue.capitalized)
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(.visible, for: .navigationBar)
            #endif
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .principal) {
                    Picker("Event type", selection: $creation) {
                        Text("Event").tag(Event.Creation.event)
                        Text("Schedule").tag(Event.Creation.schedule)
                    }
                    .pickerStyle(.segmented)
                }
                ToolbarItem(placement: .primaryAction) {
                    Button("Create") {
                        //            viewModel.create()
                        dismiss()
                    }
                    //        .disabled(!viewModel.canCreate)
                }
            }
        }
    }
}

//struct EventCreationView_Previews: PreviewProvider {
//    static var previews: some View {
//        EventCreationView()
//    }
//}
