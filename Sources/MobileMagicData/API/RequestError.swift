//
//  RequestError.swift
//  MobileMagic
//
//  Created by Evandro Harrison Hoffmann on 15/07/2020.
//  Copyright © 2020 MobileMagic. All rights reserved.
//

import Foundation

public enum RequestError: Error, LocalizedError {
    case invalidUrl
    case timeOut(String?)
    case unknown(String?)
    case cancelled(String?)
    case generic(String?)
    case noConnection(String?)
    case unauthorized
    case invalidData
    case uploadFailed(String?)
    case cacheRule(String?)
    case parse(String?)
    
    var localizedDescription: String {
        switch self {
        case .invalidUrl: return "invalid url"
        case .timeOut(let message): return message ?? "timeout"
        case .unknown(let message): return message ?? "unknown"
        case .cancelled(let message): return message ?? "cancelled"
        case .generic(let message): return message ?? "generic"
        case .noConnection(let message): return message ?? "no connection"
        case .unauthorized: return "unauthorized"
        case .invalidData: return "invalid data"
        case .uploadFailed(let message): return message ?? "upload failed"
        case .cacheRule(let message): return message ?? "cache rule"
        case .parse(let message): return message ?? "parse"
        }
    }
    
    public static func == (lhs: RequestError, rhs: RequestError) -> Bool {
        switch (lhs, rhs) {
        case (.invalidUrl, .invalidUrl): return true
        case (.timeOut, .timeOut): return true
        case (.unknown, .unknown): return true
        case (.cancelled, .cancelled): return true
        case (.generic, .generic): return true
        case (.noConnection, .noConnection): return true
        case (.unauthorized, .unauthorized): return true
        case (.invalidData, .invalidData): return true
        case (.uploadFailed, .uploadFailed): return true
        case (.cacheRule, .cacheRule): return true
        case (.parse, .parse): return true
        default: return false
        }
    }
}
