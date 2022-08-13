//
//  NewClubViewModel.swift
//  MembersOf
//
//  Created by Ravil Khusainov on 8/2/22.
//

import Foundation
import Combine

extension NewTeamView {
    
    @MainActor
    final class ViewModel: ObservableObject {
        
        @Published var name: String = ""
        @Published var brief: String = ""
        
        @Published var socials: [Social] = []
        @Published var medias: [Social.Media] = .all
        @Published var media: Social.Media = .instagram
        @Published var account: String = ""
        
        func addSocial() {
            socials.append(.init(id: UUID(), media: media, account: account))
            
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
        
        func create() -> Team {
            .init(
                id: UUID(),
                name: name,
                brief: brief,
                social: socials,
                crew: [
                    .init(
                        id: UUID(),
                        role: .owner,
                        order: 0,
                        member: .init(id: UUID(), firstName: "Ravil", lastName: "Khusainov")
                    )
                ]
            )
        }
    }
}

