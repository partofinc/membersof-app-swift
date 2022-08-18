//
//  ProfileView.swift
//  MembersOf
//
//  Created by Ravil Khusainov on 8/5/22.
//

import SwiftUI

struct ProfileView: View {
    
    let storage: Storage = .shared
    @State var me: Member?
    
    var body: some View {
        NavigationStack {
            VStack {
                if let me {
                    Text(me.fullName)
                } else {
                    Button {
                        let member = Member(id: UUID(), firstName: "Ravil", lastName: "Khusainov")
                        me = member
                        Task {
                            try await storage.save(member)
                        }
                    } label: {
                        Text("Create me")
                    }
                }
            }
            .navigationTitle("Profile")
            .task {
                me = storage.find(key: "firstName", value: "Ravil")
            }
        }
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView()
    }
}
