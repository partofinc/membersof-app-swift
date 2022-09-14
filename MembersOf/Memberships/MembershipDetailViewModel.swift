//
//  MembershipDetailViewModel.swift
//  MembersOf
//
//  Created by Ravil Khusainov on 8/23/22.
//

import Foundation

extension MembershipDetailView {
    
    @MainActor
    final class ViewModel: ObservableObject {
        
        let membership: Membership
        @Published var team: Team = .loading
        
        private let storage: Storage = .shared
        
        private let priceFormatter: NumberFormatter = {
            let formatter = NumberFormatter()
            formatter.numberStyle = .currency
            formatter.locale = .autoupdatingCurrent
            formatter.maximumFractionDigits = 2
            formatter.minimumFractionDigits = 0
            return formatter
        }()
        
        init(_ membership: Membership) {
            self.membership = membership
        }
        
        func format(_ price: Price) -> String {
            priceFormatter.currencyCode = price.currency
            return priceFormatter.string(for: price.value)!
        }
        
        func delete() {
            Task {
                try await storage.delete(membership)
            }
        }
    }
}
