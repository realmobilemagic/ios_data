//
//  Codable+Extensions.swift
//  
//
//  Created by Leonardo Vinicius Kaminski Ferreira on 26/07/21.
//

import Foundation

public extension Encodable {
    func encode(with encoder: JSONEncoder = JSONEncoder()) throws -> Data {
        return try encoder.encode(self)
    }
    
    func asDictionary() throws -> [String: Any] {
        let data = try JSONEncoder().encode(self)
        guard let dictionary = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any] else {
            throw NSError()
        }
        return dictionary
    }
}

public extension Decodable {
    static func decode(with decoder: JSONDecoder = JSONDecoder(), from data: Data?) throws -> Self {
        guard let data = data else {
            throw CodableError.invalidData
        }
        
        do {
            return try decoder.decode(Self.self, from: data)
        } catch {
            throw error
        }
    }
    
    static func decode(with decoder: JSONDecoder = JSONDecoder(), from data: Data?) throws -> [Self] {
        guard let data = data else {
            throw CodableError.invalidData
        }
        
        do {
            return try decoder.decode([Self].self, from: data)
        } catch {
            throw error
        }
    }
}

public enum CodableError: Error {
    case invalidData
}

