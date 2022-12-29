

import Foundation
import Combine
import Models

extension NewMembershipView {
    
    @MainActor
    final class ViewModel: ObservableObject {
        
        let team: Team?
        
        @Published var name: String = ""
        @Published var autoName: String = "Unlimited"
        
        @Published var selectedTeam: Team = .loading
        @Published var teams: [Team] = [.loading]
        
        @Published var period: Membership.Period = .unlimited
        let periods: [Membership.Period] = [
            .unlimited,
            .day,
            .week,
            .month,
            .year
        ]
        
        @Published var length: Int = 1
        @Published var periodText: String?
        
        @Published var visits: Int = 0
        @Published var visitsText: String = "Unlimited visits"
        
        @Published var price: Decimal?
        @Published var currency: Currency?
        @Published var pricing: [Price] = []
        
        let sigmer: Signer
        let storage: Storage
        
        private var teamsCanceller: AnyCancellable?
        
        var canCreate: Bool {
            guard let team = teams.first else { return false }
            return name.count > 2 && team != .loading && price == nil && currency == nil
        }
        
        var pricingFooter: String {
            if let currency {
                return currency.name
            } else {
                return "You can add pricing in multiple currencies"
            }
        }
        
        init(team: Team? = nil, signer: Signer) {
            self.team = team
            self.sigmer = signer
            self.storage = signer.storage
            
            if let team {
                selectedTeam = team
                return
            }
            teamsCanceller = storage.fetch(Team.self)
                .sort(by: [.init(\.createDate, order: .reverse)])
                .catch{_ in Just([])}
                .sink { [unowned self] teams in
                    self.teams = teams
                    if !teams.contains(where: {$0.id == self.selectedTeam.id}), let team = teams.first {
                        self.selectedTeam = team
                    }
                }
        }
        
        func calculatePeriod() {
            guard period != .unlimited else {
                periodText = nil
                length = 1
                return
            }
            periodText = "\(length) " + period.rawValue.capitalized
        }
        
        func calculateVisits() {
            guard visits != 0 else {
                visitsText = "Unlimited visits"
                return
            }
            visitsText = "\(visits) Visits"
        }
        
        func hasDefaultCurrency() -> Bool {
            guard let d = Currency.default else { return true }
            if pricing.contains(where: {$0.currency == d.id}) {
                return true
            }
            currency = d
            return false
        }

        func addTier() {
            guard let currncy = currency?.code, let price else { return }
            let p = Price(id: UUID(), currency: currncy, value: price)
            currency = nil
            pricing.append(p)
            Task {
                try await Task.sleep(seconds: 0.3)
                self.price = nil
            }
        }
        
        func cancelTier() {
            currency = nil
            price = nil
        }
        
        func delete(_ price: Price) {
            pricing.removeAll(where: {$0 == price})
        }
        
        func create() {
            Task {
                let membership = Membership(
                    id: UUID(),
                    name: name,
                    visits: visits,
                    period: period,
                    length: length,
                    createDate: .now,
                    teamId: selectedTeam.id,
                    pricing: self.pricing
                )
                try await self.storage.save(membership)
            }
        }
    }
}

extension Currency {
    static var `default`: Self? {
        let locale = Locale.current
        guard let currency = locale.currency?.identifier,
              let symbol = locale.currencySymbol,
                let name = locale.localizedString(forCurrencyCode: currency) else { return nil }
        return .init(code: currency, symbol: symbol, name: name)
    }
}

extension Task where Success == Never, Failure == Never {
    static func sleep(seconds: Double) async throws {
        let duration = UInt64(seconds * 1_000_000_000)
        try await Task.sleep(nanoseconds: duration)
    }
}

