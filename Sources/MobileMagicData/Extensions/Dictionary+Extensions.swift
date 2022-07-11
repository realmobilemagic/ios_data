//
//  Dictionary+Extensions.swift
//  
//
//  Created by Leonardo Vinicius Kaminski Ferreira on 26/07/21.
//

import Foundation

public extension Dictionary {
    var data: Data? {
        return try? JSONSerialization.data(withJSONObject: self, options: [])
    }
}

