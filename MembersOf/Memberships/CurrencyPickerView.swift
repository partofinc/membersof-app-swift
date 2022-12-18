//
//  CurrencySelectionView.swift
//  MembersOf
//
//  Created by Ravil Khusainov on 8/22/22.
//

import SwiftUI

struct CurrencyPickerView: View {
    
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
        .safeAreaInset(edge: .bottom) {
            Button("Done") {
                dismiss()
            }
            .buttonStyle(.primary)
            .padding()
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
            CurrencyPickerView(currency: $currency, existing: [])
        }
    }
}

