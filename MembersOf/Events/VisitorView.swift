//
//  MemberConfirmationView.swift
//  MembersOf
//
//  Created by Ravil Khusainov on 8/9/22.
//

import SwiftUI

struct VisitorView: View {
    
    @StateObject var viewModel: ViewModel
    let dismiss: () -> Void
    
    var body: some View {
        VStack {
            List {
                member
                membership
            }
            Button {
                viewModel.checkIn()
                dismiss()
            } label: {
                Label("Check In", systemImage: "checkmark")
            }
            .padding()
        }
    }
    
    @ViewBuilder
    private var member: some View {
        VStack {
            HStack {
                Circle()
                    .frame(width: 40,height: 40)
                VStack(alignment: .leading) {
                    Text(viewModel.member.firstName)
                    if let lastName = viewModel.member.lastName {
                        Text(lastName)
                    }
                }
                .font(.headline)
            }
        }
    }
    
    @ViewBuilder
    private var membership: some View {
        Section("Membership") {
            if let sub = viewModel.subscription {
                view(for: sub)
            } else {
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
    
    @ViewBuilder
    private func view(for subscription: Subscription) -> some View {
        Text(subscription.membership.name)
            .font(.headline)
        HStack {
            Text("Expires")
            Spacer()
            Text(subscription.endDate!.formatted(date: .abbreviated, time: .omitted))
        }
//        HStack {
//            Text("Visits")
//            Spacer()
//            Text("\(subscription.visits) left")
//        }
        Button {
            
        } label: {
            Text("Renew")
        }
    }
}

struct MemberConfirmationView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            VisitorView(
                viewModel: .init(
                    member: .init(id: UUID(), firstName: "Runar", lastName: "Kalimullin"),
                    event: .init(id: UUID(), name: "name", createDate: .now, startDate: .now, endDate: nil, team: Mock.teams.first!, memberships: [])
                )
            ){}
        }
    }
}


