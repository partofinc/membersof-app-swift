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
    @State private var membershipsHidden: Bool = true
    @State private var editMode: Bool = false
    
    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading) {
                timing
                team
                visits
                notes
            }
            .padding()
        }
        .edit($editMode) {
            EventEditView(
                viewModel: .init(event: viewModel.event, storage: viewModel.storage),
                sheet: $sheet
            )
        }
        .navigationTitle(viewModel.event.name)
        .sheet(item: $sheet) { sheet in
            switch sheet {
            case .addMember:
                SearchMembersView(viewModel: .init(viewModel.event, storage: viewModel.storage))
                    .presentationDetents([.large])
            case .endDate:
                datePicker
                    .presentationDetents([.medium])
            case .addMembership:
                NewMembershipView(viewModel: .init(signer: viewModel.signer))
                    .presentationDetents([.medium])
            }
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                EditButton(editMode: $editMode)
            }
        }
        .animation(.easeInOut, value: viewModel.visits)
        .animation(.easeInOut, value: membershipsHidden)
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
                    Button(viewModel.endDate) {
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
                    .menuStyle(.primarySmall)
                    .onChange(of: endDate, perform: { date in
                        viewModel.end(with: date)
                    })
                    Spacer()
                    Text(viewModel.endDate)
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
                Button {
                    membershipsHidden.toggle()
                } label: {
                    HStack {
                        Text("Memberships")
                        Image(systemName: "chevron.down")
                            .rotationEffect(.degrees(membershipsHidden ? 0 : -180))
                    }
                }
                .font(.headline)
                .buttonStyle(.plain)
                Spacer()
                NavigationLink {
                    TeamDetailView(viewModel: .init(viewModel.event.team, storage: viewModel.storage))
                } label: {
                    HStack {
                        Text(viewModel.event.team.name)
                        Image(systemName: "chevron.right")
                    }
                }
                .buttonStyle(.primarySmall)
            }
            if !membershipsHidden {
                ForEach(viewModel.event.memberships) { ship in
                    HStack {
                        Image(systemName: "largecircle.fill.circle")
                            .font(.footnote)
                        Text(ship.name)
                        Spacer()
                    }
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
                    .font(.headline)
                Spacer()
                Button {
                    sheet = .addMember
                } label: {
                    Label("Check in", systemImage: "plus")
                }
                .buttonStyle(.primarySmall)
            }
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
        }
        .cardStyle()
    }

    @ViewBuilder
    private var notes: some View {
        VStack {
            HStack {
                Text("Notes")
                    .font(.headline)
                Spacer()
                Button {

                } label: {
                    Label("New", systemImage: "plus")
                }
                .buttonStyle(.primarySmall)
            }
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

