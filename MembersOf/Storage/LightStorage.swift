//
//  LightStorage.swift
//  MembersOf
//
//  Created by Ravil Khusainov on 8/23/22.
//

import Foundation

@propertyWrapper
struct LightStorage<Value> {
    let key: Key
    let container: UserDefaults = .standard
    
    
    var wrappedValue: Value? {
        get {
            container.object(forKey: key.rawValue) as? Value
        }
        set {
            if let newValue {
                container.set(newValue, forKey: key.rawValue)
            } else {
                container.removeObject(forKey: key.rawValue)
            }
        }
    }
}

extension LightStorage {
    
    enum Key: String {
        case userId = "user.id"
    }
}
