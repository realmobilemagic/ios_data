//
//  DownloadManager.swift
//  LottieFiles
//
//  Created by Evandro Harrison Hoffmann on 24/03/2021.
//  Copyright © 2021 LottieFiles. All rights reserved.
//

import Foundation

public class DownloadManager: NSObject {
    public static let shared: DownloadManager = .init()
    
    public var tasks: [String: URLSessionDataTask] = [:]
    
    /// Temp folder to app directory
    public static var tempDirectoryURL: URL {
        if #available(iOS 10.0, *) {
            return FileManager.default.temporaryDirectory
        }
        
        return URL(fileURLWithPath: NSTemporaryDirectory())
    }
    
    /// Temp downloads folder
    public static var downloadsDirectoryURL: URL {
        DownloadManager.tempDirectoryURL.appendingPathComponent("downloads")
    }
    
    /// Returns url for download foder with file name
    /// - Parameter url: File url url
    /// - Returns: url to file temp folder
    public static func downloadDirectoryURL(directory: URL, file url: URL) -> URL {
        directory.appendingPathComponent(url.lastPathComponent)
    }
    
    /// Downloads a file
    /// - Parameters:
    ///   - url: url to download from
    ///   - downloadFolder: download folder, defaults to `downloads`
    ///   - completion: returns downloaded file URL
    public func download(from url: URL, to downloadFolder: URL = downloadsDirectoryURL, force: Bool = false, completion: @escaping (URL?) -> Void) {
        let downloadUrl = DownloadManager.downloadDirectoryURL(directory: downloadFolder, file: url)
        
        if !force, FileManager.default.fileExists(atPath: downloadUrl.absoluteString) {
            completion(downloadUrl)
            return
        }
        
        DownloadManager.shared.tasks[url.absoluteString]?.cancel()
        DownloadManager.shared.tasks[url.absoluteString] = URLSession.shared.dataTask(with: url) { (data, response, error) in
            guard error == nil, let data = data else {
                "error in download, \(String(describing: error)), \(error?.localizedDescription ?? "")".log()
                DispatchQueue.main.async {
                    completion(url)
                }
                return
            }
          
            do {
                try FileManager.default.createDirectory(at: downloadFolder, withIntermediateDirectories: true, attributes: nil)
                try data.write(to: downloadUrl)
                
                DispatchQueue.main.async {
                    completion(downloadUrl)
                }
            } catch {
                "Failed to save downloaded data: \(error.localizedDescription)".log()
                DispatchQueue.main.async {
                    completion(nil)
                }
            }
        }
        DownloadManager.shared.tasks[url.absoluteString]?.resume()
    }
}
