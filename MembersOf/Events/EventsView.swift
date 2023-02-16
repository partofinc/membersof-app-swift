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
            ScrollView {
                LazyVStack(alignment: .leading) {
                    if !viewModel.events.isEmpty {
                        ScrollView(.horizontal, showsIndicators: false) {
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
                            .padding(.bottom)
                        }
                        .frame(height: 150)
                    }
                    if !viewModel.scheduled.isEmpty {
                        Text("Schedule")
                            .font(.title)
                        ForEach(viewModel.scheduled) { sched in
                            NavigationLink {
                                VStack {
                                    Text(sched.name)
                                    Text(sched.team.name)
                                    ForEach(sched.repeats, id: \.weekday) { rep in
                                        if let day = Calendar.localized.weekdaySymbol(by: rep.weekday) {
                                            Text(day)
                                        }
                                        Text(rep.start, format: .number)
                                        Text(rep.duration, format: .number)
                                    }
                                }
                            } label: {
                                ScheduleRow(schedule: sched)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("Events")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Menu {
                        Button {
                            sheet = .event
                        } label: {
                            Label("Event", systemImage: "calendar.day.timeline.left")
                        }
                        Button {
                            sheet = .schedule
                        } label: {
                            Label("Schedule", systemImage: "calendar")
                        }
                    } label: {
                        Image(systemName: "plus")
                    }
                }
                ToolbarItem(placement: .automatic) {
                    NavigationLink {
                        Text("History")
                    } label: {
                        Image(systemName: "clock.arrow.circlepath")
                    }
                }
            }
            .sheet(item: $sheet) { sheet in
                switch sheet {
                case .event:
                    NewEventView(viewModel: .init(viewModel.signer))
                case .schedule:
                    NewScheduleView(viewModel: .init(signer: viewModel.signer))
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
