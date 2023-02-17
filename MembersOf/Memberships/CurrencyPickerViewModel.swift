//
//  CurrencyPickerViewModel.swift
//  MembersOf
//
//  Created by Ravil Khusainov on 2022-12-18.
//

import Foundation

extension CurrencyPickerView {
    
    @MainActor
    final class ViewModel: ObservableObject {
        
        @Published var search: String = ""
        @Published var list: [Currency] = []
        
        var currencies: [Currency] {
            if search.isEmpty {
                return list
            } else {
                return list.filter { currency in
                    currency.code.lowercased().contains(search.lowercased()) || currency.name.lowercased().contains(search.lowercased()) || currency.code == search
                }
            }
        }
        
        init() {
            calculate()
        }
        
        fileprivate func calculate() {
            Task {
                let locales = Locale.availableIdentifiers.map(Locale.init)
                self.list = Locale.Currency.isoCurrencies.compactMap { currency -> Currency? in
                    guard let locale = locales.first(where: {$0.currency == currency}),
                          let symbol = locale.currencySymbol,
                          let name = locale.localizedString(forCurrencyCode: currency.identifier) else { return nil }
                    return .init(code: currency.identifier, symbol: symbol, name: name)
                }
            }
        }
    }
}

struct Currency: Identifiable, Equatable {
    let code: String
    let symbol: String
    let name: String
    
    var id: String { code }
}

