//
//  NewMemberView.swift
//  MembersOf
//
//  Created by Ravil Khusainov on 8/9/22.
//

import SwiftUI

struct NewMemberView: View {
    
    @StateObject var viewModel: ViewModel
    let create: (Member) -> Void
    
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack {
            Form {
                TextField("First name", text: $viewModel.firstName)
                TextField("Last name", text: $viewModel.lastName)
                Section("Membership") {
                    ForEach(viewModel.memberships) { ship in
                        Button {
                            viewModel.select(ship)
                        } label: {
                            Label(ship.name, systemImage: viewModel.isSelected(ship) ? "checkmark.circle.fill" : "circle")
                        }
                    }
                    if let ship = viewModel.membership {
                        options(for: ship)
                    }
                }
            }
            Button {
                viewModel.create()
//                create(viewModel.create())
            } label: {
                Label("Check In", systemImage: "checkmark")
            }
            .disabled(!viewModel.canConfirm)
            .padding()
        }
        .navigationTitle(viewModel.title)
    }
    
    @ViewBuilder
    private func options(for membership: Membership) -> some View {
        switch membership.period {
        case .unlimited:
            EmptyView()
        default:
            DatePicker("Starting", selection: $viewModel.starting, displayedComponents: .date)
        }
        if membership.visits > 0 {
            Stepper("\(viewModel.visits) Visits", value: $viewModel.visits, in: 1...1000)
        }
        HStack {
            Text("Payment, $")
            Spacer()
            TextField("350", text: $viewModel.payment)
                .multilineTextAlignment(.trailing)
                .keyboardType(.numberPad)
        }
    }
}

struct NewMemberView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            NewMemberView(viewModel: .init(team: Mock.teams.first!)) {_ in}
        }
    }
}
