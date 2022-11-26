//
//  EventEditView.swift
//  MembersOf
//
//  Created by Ravil Khusainov on 9/27/22.
//

import SwiftUI

struct EventEditView: View {
    
    @StateObject var viewModel: ViewModel
    @Binding var sheet: EventDetailView.Sheet?
    @State private var endDate: Date = .now
    
    var body: some View {
        VStack {
            Form {
                TextField("Name", text: $viewModel.name)
                DatePicker("Starts", selection: $viewModel.startDate)
                DatePicker("Ends", selection: $endDate)
                Toggle("Finished", isOn: $viewModel.isEnded)
                Section("Memberships") {
                    NavigationLink {
                        TeamDetailView(viewModel: .init(team: viewModel.event.team))
                    } label: {
                        Text(viewModel.event.team.name)
                    }
                    ForEach(viewModel.memberships) { ship in
                        Button {
                            viewModel.toggle(ship)
                        } label: {
                            Label(ship.name, systemImage: viewModel.isSelected(ship) ? "checkmark.circle.fill" : "circle")
                        }
                    }
                    Button {
                        sheet = .addMembership
                    } label: {
                        Label("Add", systemImage: "plus")
                    }
                }
            }
            .onChange(of: endDate, perform: { newValue in
                viewModel.endDate = endDate
            })
            Button("Save") {
                
            }
            .buttonStyle(.primary)
            .padding()
        }
        .onAppear {
            endDate = viewModel.endDate ?? .now
        }
    }
}

struct EventEditView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            EventEditView(
                viewModel: .init(event:
                    .init(id: UUID(), name: "One time", createDate: .now, startDate: .now, estimatedEndDate: nil, endDate: nil, team: Mock.teams.first!, memberships: [])
                                          ),
                sheet: .constant(nil)
            )
        }
    }
}
