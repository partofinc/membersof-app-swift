//
//  EventsView.swift
//  MembersOf
//
//  Created by Ravil Khusainov on 8/5/22.
//

import SwiftUI
import Models

struct EventsView: View {
    
    @StateObject var viewModel: ViewModel
    @State private var sheet: Sheet?
    @State private var event: Event?
    
    var body: some View {
        NavigationStack {
            VStack {
                ScrollView(.horizontal) {
                    LazyHStack {
                        ForEach(viewModel.events) { event in
                            NavigationLink {
                                EventDetailView(viewModel: .init(event: event, signer: viewModel.signer))
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
                
            }
            .safeAreaInset(edge: .bottom) {
                Button {
                    sheet = .new
                } label: {
                    Label("New", systemImage: "plus")
                }
                .buttonStyle(.primary)
                .padding()
            }
            .navigationTitle("Events")
            .sheet(item: $sheet) { sheet in
                switch sheet {
                case .new:
                    NewEventView(viewModel: .init(viewModel.signer))
                        .presentationDetents([.medium, .large])
                }
            }
            .animation(.easeInOut, value: viewModel.events)
        }
    }
}

struct EventsView_Previews: PreviewProvider {
    static var previews: some View {
        EventsView(viewModel: .init(PreviewSigner(storage: CoreDataStorage("CoreModel"))))
    }
}
