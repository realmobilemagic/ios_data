//
//  SessionManager.swift
//  
//
//  Created by Leonardo Vinicius Kaminski Ferreira on 26/07/21.
//

import Foundation

public class SessionManager {
    
    // MARK: - Properties
    
    static var shared: SessionManager = .init()
    private(set) var credentials: Credentials?
    
    // MARK: - Initializers
    
    private init() {}
    
    // MARK: - Methods
    
    public static func setNewCredentials(_ credentials: Credentials?) {
        SessionManager.shared.credentials = credentials
    }
}
