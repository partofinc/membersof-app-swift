//
//  NewMemberViewModel.swift
//  MembersOf
//
//  Created by Ravil Khusainov on 8/9/22.
//

import Foundation

extension NewVisitorView {
    
    @MainActor
    final class ViewModel: ObservableObject {
        
        let event: Event
        
        @Published var firstName: String = ""
        @Published var lastName: String = ""
        @Published var membership: Membership?
        @Published var memberships: [Membership] = []
        @Published var starting: Date = .now
        @Published var visits: Int = 0
        @Published var payment: Decimal = 0
        @Published var debt: Decimal = 0
        @Published var price: Price = .init(id: UUID(), currency: "USD", value: 0)
        
        fileprivate let storage: Storage = .shared
        fileprivate var membershipsFetcher: Storage.Fetcher<Membership>?
        
        init(_ event: Event) {
            self.event = event
            memberships = event.memberships
        }
        
        var title: String {
            firstName.isEmpty ? "New" : firstName
        }
        
        var canConfirm: Bool {
            !firstName.isEmpty && !lastName.isEmpty && membership != nil
        }
        
        func create() {
            guard let membership else { return }
            Task {
                var payments: [Payment] = []
                if !membership.pricing.isEmpty {
                    let debt: Debt? = self.debt == 0 ? nil : .init(id: UUID(), currency: price.currency, amount: self.debt)
                    let payment: Payment = .init(id: UUID(), currency: price.currency, amount: self.payment, date: .now, debt: debt)
                    payments.append(payment)
                }
                let member = Member(id: UUID(), firstName: firstName, lastName: lastName)
                let subscription = Subscription(id: UUID(), startDate: .now, endDate: nil, member: member, membership: membership, payments: payments)
                let visit = Visit(id: UUID(), checkInDate: .now, event: event, member: member, subscription: subscription)
                try await storage.save(visit)
            }
        }
        
        func select(_ ship: Membership) {
            membership = ship
            visits = ship.visits
            starting = .now
            if let price = ship.pricing.first {
                self.price = price
                self.payment = price.value
            }
        }
    
        func isSelected(_ ship: Membership) -> Bool {
            guard let membership else { return false }
            return ship.id == membership.id
        }
        
        func select(_ price: Price) {
            payment = price.value
            self.price = price
            calculate(price.value)
        }
        
        func isSelected(_ price: Price) -> Bool {
            return self.price == price
        }
        
        func calculate(_ payment: Decimal) {
            debt = payment - price.value
        }
    }
}
