//
//  EventsView.swift
//  MembersOf
//
//  Created by Ravil Khusainov on 8/5/22.
//

import SwiftUI

struct EventsView: View {
    
    @StateObject var viewModel: ViewModel = .init()
    @State private var sheet: Sheet?
    @State private var path: [Event] = []
    
    var body: some View {
        NavigationStack(path: $path) {
            VStack {
                HStack {
                    ForEach(viewModel.events) { event in
                        EventRow(event: event)
                            .onTapGesture {
                                path = [event]
                            }
                    }
                }
                .navigationDestination(for: Event.self) {
                    EventDetailView(viewModel: .init(event: $0))
                }
                .frame(height: 100)
                .padding()
                Spacer()
                Button {
                    sheet = .new
                } label: {
                    Label("New", systemImage: "plus")
                }
                .padding()
            }
            .navigationTitle("Events")
            .sheet(item: $sheet) { sheet in
                switch sheet {
                case .new:
                    NewEventView()
                        .presentationDetents([.medium])
                }
            }
            .animation(.easeInOut, value: viewModel.events)
        }
    }
}

struct EventsView_Previews: PreviewProvider {
    static var previews: some View {
        EventsView()
    }
}