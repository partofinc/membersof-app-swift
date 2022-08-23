//
//  MemberConfirmationView.swift
//  MembersOf
//
//  Created by Ravil Khusainov on 8/9/22.
//

import SwiftUI

struct MemberConfirmationView: View {
    
    @StateObject var viewModel: ViewModel
    let dismiss: DismissAction?
    
    var body: some View {
        VStack {
            List {
                member
                membership
            }
            Button {
                viewModel.checkIn()
                dismiss?()
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
//                .keyboardType(.numberPad)
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
        let event: Event
        
        fileprivate let storage: Storage = .shared
        fileprivate var membershipsFetcher: Storage.Fetcher<Membership>?
        fileprivate var subscriptionsFetcher: Storage.Fetcher<Subscription>?
        
        @Published var subscription: Subscription?
        
        @Published var starting: Date = .now
        @Published var visits: Int = 0
        @Published var payment: String = ""
        @Published var membership: Membership?
        @Published var memberships: [Membership] = []
        
        init(member: Member, event: Event) {
            self.member = member
            self.event = event
            
            membershipsFetcher = storage.fetch()
                .filter(by: \.team.id, value: event.team.id)
                .assign(to: \.memberships, on: self)
                .run(sort: [.init(\.createDate, order: .reverse)])
            
            subscriptionsFetcher = storage.fetch()
                .filter(with: .init(format: "member.id == %@", member.id.uuidString))
                .filter(with: .init(format: "membership.team.id == %@", event.team.id.uuidString))
                .sink(receiveValue: { [unowned self] subs in
                    self.subscription = subs.last
                })
                .run(sort: [.init(\.startDate)])
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
        
        func checkIn() {
            Task {
                try await self.storage.save(Visit(id: UUID(), member: member, checkInDate: .now, eventId: event.id))
            }
        }
    }
}

struct MemberConfirmationView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            MemberConfirmationView(
                viewModel: .init(
                    member: .init(id: UUID(), firstName: "Runar", lastName: "Kalimullin"),
                    event: .init(id: UUID(), name: "name", createDate: .now, startDate: nil, endDate: nil, team: Mock.teams.first!, memberships: [])
                ),
                dismiss: nil
            )
        }
    }
}


