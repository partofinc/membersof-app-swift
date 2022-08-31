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
        
        @Published private(set) var memberships: [Membership] = []
        @Published private(set) var me: Member = .local
        
        private let storage: Storage = .shared
        private let signer: Signer = .shared
        private var membershipsFetcher: Storage.Fetcher<Membership>?
        private var memberFetcher: AnyCancellable?
                
        init() {
            memberFetcher = signer.me
                .sink { [unowned self] member in
                    self.me = member
                    self.fetch()
                }
        }
        
        private func fetch() {
            membershipsFetcher = storage.fetch()
                .filter(by: { [unowned self] ship in
                    guard let crew = ship.team.crew else { return false }
                    return crew.contains(where: {$0.member.id == self.me.id})
                })
                .assign(to: \.memberships, on: self)
                .run(sort: [.init(\.createDate, order: .reverse)])
        }
    }
}
