//
//  EventDetailView.swift
//  MembersOf
//
//  Created by Ravil Khusainov on 8/9/22.
//

import SwiftUI

struct EventDetailView: View {
    
    @StateObject var viewModel: ViewModel
    @State private var sheet: Sheet?
    @State private var endDate: Date = .now
    @State private var customDate: Date = .now
    
    var body: some View {
        VStack {
            ScrollView {
                VStack(alignment: .leading) {
                    timing
                    team
                    visits
                    notes
                }
                .padding()
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
            }
        }
        .toolbar {
            ToolbarItem {
                Button("Edit") {
                    
                }
            }
        }
        .animation(.easeInOut, value: viewModel.visits)
    }
    
    @ViewBuilder
    private var timing: some View {
        VStack {
            HStack {
                Text(viewModel.progress.rawValue)
                Spacer()
                Menu {
                    Button {
                        
                    } label: {
                        Label("In time", systemImage: "hand.thumbsup")
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
            }
            .font(.headline)
            HStack {
                Text(viewModel.startDate)
                Spacer()
                Text("1 h 4 m")
                    .bold()
                Spacer()
                Text("3:23 PM")
            }
        }
        .cardStyle()
    }
    
    @ViewBuilder
    private var team: some View {
        NavigationLink {
            TeamDetailView(viewModel: .init(team: viewModel.event.team))
        } label: {
            Text(viewModel.event.team.name)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.accentColor.gradient.opacity(0.1))
                .shadow(radius: 3)
        )
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
            EventDetailView(viewModel: .init(event: .init(id: UUID(), name: "Open mat", createDate: .now, startDate: .now + 1.days, endDate: nil, team: Mock.teams.first!, memberships: [])))
        }
    }
}
