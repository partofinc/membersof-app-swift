//
//  ProfileViewModel.swift
//  MembersOf
//
//  Created by Ravil Khusainov on 8/23/22.
//

import Foundation

extension ProfileView {
    
    @MainActor
    final class ViewModel: ObservableObject {
        
        fileprivate let storage: Storage = .shared
        @Published var me: Member?
        
        @LightStorage(key: .userId)
        var userId: String?
        
        func fetch() {
            guard let userId else { return }
            me = storage.find(key: "id", value: userId)
        }
        
        func save() {
            
        }
        
        func signOut() {
            userId = nil
            me = nil
        }
    }
}
