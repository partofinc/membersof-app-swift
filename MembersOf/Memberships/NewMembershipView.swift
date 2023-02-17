//
//  NewMembershipView.swift
//  MembersOf
//
//  Created by Ravil Khusainov on 7/29/22.
//

import SwiftUI

struct NewMembershipView: View {
    
    @StateObject var viewModel: ViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var choosingCurrency = false
    @FocusState private var isPriceEditing
    
    var body: some View {
        NavigationStack {
            VStack {
                Form {
                    HStack {
                        Text("Name")
                        TextField(viewModel.autoName, text: $viewModel.name)
                            .multilineTextAlignment(.trailing)
                    }
                    if let team = viewModel.team {
                        HStack {
                            Text("Team")
                            Spacer()
                            Text(team.name)
                        }
                    } else if viewModel.teams.isEmpty {
                        NavigationLink {
                            NewTeamView(viewModel: .init(viewModel.sigmer), team: $viewModel.selectedTeam)
                        } label: {
                            HStack {
                                Text("Team")
                                Spacer()
                                Text("New")
                                    .foregroundColor(.accentColor)
                            }
                        }
                    } else {
                        Picker("Team", selection: $viewModel.selectedTeam) {
                            ForEach(viewModel.teams, id: \.self) { team in
                                Text(team.name).tag(team.id)
                            }
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
                        CurrencyPickerView(currency: $viewModel.currency, existing: viewModel.pricing.map(\.currency))
                    }
                }
            }
            .navigationTitle("Membership")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(.visible, for: .navigationBar)
            #endif
            .toolbar {
                ToolbarItem {
                    Button("Create") {
                        viewModel.create()
                        dismiss()
                    }
                    .disabled(!viewModel.canCreate)
                }
            }
        }
    }
    
    @ViewBuilder
    private var pricing: some View {
        Section(header: Text("Pricing"), footer: Text(viewModel.pricingFooter)) {
            ForEach(viewModel.pricing) { price in
                HStack {
                    Text(price.value.formatted(.currency(code: price.currency)))
                    Spacer()
                    Button {
                        viewModel.delete(price)
                    } label: {
                        Image(systemName: "trash")
                    }
                    .foregroundColor(.red)
                    .buttonStyle(.plain)
                }
            }
            if let currency = viewModel.currency {
                HStack {
                    Button {
                        choosingCurrency.toggle()
                    } label: {
                        Text(currency.symbol)
                    }
                    .buttonStyle(.primarySmall)
                    TextField("0.00", value: $viewModel.price, format: Decimal.FormatStyle())
                    #if os(iOS)
                        .keyboardType(.decimalPad)
                    #endif
                        .focused($isPriceEditing)
                }
                HStack {
                    Button {
                        viewModel.addTier()
                    } label: {
                        Label("Save", systemImage: "checkmark")
                    }
                    .buttonStyle(.plain)
                    .foregroundColor(.accentColor)
                    .frame(maxWidth: .infinity)
                    .disabled(viewModel.price == nil)
                    Button(role: .destructive) {
                        viewModel.cancelTier()
                    } label: {
                        Label("Cancel", systemImage: "xmark")
                    }
                    .buttonStyle(.plain)
                    .foregroundColor(.red)
                    .frame(maxWidth: .infinity)
                }
            } else {
                Button {
                    if viewModel.hasDefaultCurrency() {
                        choosingCurrency.toggle()
                    }
                } label: {
                    Label("Add", systemImage: "plus")
                }
            }
        }
        .onChange(of: viewModel.currency) { newValue in
            guard newValue != nil else { return }
            isPriceEditing = true
        }
    }
}



//struct NewMembershipView_Previews: PreviewProvider {
//    
//    @State static var creatingNew = true
//    
//    static var previews: some View {
//        VStack {
//            Spacer()
//            Button {
//                creatingNew.toggle()
//            } label: {
//                Label("New", systemImage: "plus")
//            }
//            .padding()
//        }
//        .sheet(isPresented: $creatingNew) {
//            NewMembershipView(viewModel: .init())
//                .presentationDetents([.fraction(0.6)])
//        }
//    }
//}
