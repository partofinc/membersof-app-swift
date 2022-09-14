

import Foundation
import Combine

extension NewMembershipView {
    
    @MainActor
    final class ViewModel: ObservableObject {
        
        let team: Team?
        
        @Published var name: String = ""
        @Published var autoName: String = "Unlimited"
        
        @Published var teamIdx: Int = 0
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
        @Published var priceCurrency: Currency?
        @Published var pricing: [Price] = []
        
        @Published var defaultCurrency: Currency? = .default
        
        private let priceFormatter: NumberFormatter = {
            let formatter = NumberFormatter()
            formatter.numberStyle = .currency
            formatter.locale = .autoupdatingCurrent
            formatter.maximumFractionDigits = 2
            formatter.minimumFractionDigits = 0
            return formatter
        }()
        
        private let storage: Storage = .shared
        private var teamsFetcher: Storage.Fetcher<Team>?
        
        var canCreate: Bool {
            guard let team = teams.first else { return false }
            return name.count > 2 && team != .loading
        }
        
        init(_ team: Team? = nil) {
            self.team = team
            guard team == nil else { return }
            teamsFetcher = storage.fetch()
                .assign(to: \.teams, on: self)
                .run(sort: [.init(\.createDate, order: .reverse)])
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
        
        func fromat(_ price: Price) -> String {
            priceFormatter.currencyCode = price.currency
            return priceFormatter.string(for: price.value)!
        }
        
        func add(_ currency: Currency) {
            priceCurrency = currency
        }
        
        func addPrice() {
            guard let currncy = priceCurrency?.code, let price else { return }
            let p = Price(id: UUID(), currency: currncy, value: price)
            priceCurrency = nil
            self.price = 0
            if let defaultCurrency, defaultCurrency.code == currncy {
                self.defaultCurrency = nil
            }
            pricing.append(p)
        }
        
        func delete(_ price: Price) {
            pricing.removeAll(where: {$0 == price})
            if let def = Currency.default, def.code == price.currency {
                defaultCurrency = def
            }
        }
        
        func create() {
            let team = self.team ?? teams[teamIdx]
            Task {
                let membership = Membership(
                    id: UUID(),
                    name: name,
                    visits: visits,
                    period: period,
                    length: length,
                    createDate: .now,
                    teamId: team.id,
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

