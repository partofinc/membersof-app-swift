//
//  NewClubViewModel.swift
//  MembersOf
//
//  Created by Ravil Khusainov on 8/2/22.
//

import Foundation
import Combine
//import SwiftUI

extension NewTeamView {
    
    @MainActor
    final class ViewModel: ObservableObject {
        
        @Published var name: String = ""
        @Published var brief: String = ""
        
        @Published var socials: [Social] = []
        @Published var medias: [Social.Media] = .all
        @Published var media: Social.Media = .instagram
        @Published var account: String = ""
        
        private let storage: Storage = .shared
        private var me: Member = .local
        
        @LightStorage(key: .userId)
        private var userId: String?
        
        init() {
            restoreUser()
        }
        
        func addSocial() {
            let order = socials.last?.order ?? 0
            socials.append(.init(id: UUID(), media: media, account: account, order: order, memberId: nil, teamId: nil))
            
            account = ""
            
            medias.removeAll(where: {$0 == media})
            if let m = medias.first {
                media = m
            }
        }
        
        func remove(_ social: Social) {
            socials.removeAll(where: {$0.id == social.id})
            medias.insert(social.media, at: 0)
            media = social.media
            account = ""
        }
        
        func create() {
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
        }
        
        private func restoreUser() {
            guard let userId else { return }
            guard let user: Member = storage.find(key: "id", value: userId) else { return }
            me = user
        }
    }
}

