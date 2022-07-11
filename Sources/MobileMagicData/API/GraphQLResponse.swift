//
//  APIResponse.swift
//  LottieFiles
//
//  Created by Evandro Harrison Hoffmann on 15/07/2020.
//  Copyright © 2020 LottieFiles. All rights reserved.
//

import Foundation

public struct GraphQLResponse<T: Codable>: Codable {
    public var data: T
}
