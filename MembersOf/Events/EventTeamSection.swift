//
//  EventTeamSection.swift
//  MembersOf
//
//  Created by Ravil Khusainov on 2023-02-07.
//

import SwiftUI

struct EventTeamSection: View {
    
    @FetchRequest
    @State private(set) var teams: [Team] = [.loading]
    @State var team: Team = .loading
    @State var schedule: Schedule = .none
    @State private(set) var scheduled: [Schedule] = []
    @State private(set) var places: [Place] = [.none]
    @State var place: Place = .none
    
    @State private(set) var memberships: [Membership] = []
    @State private(set) var selectedMemberships: [UUID] = []
    
    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
    }
}

