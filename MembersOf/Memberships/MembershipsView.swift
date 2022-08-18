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
                    VStack {
                        ForEach(viewModel.memberships) { ship in
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
                    }
                    .padding()
                }
                Button {
                    creatingNew.toggle()
                } label: {
                    Label("New", systemImage: "plus")
                }
                .padding()
            }
            .navigationTitle("Memberships")
            .sheet(isPresented: $creatingNew) {
                NewMembershipView()
                    .presentationDetents([.medium])
            }
        }
    }
}

struct MembershipsView_Previews: PreviewProvider {
    static var previews: some View {
        MembershipsView()
    }
}
