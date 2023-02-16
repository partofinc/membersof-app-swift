//
//  NewTeamSectionView.swift
//  MembersOf
//
//  Created by Ravil Khusainov on 16.02.2023.
//

import SwiftUI
import Models

struct NewTeamSectionView: View {
    
    let signer: Signer
    @Binding var teams: [Team]
    @Binding var team: Team
    
    @Binding var places: [Place]
    @Binding var place: Place
    
    @Binding var memberships: [Membership]
    @Binding var selectedMemberships: [UUID]
    
    var body: some View {
        Section {
            if teams.isEmpty {
                NavigationLink {
                    NewTeamView(viewModel: .init(signer), team: $team)
                } label: {
                    HStack {
                        Text("Team")
                        Spacer()
                        Text("New")
                            .foregroundColor(.accentColor)
                    }
                }
            } else {
                Picker("Team", selection: $team) {
                    ForEach(teams, id: \.self) { team in
                        Text(team.name).tag(team)
                    }
                }
                Picker("Place", selection: $place) {
                    ForEach(places, id: \.self) { place in
                        Text(place.name).tag(place)
                    }
                }
            }
            HStack {
                Text("Memberships")
                Spacer()
                Button("All") {
                    selectMemberships()
                }
                .buttonStyle(.plain)
                .foregroundColor(.accentColor)
                Text("|")
                Button("None") {
                    deselectMemberships()
                }
                .buttonStyle(.plain)
                .foregroundColor(.accentColor)
            }
            ForEach(memberships) { ship in
                Button {
                    toggle(ship)
                } label: {
                    Label(ship.name, systemImage: isSelected(ship) ? "checkmark.circle.fill" : "circle")
                }
            }
            Menu {
                NavigationLink {
                    NewTeamView(viewModel: .init(signer), team: $team)
                } label: {
                    Label("Team", systemImage: "person.3")
                }
                NavigationLink {
                    NewMembershipView(viewModel: .init(team: team, signer: signer))
                } label: {
                    Label("Membership", systemImage: "creditcard")
                }
                NavigationLink {
                    Text("New place")
                } label: {
                    Label("Place", systemImage: "mappin.and.ellipse")
                }
            } label: {
                Label("Add", systemImage: "plus")
            }
        }
    }
    
    @MainActor
    func isSelected(_ membership: Membership) -> Bool {
        selectedMemberships.contains(membership.id)
    }
    
    @MainActor
    func toggle(_ membership: Membership) {
        if let idx = selectedMemberships.firstIndex(of: membership.id) {
            selectedMemberships.remove(at: idx)
        } else {
            selectedMemberships.append(membership.id)
        }
    }
    
    @MainActor
    func selectMemberships() {
        selectedMemberships = memberships.map(\.id)
    }
    
    @MainActor
    func deselectMemberships() {
        selectedMemberships.removeAll()
    }
}

//struct NewTeamSectionView_Previews: PreviewProvider {
//    static var previews: some View {
//        NewTeamSectionView()
//    }
//}
