//
//  CoreDataAccess.swift
//  MobileMagic
//
//  Created by Evandro Harrison Hoffmann on 07/07/2020.
//  Copyright © 2020 MobileMagic. All rights reserved.
//

import CoreData

class CoreDataAccess: NSObject {
    
    var databaseName: String!
    var groupName: String?
    var databaseNameSqlite: String!
    var useTempDirectory = false
    var databaseOptions: [String: Any] = [NSMigratePersistentStoresAutomaticallyOption: true, NSInferMappingModelAutomaticallyOption: true]
    
    override init(){
        super.init()
    }
    
    init(databaseName: String, useTempDirectory: Bool = false) {
        super.init()
        setDatabase(databaseName, groupName: nil, useTempDirectory: useTempDirectory)
    }
    
    func setDatabase(_ name: String, groupName: String?, useTempDirectory: Bool = false){
        databaseName = name
        databaseNameSqlite = "\(databaseName ?? "").sqlite"
        self.useTempDirectory = useTempDirectory
        self.groupName = groupName
    }
    
    // MARK: - Local Core Data stack
    
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: databaseName, managedObjectModel: managedObjectModel)
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                print("## CoreData ERROR - Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        
        var url = self.applicationDocumentsDirectory.appendingPathComponent(self.databaseNameSqlite)
        
        //configure group database
        if let groupName = self.groupName {
            let directory = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: groupName)!
            url = directory.appendingPathComponent(self.databaseNameSqlite)
        }
        
        if self.useTempDirectory, #available(tvOS 10.0, iOSApplicationExtension 10.0, watchOS 3.0, iOS 10, *) {
            let directory = FileManager.default.temporaryDirectory
            url = directory.appendingPathComponent(self.databaseNameSqlite)
        }
        
        var failureReason = "There was an error creating or loading the application's saved data."
        do {
            try coordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: url, options: self.databaseOptions)
        } catch {
            var dict = [String: AnyObject]()
            dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data" as AnyObject?
            dict[NSLocalizedFailureReasonErrorKey] = failureReason as AnyObject?
            
            dict[NSUnderlyingErrorKey] = error as NSError
            let wrappedError = NSError(domain: "YOUR_ERROR_DOMAIN", code: 9999, userInfo: dict)
            NSLog("## CoreData ERROR - Unresolved error \(wrappedError), \(wrappedError.userInfo)")
        }
        
        return coordinator
    }()
    
    // MARK: - Core Data stack
    
    lazy var applicationDocumentsDirectory: URL = {
        let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return urls[urls.count-1]
    }()
    
    lazy var managedObjectModel: NSManagedObjectModel = {
        if self.databaseName == nil {
            NSLog("## CoreData ERROR - You forgot setting up the database name")
        }
        
        let modelURL = Bundle.module.url(forResource: self.databaseName, withExtension: "momd")!
        return NSManagedObjectModel(contentsOf: modelURL)!
    }()
    
    lazy var managedObjectContext: NSManagedObjectContext = {
        let coordinator = self.persistentStoreCoordinator
        var managedObjectContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = coordinator
        return managedObjectContext
    }()
    
    // MARK: - Core Data Saving support
    
    func saveContext () {
        if managedObjectContext.hasChanges {
            do {
                try managedObjectContext.save()
            } catch {
                let nserror = error as NSError
                NSLog("## CoreData ERROR - Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
}
