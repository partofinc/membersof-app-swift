//
//  MembershipsViewModel.swift
//  MembersOf
//
//  Created by Ravil Khusainov on 8/2/22.
//

import Foundation
import Combine
import Models

extension MembershipsView {
    
    @MainActor
    final class ViewModel: ObservableObject {
        
        @Published private(set) var memberships: [Membership] = []
        @Published private(set) var me: Member = .local
        
        let storage: Storage
        let signer: Signer
        
        private var cancellers: Set<AnyCancellable> = []
                
        init(_ signer: Signer) {
            self.signer = signer
            self.storage = signer.storage
            
            signer.me
                .sink { [unowned self] member in
                    self.me = member
                    self.fetch()
                }
                .store(in: &cancellers)
        }
        
        private func fetch() {
            storage.fetch(Membership.self)
                .filter(by: { [unowned self] ship in
                    guard let crew = ship.team.crew else { return false }
                    return crew.contains(where: {$0.member.id == self.me.id})
                })
                .sort(by: [.init(\.createDate, order: .reverse)])
                .catch{_ in Just([])}
                .assign(to: \.memberships, on: self)
                .store(in: &cancellers)
        }
    }
}
