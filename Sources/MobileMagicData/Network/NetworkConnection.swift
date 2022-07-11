//
//  NetworkConnection.swift
//  
//
//  Created by Evandro Harrison Hoffmann on 11/01/2022.
//

import Network
import Foundation

public class NetworkConnection: NSObject {
    
    public static var shared: NetworkConnection = .init()
    
    public var monitor: NWPathMonitor = .init()
    public var isConnected: Bool = false
    
    public func startMonitoring() {
        monitor.pathUpdateHandler = { [weak self] path in
            switch path.status {
            case .satisfied:
                self?.isConnected = true
                NetworkConnectionNotification.onNetworkStatusChanged.notify(with: true)
            default:
                self?.isConnected = false
                NetworkConnectionNotification.onNetworkStatusChanged.notify(with: false)
            }
        }
        monitor.start(queue: .global(qos: .background))
    }
    
}

public enum NetworkConnectionNotification: String {
    case onNetworkStatusChanged
    
    var notification: Notification.Name {
        Notification.Name(rawValue: rawValue)
    }
    
    func notify(with object: Any? = nil) {
        NotificationCenter.default.post(name: notification, object: object)
    }
    
    func observe<T>(queue: OperationQueue = .main, using: @escaping (T?) -> Void) {
        NotificationCenter.default.addObserver(forName: notification, object: nil, queue: queue) { notification in
            using(notification.object as? T)
        }
    }
    
    func observe(queue: OperationQueue = .main, using: @escaping () -> Void) {
        NotificationCenter.default.addObserver(forName: notification, object: nil, queue: queue) { notification in
            using()
        }
    }
}
