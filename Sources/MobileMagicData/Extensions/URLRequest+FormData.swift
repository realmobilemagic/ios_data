//
//  URLRequest+FormData.swift
//  
//
//  Created by Evandro Harrison Hoffmann on 08/02/2022.
//

import Foundation

public extension URLRequest {
    
    /// Adds multipart form data to URL request
    /// - Parameters:
    ///   - fileURL: file URL
    ///   - contentType: eg. image/svg+xml
    mutating func addMultipartFormData(_ fileURL: URL, contentType: String) {
        addMultipartFormData(try? Data(contentsOf: fileURL), fileName: fileURL.lastPathComponent, contentType: contentType)
    }
    
    /// Adds multipart form data to URL request
    /// - Parameters:
    ///   - fileData: data of file
    ///   - fileName: name of the file
    ///   - contentType: eg. image/svg+xml
    mutating func addMultipartFormData(_ fileData: Data?, fileName: String, contentType: String) {
        guard let fileData = fileData else { return }
        // generate boundary string using a unique string
        let boundary = UUID().uuidString
                
        // Content-Type is multipart/form-data, this is the same as submitting form data with file upload
        // in a web browser
        setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
                 
        let paramName = "file"
        var data = Data()
        // Add the file data to the raw http request data
        data.append("\r\n--\(boundary)\r\n".data(using: .utf8)!)
        data.append("Content-Disposition: form-data; name=\"\(paramName)\"; filename=\"\(fileName)\"\r\n".data(using: .utf8)!)
        data.append("Content-Type: \(contentType)\r\n\r\n".data(using: .utf8)!)
                data.append(fileData)
                data.append("\r\n--\(boundary)--\r\n".data(using: .utf8)!)
        httpBody = data
        // do not forget to set the content-length!
        setValue(String(data.count), forHTTPHeaderField: "Content-Length")
    }
}
