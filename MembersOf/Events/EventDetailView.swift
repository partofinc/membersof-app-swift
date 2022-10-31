//
//  EventDetailView.swift
//  MembersOf
//
//  Created by Ravil Khusainov on 8/9/22.
//

import SwiftUI

struct EventDetailView: View {
    
    @StateObject var viewModel: ViewModel
    
    @State private var endDate: Date = .now
    @State private var customDate: Date = .now
    @State private var sheet: Sheet?
    @Environment(\.editMode) private var editMode
    
    var body: some View {
        Group {
            if editMode?.wrappedValue.isEditing ?? false {
                EventEditView(viewModel: .init(event: viewModel.event), sheet: $sheet)
            } else {
                VStack {
                    ScrollView {
                        LazyVStack(alignment: .leading) {
                            timing
                            team
                            visits
                            notes
                        }
                        .padding()
                    }
                }
            }
        }
        .navigationTitle(viewModel.event.name)
        .sheet(item: $sheet) { sheet in
            switch sheet {
            case .addMember:
                SearchMembersView(viewModel: .init(viewModel.event))
                    .presentationDetents([.large])
            case .endDate:
                datePicker
                    .presentationDetents([.medium])
            case .addMembership:
                NewMembershipView(viewModel: .init())
                    .presentationDetents([.medium])
            }
        }
        .toolbar {
            EditButton()
        }
        .animation(.easeInOut, value: viewModel.visits)
    }
    
    @ViewBuilder
    private var timing: some View {
        HStack(alignment: .bottom) {
            VStack(alignment: .leading) {
                if viewModel.progress == .upcoming {
                    Text(viewModel.progress.rawValue)
                        .font(.headline)
                    Spacer()
                }
                Text(viewModel.startDate)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            VStack {
                if viewModel.progress == .ongoing {
                    Text(viewModel.progress.rawValue)
                        .font(.headline)
                    Spacer()
                }
                Text(viewModel.duration)
                    .bold()
            }
            .frame(maxWidth: .infinity)
            VStack(alignment: .trailing) {
                if viewModel.progress == .ended {
                    Text(viewModel.progress.rawValue)
                        .font(.headline)
                    Spacer()
                    Button(viewModel.endDateString) {
                        sheet = .endDate
                    }
                    .padding(6)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.accentColor.gradient.opacity(0.1))
                            .shadow(radius: 3)
                    )
                } else {
                    Menu {
                        if let date = viewModel.event.estimatedEndDate {
                            Button {
                                endDate = date
                            } label: {
                                Label("In time", systemImage: "hand.thumbsup")
                            }
                        }
                        Button {
                            endDate = .now
                        } label: {
                            Label("Now", systemImage: "hand.raised.fingers.spread")
                        }
                        Button {
                            sheet = .endDate
                        } label: {
                            Label("Date", systemImage: "calendar")
                        }
                    } label: {
                        Label("End", systemImage: "checkmark.circle")
                    }
                    .onChange(of: endDate, perform: { date in
                        viewModel.end(with: date)
                    })
                    .padding(6)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.accentColor.gradient.opacity(0.1))
                            .shadow(radius: 3)
                    )
                    Spacer()
                    Text(viewModel.endDateString)
                }
            }
            .frame(maxWidth: .infinity, alignment: .trailing)
        }
        .cardStyle()
    }
    
    @ViewBuilder
    private var team: some View {
        VStack(alignment: .leading) {
            HStack {
                Text("Memberships")
                    .font(.headline)
                Spacer()
                NavigationLink {
                    TeamDetailView(viewModel: .init(team: viewModel.event.team))
                } label: {
                    Text(viewModel.event.team.name)
                }
                .padding(6)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.accentColor.gradient.opacity(0.1))
                        .shadow(radius: 3)
                )
            }
            ForEach(viewModel.event.memberships) { ship in
                HStack {
                    Image(systemName: "largecircle.fill.circle")
                    Text(ship.name)
                    Spacer()
                }
            }
        }
        .cardStyle()
    }
    
    @ViewBuilder
    private var visits: some View {
        VStack {
            HStack {
                Text("Visits")
                Spacer()
                Text("\(viewModel.visits.count)")
            }
            .font(.headline)
            ForEach(viewModel.visits) { visit in
                HStack {
                    Text(visit.member.fullName)
                        .font(.headline)
                    Spacer()
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.purple.opacity(0.7).gradient)
                        .shadow(radius: 3)
                )
                .contextMenu {
                    Button(role: .destructive) {
                        viewModel.delete(visit)
                    } label: {
                        Label("Chedk Out", systemImage: "xmark")
                    }
                }
            }
            Button {
                sheet = .addMember
            } label: {
                Label("Check in", systemImage: "plus")
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.accentColor.gradient.opacity(0.1))
                    .shadow(radius: 3)
            )
        }
        .cardStyle()
    }

    @ViewBuilder
    private var notes: some View {
        VStack {
            HStack {
                Text("Notes")
                Spacer()
                Text("0")
            }
            .font(.headline)
            Button {

            } label: {
                Label("New", systemImage: "plus")
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.accentColor.gradient.opacity(0.1))
                    .shadow(radius: 3)
            )
        }
        .cardStyle()
    }

    @ViewBuilder
    private var datePicker: some View {
        NavigationStack {
            Form {
                DatePicker("", selection: $customDate, in: .now...)
                    .datePickerStyle(.wheel)
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        endDate = customDate
                        sheet = nil
                    }
                }
            }
        }
    }
}

extension View {
    func cardStyle() -> some View {
        self
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.white)
                .shadow(color: .black.opacity(0.1), radius: 3, y: 1)
        )
    }
}

import SwiftDate

struct EventDetailView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            EventDetailView(viewModel: .init(event: .init(id: UUID(), name: "Open mat", createDate: .now, startDate: .now - 1.hours, estimatedEndDate: nil, endDate: nil, team: Mock.teams.first!, memberships: [])))
        }
        NavigationStack {
            EventDetailView(viewModel: .init(event: .init(id: UUID(), name: "Open mat", createDate: .now, startDate: .now + 1.hours, estimatedEndDate: nil, endDate: nil, team: Mock.teams.first!, memberships: [])))
        }
        NavigationStack {
            EventDetailView(viewModel: .init(event: .init(id: UUID(), name: "Open mat", createDate: .now, startDate: .now - 1.hours, estimatedEndDate: .now + 90.minutes, endDate: .now + 2.hours, team: Mock.teams.first!, memberships: [])))
        }
    }
}
