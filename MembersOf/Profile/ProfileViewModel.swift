//
//  ProfileViewModel.swift
//  MembersOf
//
//  Created by Ravil Khusainov on 8/23/22.
//

import Foundation
import Combine
import Models

extension ProfileView {
    
    @MainActor
    final class ViewModel: ObservableObject {
        
        @Published var social: [Social] = [] {
            didSet {
                calculateMedia()
            }
        }
        @Published var existingMedia: [Social.Media] = []
        @Published var missingMedia: [Social.Media] = []
        @Published var addingMedia: Social.Media?
        @Published var addingAccount: String = ""
        @Published var me: Member = .local {
            didSet {
                firstName = me.firstName
                lastName = me.lastName ?? ""
                fetch()
            }
        }
        @Published var deletingSocial: Social?
        var socialConfirmationTitle: String { deletingSocial?.title ?? "" }
        var signedIn: Bool { signer.signedIn }
        
        var firstName: String = "Name"
        var lastName: String = "Lastname"
        
        let storage: Storage
        let signer: Signer
        
        private var cancellers: Set<AnyCancellable> = []
        
        init(_ signer: Signer) {
            self.signer = signer
            self.storage = signer.storage
            
             signer.me
                .sink { [unowned self] member in
                    self.me = member
                }
                .store(in: &cancellers)
        }
        
        func fetch() {
            storage.fetch(Social.self)
                .filter(by: {$0.member?.id == self.me.id})
                .sort(by: [.init(\.order)])
                .catch{_ in Just([])}
                .assign(to: \.social, on: self)
                .store(in: &cancellers)
        }
        
        func addSocial() {
            guard let addingMedia else { return }
            Task {
                var order = self.social.map(\.order).last ?? 0
                order += 1
                try await self.storage.save(Social(id: UUID(), media: addingMedia, account: addingAccount, order: order, memberId: me.id, teamId: nil))
                DispatchQueue.main.async {
                    self.addingAccount = ""
                    self.addingMedia = nil
                }
            }
        }
        
        func delete(_ social: Social) {
            Task {
                try await self.storage.delete(social)
            }
        }
        
        func save() {
            let member = Member(
                id: me.id,
                firstName: firstName.trimmingCharacters(in: .whitespacesAndNewlines),
                lastName: lastName.isEmpty ? nil : lastName.trimmingCharacters(in: .whitespacesAndNewlines)
            )
            guard me != member else { return }
            Task {
                try await self.storage.save(member)
            }
        }
        
        func signOut() {
            signer.signOut()
        }
        
        func singIn(_ member: Member) {
            Task {
                try await self.storage.save(member)
                DispatchQueue.main.async {
                    self.signer.signIn(member)
                }
            }
        }
        
        private func calculateMedia() {
            let all: [Social.Media] = .all
            existingMedia = all.filter{social.map(\.media).contains($0)}
            missingMedia = all.filter{!existingMedia.contains($0)}
        }
    }
    
    enum Sheet: Identifiable {
        case exit
        
        var id: Self { self }
    }
}
