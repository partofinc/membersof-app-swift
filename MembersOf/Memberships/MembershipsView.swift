//
//  MembershipsView.swift
//  MembersOf
//
//  Created by Ravil Khusainov on 8/2/22.
//

import SwiftUI

struct MembershipsView: View {
    
    @StateObject var viewModel: ViewModel
    @State private var creatingNew: Bool = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack {
                    ForEach(viewModel.memberships) { ship in
                        NavigationLink {
                            MembershipDetailView(viewModel: .init(ship, storage: viewModel.storage))
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
            .safeAreaInset(edge: .bottom) {
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
                NewMembershipView(viewModel: .init(signer: viewModel.signer))
                    .presentationDetents([.medium])
            }
            .animation(.easeInOut, value: viewModel.memberships)
        }
    }
}

struct MembershipsView_Previews: PreviewProvider {
    static let signer = PreviewSigner.default
    static var previews: some View {
        MembershipsView(viewModel: .init(signer))
    }
}
