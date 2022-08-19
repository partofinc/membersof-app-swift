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
        
        @Published fileprivate(set) var memberships: [Membership] = []
        private let storage: Storage
        private var membershipsFetcher: Storage.Fetcher<Membership>?
                
        init() {
            storage = .shared
            membershipsFetcher = storage.fetch()
                .assign(to: \.memberships, on: self)
                .run(sort: [.init(\.createDate, order: .reverse)])
        }
    }
}
