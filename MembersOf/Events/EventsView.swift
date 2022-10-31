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
    @State private var event: Event?
    
    var body: some View {
        NavigationStack {
            VStack {
                ScrollView(.horizontal) {
                    LazyHStack {
                        ForEach(viewModel.events) { event in
                            NavigationLink {
                                EventDetailView(viewModel: .init(event: event))
                            } label: {
                                EventRow(event: event)
                            }
                            .buttonStyle(.plain)
                            .frame(minWidth: 150)
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
                    NewEventView()
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
