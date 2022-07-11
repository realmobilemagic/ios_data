//
//  DataBaseManager.swift
//  MobileMagic
//
//  Created by Evandro Harrison Hoffmann on 07/07/2020.
//  Copyright © 2020 MobileMagic. All rights reserved.
//

import Foundation
import CoreData

public class DataBaseManager {
    
    public static var shared: DataBaseManager = {
        let manager = DataBaseManager()
        manager.database = .init(databaseName: "MobileMagicAPI")
        return manager
    }()
    
    var isLogEnabled: Bool = false
    
    var database: CoreDataAccess!
    
    private init() {}
    
    public func save() {
        database.saveContext()
    }
}
