//
//  DataBaseManager+Cache.swift
//  MobileMagic
//
//  Created by Leonardo Vinicius Kaminski Ferreira on 13/07/21.
//  Copyright © 2021 MobileMagic. All rights reserved.
//

import Foundation
import CoreData

// MARK: - Caching

public class DataBaseManagerCacheAPI {
    
    let managedObjectContext: NSManagedObjectContext
    private let coreDataStack = DataBaseManager.shared.database
    private let privateMOC = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
    
    public init?() {
        if let persistentContainer = coreDataStack?.persistentContainer {
            self.managedObjectContext = persistentContainer.viewContext
        } else {
            return nil
        }
        
        privateMOC.parent = self.managedObjectContext
    }
    
    public func save(_ data: Data?, to key: String) {
        self.privateMOC.performAndWait {
            let fetchQuery = NSFetchRequest<NSFetchRequestResult>(entityName: String(describing: CacheAPI.self))
            fetchQuery.predicate = NSPredicate(format: "key = %@", key)
            do {
                if let first = try self.privateMOC.fetch(fetchQuery).first as? CacheAPI {
                    first.data = data /// updates the data
                } else {
                    let entity = NSEntityDescription.entity(forEntityName: String(describing: CacheAPI.self), in: self.managedObjectContext)!
                    let object = NSManagedObject(entity: entity, insertInto: self.privateMOC) as! CacheAPI
                    object.key = key
                    object.data = data
                    
                    self.privateMOC.insert(object)
                    print("$%# CORE DATA: Insert [\(key)] succeeded")
                }
                synchronize()
            } catch {
                print("$%# CORE DATA: \(error.localizedDescription)")
            }
        }
    }
    
    public func load(key: String, completion: @escaping (Data?) -> Void) {
        self.privateMOC.performAndWait {
            let fetchQuery = NSFetchRequest<NSFetchRequestResult>(entityName: String(describing: CacheAPI.self))
            fetchQuery.predicate = NSPredicate(format: "key = %@", key)
            do {
                if let first = try self.privateMOC.fetch(fetchQuery).first as? CacheAPI {
                    print("$%# CORE DATA: Fetch [\(key)] succeeded")
                    completion(first.data)
                    return
                }
                completion(nil)
            } catch {
                print("$%# CORE DATA: \(error.localizedDescription)")
            }
        }
    }
    
    public func clear() {
        self.privateMOC.performAndWait {
            let fetchQuery = NSFetchRequest<NSFetchRequestResult>(entityName: String(describing: CacheAPI.self))
            do {
                if let models = try self.privateMOC.fetch(fetchQuery) as? [CacheAPI] {
                    models.forEach { cache in
                        self.privateMOC.delete(cache)
                        print("$%# CORE DATA: Delete [\(cache.key ?? "")] succeeded")
                    }
                    synchronize()
                    return
                }
                print("$%# CORE DATA: Didn't get any models to perform deletion.")
            } catch {
                print("$%# CORE DATA: \(error.localizedDescription)")
            }
        }
    }
    
    private func synchronize() {
        do {
            try self.privateMOC.save() // We call save on the private context, which moves all of the changes into the main queue context without blocking the main queue.
            self.managedObjectContext.performAndWait {
                do {
                    try self.managedObjectContext.save()
                } catch {
                    print("Could not synchonize data. \(error), \(error.localizedDescription)")
                }
            }
        } catch {
            print("Could not synchonize data. \(error), \(error.localizedDescription)")
        }
    }
}
