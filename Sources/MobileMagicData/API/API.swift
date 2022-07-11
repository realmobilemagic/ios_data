//
//  LFAPI.swift
//  MobileMagic
//
//  Created by Evandro Harrison Hoffmann on 15/07/2020.
//  Copyright © 2020 MobileMagic. All rights reserved.
//

import Foundation

public class API<R: Requestable, C: Codable> {
    
    // MARK: - Initializers
    
    public init() {} 
    
    // MARK: - Methods
    
    /// Create URL request with GraphQL
    /// - Parameters:
    ///   - graphQL: GraphQL query
    ///   - response: Type of response
    ///   - completion: Result<Codable, RequestError>
    public func perform(_ request: R, response type: APIResponse = .localOrRemote, completion: @escaping (Result<C, RequestError>) -> Void) {
        perform(request.urlRequest, shouldCache: request.shouldCache, responseType: type, completion: completion)
    }
    
    /// Make URL request with result type
    /// - Parameters:
    ///   - request: URLRequest
    ///   - shouldCache: if should cache or not
    ///   - responseType: Type of response
    ///   - completion: Result<Codable, RequestError>
    public func perform(_ request: URLRequest, shouldCache: Bool, responseType: APIResponse, completion: @escaping (Result<C, RequestError>) -> Void) {
        var didReturnFromCache = false
        
        /// internal method for handling main thread dispatch
        func handleCompletionOnMain(_ value: Result<C, RequestError>, type: APIResponse) {
            DispatchQueue.main.async {
                switch responseType {
                case .local:
                    guard type == .local, !NetworkConnection.shared.isConnected else { return }
                    didReturnFromCache = true
                    completion(value)
                case .remote:
                    guard type == .remote else { return }
                    completion(value)
                case .localOrRemote:
                    if type == .local, !NetworkConnection.shared.isConnected {
                        didReturnFromCache = true
                        completion(value)
                    } else if !didReturnFromCache {
                        didReturnFromCache = true
                        completion(value)
                    }
                case .localAndRemote:
                    completion(value)
                }
            }
        }
        
        let cacheKey = request.urlCacheKey
        if shouldCache, !NetworkConnection.shared.isConnected {
            if !EnvironmentManager.shared.isExtensionApp {
                DataBaseManagerCacheAPI()?.load(key: cacheKey, completion: { (data) in
                    guard let decoded: C = Self.decoded(data: data) else { return }
                    handleCompletionOnMain(.success(decoded), type: .local)
                    didReturnFromCache = true
                })
            }
        }
        
        if let data = request.httpBody {
            "Raw body: \(String(data: data, encoding: .utf8) ?? "EMPTY")".log()
        }
        
        let session = URLSession.shared
        let dataTask = session.dataTask(with: request) { (data, response, error) in
            if let data = data {
                "Raw response: \(String(data: data, encoding: .utf8) ?? "EMPTY")".log()
            }
            
            if let error = error {
                let urlError = error as NSError
                switch urlError.code {
                case NSURLErrorTimedOut:
                    handleCompletionOnMain(.failure(.timeOut(error.localizedDescription)), type: .remote)
                case NSURLErrorNotConnectedToInternet:
                    handleCompletionOnMain(.failure(.noConnection(error.localizedDescription)), type: .remote)
                case URLError.cancelled.rawValue:
                    handleCompletionOnMain(.failure(.cancelled(error.localizedDescription)), type: .remote)
                default:
                    handleCompletionOnMain(.failure(.unknown(error.localizedDescription)), type: .remote)
                }
            } else if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 401  {
                handleCompletionOnMain(.failure(.unauthorized), type: .remote)
            } else if let decoded: C = Self.decoded(data: data) {
                handleCompletionOnMain(.success(decoded), type: .remote)
                
                // save cache
                guard let data = data else { return }
                
                if EnvironmentManager.shared.isExtensionApp || shouldCache {
                    DataBaseManagerCacheAPI()?.save(data, to: cacheKey)
                }
            } else {
                handleCompletionOnMain(.failure(.invalidData), type: .remote)
            }
        }
        dataTask.resume()
    }
    
    /*func getFromDatabase(_ cacheKey: String, completion: @escaping (Result<C, RequestError>) -> Void) {
        
    }
    
    func saveToDatabase(_ data: Data?, to key: String) {
        
    }*/
    
    /// Decodes data based on either graphql structure or normal json structure
    /// - Parameter data: data to decode
    /// - Returns: Codable object
    public static func decoded<C: Codable>(data: Data?) -> C? {
        if let decoded: GraphQLResponse<C> = try? GraphQLResponse<C>.decode(from: data) {
            return decoded.data
        } else if let decoded: C = try? C.decode(from: data) {
            return decoded
        }
        
        return nil
    }
    
}

public enum APIResponse {
    case local
    case remote
    case localOrRemote
    case localAndRemote
}
