//
//  OELocalDbHandler.swift
//  OfflineEvent
//
//  Created by Vijay on 11/06/20.
//  Copyright © 2020 Vijay. All rights reserved.
//


import Foundation

import Foundation
import UIKit
import CoreData

let appDelegate = UIApplication.shared.delegate as! AppDelegate

class OELocalDbHandler {
    
    private lazy var privateManagedObjectContext: NSManagedObjectContext = {
        // Initialize Managed Object Context
        var managedObjectContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        // Configure Managed Object Context
        managedObjectContext.persistentStoreCoordinator = appDelegate.persistentContainer.persistentStoreCoordinator
        
        return managedObjectContext
    }()
    
    private lazy var mainManagedObjectContext: NSManagedObjectContext = {
        
        var managedObjectContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = appDelegate.persistentContainer.persistentStoreCoordinator
        return managedObjectContext
        
    }()
    
    func saveCoreData<T: Codable>(_ results:Data ,returnClass: T.Type, completionHandler:(Result<Bool,ErrorHandler>)->()) {
        do {
            guard let codableContext = CodingUserInfoKey.init(rawValue: "context") else {
                fatalError("Failed context")
            }
            let decoder = JSONDecoder()
            decoder.userInfo[codableContext] = privateManagedObjectContext
            // Parse JSON data
            _ = try decoder.decode(returnClass.self, from: results)
            do {
                try privateManagedObjectContext.save()
                completionHandler(.success(true))
            } catch {
                completionHandler(.failure(.serviceError))
            }
        } catch {
            completionHandler(.failure(.serviceError))
        }
    }
    
    ///Local data fetch from core data
    func fetchLocalData<T: NSManagedObject>(entityName:String,completionHandler:(Result<[T],ErrorHandler>)->()){
        let fetchRequest = NSFetchRequest<T>(entityName: entityName)

        do {
            let result = try mainManagedObjectContext.fetch(fetchRequest)
            return completionHandler(.success(result))
        } catch _ {
            return completionHandler(.failure(.nodata))
        }
    }
    
    ///Local data fetch from core data
    func fetchLocalDataIsExcists(entityName:String) -> Bool {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
        do {
            let result = try mainManagedObjectContext.fetch(fetchRequest)
            if result.count > 0 {
                return true
            }
            return false
        } catch _ {
            return false
        }
    }
     
    
    /// Delete Event list and updated
    /// - Parameter budgetId: Budget ID
    /// - Parameter completionHandler: completion success
    /// - Parameter failure: failure error handling
    func deleteEvent(name:String, completionHandler:(Result<Bool, ErrorHandler>)->()) {
        let fetchRequest = NSFetchRequest<EventObject>(entityName: "EventObject")
        do {
            let result = try privateManagedObjectContext.fetch(fetchRequest)
            guard let resultFilter = result.filter({$0.name == name}).first else { return }
            privateManagedObjectContext.delete(resultFilter)
            //result.removeAll(where: {$0.budgetId == budgetId})
            do {
                try privateManagedObjectContext.save()
                completionHandler(.success(true))
            } catch _ {
                completionHandler(.failure(.networkError))
            }
        }catch _ {
            completionHandler(.failure(.networkError))
        }
    }
    
    
    func updateEvent(updateObject: EventObject, completionHandler:(Result<Bool, ErrorHandler>)->()) {
        let fetchRequest = NSFetchRequest<EventObject>(entityName: "EventObject")
        do {
            var result = try privateManagedObjectContext.fetch(fetchRequest)
            
            guard let index = result.firstIndex(of: updateObject) else { return }
            result[index] = updateObject

            do {
                try privateManagedObjectContext.save()
                completionHandler(.success(true))
            } catch _ {
                completionHandler(.failure(.networkError))
            }
        }catch _ {
            completionHandler(.failure(.networkError))
        }
    }
}




extension Array where Element: Equatable {
    mutating func remove(object: Element) {
        guard let index = firstIndex(of: object) else { return }
        remove(at: index)
    }
}
