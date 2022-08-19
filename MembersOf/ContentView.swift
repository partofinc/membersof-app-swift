//
//  ContentView.swift
//  MembersOf
//
//  Created by Ravil Khusainov on 7/29/22.
//

import SwiftUI

struct ContentView: View {
    
    #if os(iOS)
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    #endif
    @State private var selectedItem: NavigationItem? = .events
    @State private var navigation: [NavigationItem] = [
        .events,
        .memberships,
        .teams,
        .profile
    ]
    
    var body: some View {
        #if os(iOS)
        if horizontalSizeClass == .compact {
            tabBar
        } else {
            sideBar
        }
        #else
        sideBar
        #endif
    }
    
    @ViewBuilder private var tabBar: some View {
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
    
    @ViewBuilder private var sideBar: some View {
        NavigationSplitView {
            List(selection: $selectedItem) {
                Label("Events", systemImage: "calendar")
                    .tag(NavigationItem.events)
                Label("Memberships", systemImage: "creditcard")
                    .tag(NavigationItem.memberships)
                Label("Teams", systemImage: "person.3")
                    .tag(NavigationItem.teams)
                Label("Profile", systemImage: "person.circle")
                    .tag(NavigationItem.profile)
            }
        } detail: {
            switch selectedItem! {
            case .events:
                EventsView()
            case .memberships:
                MembershipsView()
            case .teams:
                TeamsView()
            case .profile:
                ProfileView()
            }
        }
    }
}

enum NavigationItem: String, Identifiable, Hashable {
    case events, memberships, teams, profile
    var id: Self { self }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
