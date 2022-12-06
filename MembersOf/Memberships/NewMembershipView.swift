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
                            NewTeamView(viewModel: .init(viewModel.sigmer))
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
                        CurrencySelectionView(currency: $viewModel.currency, existing: viewModel.pricing.map(\.currency))
                    }
                }
            }
            .navigationTitle("Membership")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem {
                    Button("Create") {
                        viewModel.create()
                        dismiss()
                    }
                    .disabled(!viewModel.canCreate)
                }
            }
            .toolbarBackground(.visible, for: .navigationBar)
        }
    }
    
    @ViewBuilder
    private var pricing: some View {
        Section("Pricing") {
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
                    TextField("0.00", value: $viewModel.price, format: Decimal.FormatStyle.init(locale: .current))
                        .keyboardType(.decimalPad)
                    Button {
                        viewModel.addTier()
                    } label: {
                        Image(systemName: "checkmark.circle")
                    }
                    .buttonStyle(.plain)
                    .foregroundColor(.accentColor)
                    .disabled(viewModel.price == nil)
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
