//
//  NewMembershipView.swift
//  MembersOf
//
//  Created by Ravil Khusainov on 7/29/22.
//

import SwiftUI

struct NewMembershipView: View {
    
    @StateObject fileprivate var viewModel = ViewModel()
    @Environment(\.dismiss) private var dismiss
    @State private var choosingCurrency = false
    
    var body: some View {
        VStack {
            HStack {
                Text("Membership")
                Spacer()
                Button("Create") {
                    viewModel.create()
                    dismiss()
                }
            }
            .padding(.horizontal)
            .frame(height: 44)
            .font(.headline)
            Form {
                HStack {
                    Text("Name")
                    TextField(viewModel.autoName, text: $viewModel.name)
                        .multilineTextAlignment(.trailing)
                }
                Picker("Team", selection: $viewModel.teamIdx) {
                    ForEach(0..<viewModel.teams.count, id: \.self) { idx in
                        Text(viewModel.teams[idx].name).tag(idx)
                    }
                }
                Picker("Period", selection: $viewModel.period) {
                    ForEach(viewModel.periods) { p in
                        Text(p.rawValue.capitalized)
                    }
                }
                if let lenght = viewModel.periodText {
                    Stepper(lenght, value: $viewModel.length, in: 1...10000, onEditingChanged: { _ in
                        viewModel.calculatePeriod()
                    })
                }
                Stepper(viewModel.visitsText, value: $viewModel.visits, in: 0...10000, onEditingChanged: { _ in
                    viewModel.calculateVisits()
                })
                pricing
            }
            .onChange(of: viewModel.period) { _ in
                viewModel.calculatePeriod()
            }
            .sheet(isPresented: $choosingCurrency) {
                NavigationStack {
                    CurrencySelectionView { currency in
                        viewModel.add(currency)
                    }
                }
            }
        }
    }
    
    @ViewBuilder
    private var pricing: some View {
        Section("Pricing") {
            ForEach(viewModel.pricing) { price in
                HStack {
                    Text(viewModel.fromat(price))
                    Spacer()
                    Button(role: .destructive) {
                        viewModel.delete(price)
                    } label: {
                        Image(systemName: "trash")
                    }
                }
            }
            if let currency = viewModel.priceCurrency {
                HStack {
                    Text(currency.symbol)
                    TextField("0.00", value: $viewModel.price, format: Decimal.FormatStyle.init(locale: .current))
                        .keyboardType(.decimalPad)
                    Button {
                        viewModel.addPrice()
                    } label: {
                        Image(systemName: "checkmark.circle")
                    }
                    .buttonStyle(.plain)
                    .foregroundColor(.accentColor)
                    .disabled(viewModel.price == nil)
                }
            } else if let currency = viewModel.defaultCurrency {
                Menu {
                    Button(currency.display) {
                        viewModel.add(currency)
                    }
                    Button("Other") {
                        choosingCurrency.toggle()
                    }
                } label: {
                    Label("Add", systemImage: "plus")
                }
            } else {
                Button {
                    choosingCurrency.toggle()
                } label: {
                    Label("Add", systemImage: "plus")
                }
            }
        }
    }
}

struct NewMembershipView_Previews: PreviewProvider {
    
    @State static var creatingNew = true
    
    static var previews: some View {
        VStack {
            Spacer()
            Button {
                creatingNew.toggle()
            } label: {
                Label("New", systemImage: "plus")
            }
            .padding()
        }
        .sheet(isPresented: $creatingNew) {
            NewMembershipView()
                .presentationDetents([.fraction(0.6)])
        }
    }
}
