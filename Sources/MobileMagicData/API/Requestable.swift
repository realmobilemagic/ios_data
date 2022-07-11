//
//  GraphQL.swift
//  MobileMagic
//
//  Created by Evandro Harrison Hoffmann on 15/07/2020.
//  Copyright © 2020 MobileMagic. All rights reserved.
//

import Foundation

public protocol Requestable {
    var shouldCache: Bool { get }
    var urlRequest: URLRequest { get }
}

public extension Requestable {
    
    /// Make URL request with result type
    /// - Parameters:
    ///   - request: URLRequest
    ///   - shouldCache: if should cache or not
    ///   - responseType: Type of response
    ///   - completion: Result<Data, RequestError>
    func getData(responseType: APIResponse = .localOrRemote, completion: @escaping (Result<Data, RequestError>) -> Void) {
        let database = DataBaseManagerCacheAPI()
        var didReturnFromCache = false
        
        /// internal method for handling main thread dispatch
        func handleCompletionOnMain(_ value: Result<Data, RequestError>, type: APIResponse) {
            DispatchQueue.main.async {
                switch responseType {
                case .local:
                    guard type == .local, !NetworkConnection.shared.isConnected else { return }
                    completion(value)
                case .remote:
                    guard type == .remote else { return }
                    completion(value)
                case .localOrRemote:
                    if type == .local, !NetworkConnection.shared.isConnected {
                        completion(value)
                    } else if !didReturnFromCache {
                        completion(value)
                    }
                case .localAndRemote:
                    completion(value)
                }
            }
        }
        
        let cacheKey = urlRequest.urlCacheKey
        if shouldCache, !NetworkConnection.shared.isConnected {
            if !EnvironmentManager.shared.isExtensionApp {
                database?.load(key: cacheKey, completion: { (data) in
                    guard let data = data else { return }
                    handleCompletionOnMain(.success(data), type: .local)
                    didReturnFromCache = true
                })
            }
        }
        
        if let data = urlRequest.httpBody {
            "Raw body: \(String(data: data, encoding: .utf8) ?? "EMPTY")".log()
        }
        
        let session = URLSession.shared
        let dataTask = session.dataTask(with: urlRequest) { (data, response, error) in
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
            } else if let data = data {
                handleCompletionOnMain(.success(data), type: .remote)
                
                if EnvironmentManager.shared.isExtensionApp || shouldCache {
                    database?.save(data, to: cacheKey)
                }
            } else {
                handleCompletionOnMain(.failure(.invalidData), type: .remote)
            }
        }
        dataTask.resume()
    }
}
