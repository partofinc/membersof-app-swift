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
                ScrollView(.horizontal) {
                    LazyHStack {
                        ForEach(viewModel.events) { event in
                            EventRow(event: event)
                                .frame(minWidth: 150)
                                .onTapGesture {
                                    path = [event]
                                }
                                .contextMenu {
                                    Button(role: .destructive) {
                                        viewModel.delete(event)
                                    } label: {
                                        Label("Delete", systemImage: "trash")
                                    }
                                }
                        }
                    }
                    .padding()
                }
                .navigationDestination(for: Event.self) {
                    EventDetailView(viewModel: .init(event: $0))
                }
                .frame(height: 150)
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
                    NavigationStack {
                        NewEventView()
                    }
                    .presentationDetents([.medium, .large])
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
