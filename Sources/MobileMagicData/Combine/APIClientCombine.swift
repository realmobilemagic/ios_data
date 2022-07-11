//
//  APIClientCombine.swift
//  
//
//  Created by Leonardo Vinicius Kaminski Ferreira on 02/08/21.
//

import Foundation
import Combine

public struct APIClientCombine {

    public struct Response<T> {
        public let value: T
        public let response: URLResponse
    }
    
    public init() {}
    
    public func run<T: Codable>(_ request: URLRequest) -> AnyPublisher<Response<T>, Error> {
        return URLSession.shared
            .dataTaskPublisher(for: request)
            .tryMap { result -> Response<T> in
                if let value: GraphQLResponse<T> = try? GraphQLResponse<T>.decode(from: result.data) {
                    return Response(value: value.data, response: result.response)
                } else if let value: T = try? T.decode(from: result.data) {
                    return Response(value: value, response: result.response)
                }
                let value = try JSONDecoder().decode(T.self, from: result.data)
                return Response(value: value, response: result.response)
            }
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
}

