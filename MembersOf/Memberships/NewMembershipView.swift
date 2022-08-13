//
//  NewMembershipView.swift
//  MembersOf
//
//  Created by Ravil Khusainov on 7/29/22.
//

import SwiftUI

struct NewMembershipView: View {
    
    let create: (Membership) -> Void
    @StateObject var viewModel = ViewModel()
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack {
            HStack {
                Text("Membership")
                Spacer()
                Button("Create") {
                    create(viewModel.create())
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
                Picker("Team", selection: $viewModel.clubTag) {
                    ForEach(0..<viewModel.clubs.count, id: \.self) { idx in
                        Text(viewModel.clubs[idx].name).tag(idx)
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
                HStack {
                    Text("Price")
                    if !viewModel.price.isEmpty {
                        Text("$")
                    }
                    TextField("Free", text: $viewModel.price)
                        .keyboardType(.numberPad)
                        .multilineTextAlignment(.trailing)
                }
            }
            .onChange(of: viewModel.period) { _ in
                viewModel.calculatePeriod()
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
            NewMembershipView {_ in}
                .presentationDetents([.fraction(0.6)])
        }
    }
}
