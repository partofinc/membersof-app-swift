//
//  ContentView.swift
//  MembersOf
//
//  Created by Ravil Khusainov on 7/29/22.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            EventsView()
                .tabItem {
                    Label("Events", systemImage: "calendar")
                }
            MembershipsView()
                .tabItem {
                    Label("Memberships", systemImage: "creditcard")
                }
            TeamsView()
                .tabItem {
                    Label("Teams", systemImage: "person.3")
                }
            ProfileView()
                .tabItem {
                    Label("Profile", systemImage: "person.circle")
                }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
