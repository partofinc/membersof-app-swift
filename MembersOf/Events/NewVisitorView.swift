//
//  NewMemberView.swift
//  MembersOf
//
//  Created by Ravil Khusainov on 8/9/22.
//

import SwiftUI

struct NewVisitorView: View {
    
    @StateObject var viewModel: ViewModel
    
    var dismiss: () -> Void
    
    var body: some View {
        VStack {
            Form {
                Section("") {
                    TextField("First name", text: $viewModel.firstName)
                        .textContentType(.givenName)
                    TextField("Last name", text: $viewModel.lastName)
                        .textContentType(.familyName)
                }
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
                if let ship = viewModel.membership, !ship.pricing.isEmpty {
                    Section("Payment") {
                        payment(for: ship)
                    }
                }
            }
            Button {
                viewModel.create()
                dismiss()
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
    }
    
    @ViewBuilder
    private func payment(for membership: Membership) -> some View {
        Picker("Currency", selection: $viewModel.price) {
            ForEach(membership.pricing, id: \.self) { price in
                Text(price.currency).tag(price.id)
            }
        }
        .onChange(of: viewModel.price) { price in
            viewModel.select(price)
        }
        HStack {
            TextField("Amount", value: $viewModel.payment, format: .number)
                .keyboardType(.decimalPad)
                .onChange(of: viewModel.payment) { payment in
                    viewModel.calculate(payment)
                }
            Spacer()
            if viewModel.debt != 0 {
                Text(String(describing: viewModel.debt))
                    .foregroundColor(viewModel.debt > 0 ? .green : .red)
            }
        }
    }
}

struct NewMemberView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            NewVisitorView(viewModel:
                        .init(
                            Event(
                                id: UUID(),
                                name: "Some",
                                createDate: .now,
                                startDate: .now,
                                estimatedEndDate: nil,
                                endDate: nil,
                                team: Mock.teams.first!,
                                memberships: [
                                    .init(
                                        id: UUID(),
                                        name: "One time",
                                        visits: 1,
                                        period: .day,
                                        length: 1,
                                        createDate: .now,
                                        teamId: UUID(),
                                        pricing: [
                                            .init(id: UUID(), currency: "USD", value: 34),
                                            .init(id: UUID(), currency: "CAD", value: 45)
                                        ]
                                    ),
                                    .init(
                                        id: UUID(),
                                        name: "Free",
                                        visits: 0,
                                        period: .unlimited,
                                        length: 0,
                                        createDate: .now,
                                        teamId: UUID(),
                                        pricing: []
                                    ),
                                    .init(
                                        id: UUID(),
                                        name: "First Visit",
                                        visits: 1,
                                        period: .day,
                                        length: 1,
                                        createDate: .now,
                                        teamId: UUID(),
                                        pricing: [])
                                ]
                            ))) {}
        }
    }
}
