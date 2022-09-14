//
//  MembershipDetailView.swift
//  MembersOf
//
//  Created by Ravil Khusainov on 8/23/22.
//

import SwiftUI

struct MembershipDetailView: View {
    
    @StateObject var viewModel: ViewModel
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack {
            List {
                Section("") {
                    HStack {
                        Text("Team")
                        Spacer()
                        Text(viewModel.team.name)
                    }
                    HStack {
                        Text("Period")
                        Spacer()
                        Text(viewModel.membership.period.rawValue)
                    }
                    HStack {
                        Text("Visits")
                        Spacer()
                        Text("\(viewModel.membership.visits)")
                    }
                    NavigationLink {
                        Text("Members")
                    } label: {
                        HStack {
                            Text("Members")
                            Spacer()
                            Text("12")
                        }
                    }
                }
                Section("Pricing") {
                    ForEach(viewModel.membership.pricing) { price in
                        Text(viewModel.format(price))
                    }
                }
                Section {
                    Button(role: .destructive) {
                        viewModel.delete()
                        dismiss()
                    } label: {
                        Label("Delete membership", systemImage: "trash")
                    }
                }
            }
        }
        .navigationTitle(viewModel.membership.name)
        .toolbar {
            ToolbarItem {
                Button("Edit") {
                    
                }
            }
        }
    }
}

struct MembershipDetailView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            MembershipDetailView(viewModel:
                    .init(
                        .init(
                            id: UUID(),
                            name: "One Time",
                            visits: 1,
                            period: .day,
                            length: 1,
                            createDate: .now,
                            teamId: UUID(),
                            pricing: [
                                .init(id: UUID(), currency: "USD", value: 50),
                                .init(id: UUID(), currency: "CAD", value: 60),
                                .init(id: UUID(), currency: "RUB", value: 5080)
                            ]))
            )
        }
    }
}
