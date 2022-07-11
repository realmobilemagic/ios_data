//
//  Credentials.swift
//  
//
//  Created by Leonardo Vinicius Kaminski Ferreira on 26/07/21.
//

import Foundation

public struct Credentials: Codable {
    public let accessToken: String
    public let tokenType: String
    public let expiresAt: String
    
    public var token: String {
        switch tokenType.lowercased() {
        case "bearer":
            return "Bearer \(accessToken)"
        default:
            return accessToken
        }
    }
    
    // MARK: - Initializers
    
    public init(accessToken: String,
                tokenType: String,
                expiresAt: String) {
        self.accessToken = accessToken
        self.tokenType = tokenType
        self.expiresAt = expiresAt
    }
    
}

