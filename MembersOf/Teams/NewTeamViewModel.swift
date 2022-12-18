//
//  NewClubViewModel.swift
//  MembersOf
//
//  Created by Ravil Khusainov on 8/2/22.
//

import Foundation
import Combine
import Models

extension NewTeamView {
    
    @MainActor
    final class ViewModel: ObservableObject {
        
        @Published var name: String = ""
        @Published var brief: String = ""
        
        @Published var socials: [Social] = []
        @Published var medias: [Social.Media] = .all
        @Published var media: Social.Media?
        @Published var account: String = ""
        
        private let storage: Storage
        private let signer: Signer
        
        private var me: Member = .local
        private var userCancellable: AnyCancellable?
        
        var canCreate: Bool {
            !name.isEmpty && !brief.isEmpty
        }
        
        init(_ signer: Signer) {
            self.signer = signer
            self.storage = signer.storage
            
            userCancellable = signer.me
                .sink { [unowned self] member in
                    self.me = member
                }
        }
        
        func addSocial() {
            guard let media else { return }
            let order = socials.last?.order ?? 0
            socials.append(.init(id: UUID(), media: media, account: account, order: order + 1, memberId: nil, teamId: nil))
            
            account = ""
            self.media = nil
            
            medias.removeAll(where: {$0 == media})
        }
        
        func remove(_ social: Social) {
            socials.removeAll(where: {$0.id == social.id})
            medias.insert(social.media, at: 0)
        }
        
        func create() -> Team {
            let supervisor = Supervisor(id: UUID(), role: .owner, order: 0, member: me, teamId: nil)
            let team = Team(
                id: UUID(),
                name: name,
                brief: brief,
                createDate: .now,
                social: socials,
                crew: [supervisor]
            )
            Task {
                do {
                    try await storage.save(team)
                } catch {
                    print(error)
                }
            }
            return team
        }
    }
}

