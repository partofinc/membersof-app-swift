//
//  MembershipsViewModel.swift
//  MembersOf
//
//  Created by Ravil Khusainov on 8/2/22.
//

import Foundation
import Combine

extension MembershipsView {
    
    @MainActor
    final class ViewModel: ObservableObject {
        
        @Published var memberships: [Membership] = []
                
        func create(_ membership: Membership) {
            memberships.insert(membership, at: 0)
        }
    }
}
