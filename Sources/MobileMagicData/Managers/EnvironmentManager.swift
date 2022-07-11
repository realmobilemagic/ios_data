//
//  EnvironmentManager.swift
//  
//
//  Created by Leonardo Vinicius Kaminski Ferreira on 26/07/21.
//

import Foundation

public class EnvironmentManager {
    
    public static let shared: EnvironmentManager = EnvironmentManager()
    
    public var environment: AppEnvironment = .production
    
    public var isExtensionApp: Bool = false
}

public enum AppEnvironment: String {
    case staging
    case production
    
    public var isProduction: Bool {
        self == .production
    }
    
    public var isStaging: Bool {
        self == .staging
    }
}

