//
//  MemberConfirmationView.swift
//  MembersOf
//
//  Created by Ravil Khusainov on 8/9/22.
//

import SwiftUI

struct MemberConfirmationView: View {
    
    @StateObject var viewModel: ViewModel
    let confirm: () -> Void
    
    var body: some View {
        VStack {
            List {
                member
                membership
            }
            Button {
                confirm()
            } label: {
                Label("Check In", systemImage: "checkmark")
            }
            .padding()
        }
        .navigationBarTitleDisplayMode(.inline)
    }
    
    @ViewBuilder
    private var member: some View {
        VStack {
            HStack {
                Circle()
                    .frame(width: 40,height: 40)
                VStack(alignment: .leading) {
                    Text(viewModel.member.firstName)
                    Text(viewModel.member.lastName)
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
            Text(subscription.expiresAt!.formatted(date: .abbreviated, time: .omitted))
        }
        HStack {
            Text("Visits")
            Spacer()
            Text("\(subscription.visits) left")
        }
        Button {
            
        } label: {
            Text("Renew")
        }
    }
}

extension MemberConfirmationView {
    
    @MainActor
    final class ViewModel: ObservableObject {
        
        let member: Member
        let subscription: Subscription?
        let memberships: [Membership] = [
            .init(id: UUID(), name: "ONE time", clubId: UUID(), visits: 1, period: .unlimited, length: 0),
            .init(id: UUID(), name: "Monthly (12 visits)", clubId: UUID(), visits: 12, period: .month, length: 1),
            .init(id: UUID(), name: "Monthly (Unlimited)", clubId: UUID(), visits: 0, period: .month, length: 1)
        ]
        
        @Published var starting: Date = .now
        @Published var visits: Int = 0
        @Published var payment: String = ""
        @Published var membership: Membership?
        
        init(member: Member, subscription: Subscription? = nil) {
            self.member = member
            self.subscription = subscription
        }
        
        func select(_ ship: Membership) {
            membership = ship
            visits = ship.visits
            starting = .now
        }
    
        func isSelected(_ ship: Membership) -> Bool {
            guard let membership else { return false }
            return ship.id == membership.id
        }
    }
}

struct MemberConfirmationView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            MemberConfirmationView(viewModel: .init(member: .init(id: UUID(), firstName: "Dinar", lastName: "Ibragimov"))) {}
        }
        
        NavigationStack {
            MemberConfirmationView(
                viewModel: .init(
                    member: .init(id: UUID(), firstName: "Runar", lastName: "Kalimullin"),
                    subscription: .init(id: UUID(), member: .init(id: UUID(), firstName: "Runar", lastName: "Kalimullin"), membership: .init(id: UUID(), name: "Monthly 30 visits", clubId: UUID(), visits: 30, period: .month, length: 1), startedAt: .now.addingTimeInterval(-44444), expiresAt: .now.addingTimeInterval(66696), visits: 7)
                )
            ) {}
        }
    }
}


