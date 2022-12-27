//
//  MembersOfApp.swift
//  MembersOf
//
//  Created by Ravil Khusainov on 7/29/22.
//

import SwiftUI

@main
struct MembersOfApp: App {
    
    private let signer: AppSigner = .app
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(signer)
        }
    }
}
