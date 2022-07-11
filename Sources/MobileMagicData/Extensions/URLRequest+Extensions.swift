//
//  URLRequest+Extensions.swift
//  
//
//  Created by Leonardo Vinicius Kaminski Ferreira on 26/07/21.
//

import Foundation

public enum URLMethod: String {
    case GET
    case POST
    case DELETE
    case PUT
    case PATCH
}

public extension URLRequest {
    
    static func request(with url: URL,
                               parameters: [String: String]? = nil,
                               method: URLMethod? = .GET,
                               bodyData: Data? = nil,
                               headers: [String: String]? = nil,
                               timeoutAfter timeout: TimeInterval = 15) -> URLRequest {
        var url = url
        if let parameters = parameters {
            var urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: true)
            urlComponents?.queryItems = parameters.map({ URLQueryItem(name: $0.key, value: $0.value) })
            url = urlComponents?.url ?? url
        }
        
        let urlRequest = NSMutableURLRequest(url: url)
        
        if let method = method {
            urlRequest.httpMethod = method.rawValue
        }
        
        if let bodyData = bodyData {
            urlRequest.httpBody = bodyData
        }
        
        if let headers = headers {
            for key in headers.keys {
                urlRequest.addValue(headers[key] ?? "", forHTTPHeaderField: key)
            }
        }
        
        if timeout > 0 {
            urlRequest.timeoutInterval = timeout
        }
        
        return urlRequest as URLRequest
    }
    
    var urlCacheKey: String {
        guard let url = url else {
            return ""
        }
        
        var hashValue = "?keyHash="
        
        if let httpMethod = httpMethod {
            hashValue.append(httpMethod)
        }
        
        if let httpBody = httpBody,
            let bodyString = String(data: httpBody, encoding: .utf8){
            hashValue.append(bodyString.filter{ !" \n\t\r".contains($0) })
        }
        
        return url.path.appending(hashValue)
    }
}

public extension URL {
    var queryParameters: [String: String]? {
        guard
            let components = URLComponents(url: self, resolvingAgainstBaseURL: true),
            let queryItems = components.queryItems else { return nil }
        return queryItems.reduce(into: [String: String]()) { (result, item) in
            result[item.name] = item.value
        }
    }
}

