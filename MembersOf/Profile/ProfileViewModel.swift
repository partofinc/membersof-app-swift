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
            }
        }
        
        @Published var firstName: String = "Name"
        @Published var lastName: String = "Lastname"
        
        @LightStorage(key: .userId)
        var userId: String?
        
        fileprivate let storage: Storage = .shared
        private var socialFetcher: Storage.Fetcher<Social>?
        
        func fetch() {
            guard let userId else { return }
            guard let member: Member = storage.find(key: "id", value: userId) else { return }
            me = member
            socialFetcher = storage.fetch()
                .assign(to: \.social, on: self)
//                .filter(with: .init(format: "member.id == %@", userId))
//                .filter(by: \.member!.id, value: .init(uuidString: userId)!)
                .run(sort: [.init(\.order)])
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
            guard let userId else { return }
            let member = Member(
                id: UUID(uuidString: userId)!,
                firstName: firstName.trimmingCharacters(in: .whitespacesAndNewlines),
                lastName: lastName.isEmpty ? nil : lastName.trimmingCharacters(in: .whitespacesAndNewlines)
            )
            guard me != member else { return }
            me = member
            Task {
                try await self.storage.save(member)
            }
        }
        
        func signOut() {
            userId = nil
            me = .local
        }
        
        func singIn(_ member: Member) {
            me = member
            userId = member.id.uuidString
            fetch()
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
