//
//  JSONHelper.swift
//  MembersOf
//
//  Created by Ravil Khusainov on 2023-01-31.
//

import Foundation
import Combine

final class JSONHelper {
    
    static let shared: JSONHelper = .init()
    
    let encoder: JSONEncoder = .init()
    let decoder: JSONDecoder = .init()
    let catcher: PassthroughSubject<Never, Faulure> = .init()
    
    func decode<T: Decodable>(_ type: T.Type, from data: Data) -> T? {
        do {
            return try decoder.decode(type, from: data)
        } catch {
            catcher.send(completion: .failure(.decoding(error)))
            return nil
        }
    }
    
    func encode<T: Encodable>(value: T) -> Data? {
        do {
            return try encoder.encode(value)
        } catch {
            catcher.send(completion: .failure(.encoding(error)))
            return nil
        }
    }
}

extension JSONHelper {
    
    enum Faulure: Error {
        case encoding(Error)
        case decoding(Error)
    }
}
