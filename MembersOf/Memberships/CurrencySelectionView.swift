//
//  CurrencySelectionView.swift
//  MembersOf
//
//  Created by Ravil Khusainov on 8/22/22.
//

import SwiftUI

struct CurrencySelectionView: View {
    
    
    @Binding var currency: Currency?
    let existing: [String]
    @StateObject var viewModel: ViewModel = .init()
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        List(viewModel.currencies) { currency in
            Button {
                self.currency = currency
            } label: {
                HStack {
                    Image(systemName: isSelected(currency) ? "checkmark.circle" : "circle.dotted")
                    Text(currency.code)
                    Text(currency.symbol)
                    Spacer()
                    Text(currency.name)
                        .foregroundColor(.secondary)
                }
            }
            .buttonStyle(.plain)
            .disabled(existing.contains(where: {$0 == currency.id}))
        }
        .searchable(text: $viewModel.search)
        .navigationTitle("Currency")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Done") {
                    dismiss()
                }
            }
        }
    }
    
    func isSelected(_ currecny: Currency) -> Bool {
        guard let c = self.currency else { return false }
        return c.id == currecny.id
    }
}

struct CurrencySelectionView_Previews: PreviewProvider {
    @State static var currency: Currency?
    static var previews: some View {
        NavigationStack {
            CurrencySelectionView(currency: $currency, existing: [])
        }
    }
}

extension Locale.Currency: Identifiable {
    public var id: String { identifier }
}

extension CurrencySelectionView {
    
    @MainActor
    final class ViewModel: ObservableObject {
        
        @Published var search: String = ""
        @Published var cur: [Currency] = []
        
        var currencies: [Currency] {
            if search.isEmpty {
                return cur
            } else {
                return cur.filter { currency in
                    currency.code.lowercased().contains(search.lowercased()) || currency.name.lowercased().contains(search.lowercased()) || currency.code == search
                }
            }
        }
        
        init() {
            calculate()
        }
        
        fileprivate func calculate() {
            Task {
                let cur = Locale.Currency.isoCurrencies
                let loc = Locale.availableIdentifiers.map(Locale.init)
                var res: [Currency] = []
                for c in cur {
                    guard let locale = loc.first(where: {$0.currency == c}) else { continue }
                    guard let symbol = locale.currencySymbol,
                          let name = locale.localizedString(forCurrencyCode: c.id) else { continue }
                    res.append(.init(code: c.id, symbol: symbol, name: name))
                }
                self.cur = res
            }
        }
    }
}

struct Currency: Identifiable {
    let code: String
    let symbol: String
    let name: String
    
    var id: String { code }
    
    var display: String {
        if code == symbol {
            return code
        }
        return code + "(\(symbol))"
    }
    
    var localizedName: String {
        var locale = Locale.autoupdatingCurrent
        return locale.currencySymbol ?? symbol
    }
}
