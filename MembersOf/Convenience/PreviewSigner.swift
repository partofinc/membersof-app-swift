//
//  PreviewSigner.swift
//  MembersOf
//
//  Created by Ravil Khusainov on 2022-12-01.
//

import Foundation
import Combine
import Models

final class PreviewSigner: Signer {
    
    var me: CurrentValueSubject<Models.Member, Never>
    
    var signedIn: Bool
    
    var storage: Storage
    
    init(me: CurrentValueSubject<Models.Member, Never> = .init(.local), signedIn: Bool = false, storage: Storage) {
        self.me = me
        self.signedIn = signedIn
        self.storage = storage
    }
    
    func signIn(_ member: Member) {
        
    }
    
    func signOut() {
        
    }
}

extension PreviewSigner {
    
    static var `default`: PreviewSigner {
        PreviewSigner(storage: MockStorage())
    }
}
