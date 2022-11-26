//
//  MembershipsView.swift
//  MembersOf
//
//  Created by Ravil Khusainov on 8/2/22.
//

import SwiftUI

struct MembershipsView: View {
    
    @StateObject var viewModel = ViewModel()
    @State private var creatingNew: Bool = false
    
    var body: some View {
        NavigationStack {
            VStack {
                ScrollView {
                    LazyVStack {
                        ForEach(viewModel.memberships) { ship in
                            NavigationLink {
                                MembershipDetailView(viewModel: .init(ship))
                            } label: {
                                HStack {
                                    Text(ship.name)
                                    Spacer()
                                }
                                .padding()
                                .background(
                                    RoundedRectangle(cornerRadius: 10)
                                        .fill(Color.orange.opacity(0.4).gradient)
                                        .shadow(radius: 5)
                                )
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding()
                }
                Button {
                    creatingNew.toggle()
                } label: {
                    Label("New", systemImage: "plus")
                }
                .buttonStyle(.primary)
                .padding()
            }
            .navigationTitle("Memberships")
            .sheet(isPresented: $creatingNew) {
                NewMembershipView(viewModel: .init())
                    .presentationDetents([.medium])
            }
            .animation(.easeInOut, value: viewModel.memberships)
        }
    }
}

struct MembershipsView_Previews: PreviewProvider {
    static var previews: some View {
        MembershipsView()
    }
}
