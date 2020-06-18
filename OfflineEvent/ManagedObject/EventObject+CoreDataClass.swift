//
//  EventObject+CoreDataClass.swift
//  OfflineEvent
//
//  Created by Vijay on 11/06/20.
//  Copyright © 2020 Vijay. All rights reserved.
//
//

import Foundation
import CoreData


public class EventObject: NSManagedObject,Codable {
    
    // MARK: - Codable setUp
    private enum CodingKeys: String, CodingKey {
        case uuid
        case name
        case date
        case time
        case category
        case location
        case isServerUpdated
        case status
    }
    
    // MARK: - Decodable
    required convenience public init(from decoder: Decoder) throws {
        ///Fetch context for codable
        guard let codableContext = CodingUserInfoKey.init(rawValue: "context"),
            let manageObjContext = decoder.userInfo[codableContext] as? NSManagedObjectContext,
            let manageObjList = NSEntityDescription.entity(forEntityName: "EventObject", in: manageObjContext) else {
                fatalError("failed")
        }
        
        self.init(entity: manageObjList, insertInto: manageObjContext)
        
        let values = try decoder.container(keyedBy: CodingKeys.self)
        uuid = try values.decode(String.self, forKey: .uuid)
        name = try values.decode(String.self, forKey: .name)
        date = try values.decode(String.self, forKey: .date)
        time = try values.decode(String.self, forKey: .time)
        category = try values.decode(String.self, forKey: .category)
        location = try values.decode(String.self, forKey: .location)
        if let serverUpdate = try? values.decode(Bool.self, forKey: .isServerUpdated) {
            isServerUpdated = serverUpdate
        } else {
            isServerUpdated = true
        }
        
        if let _status = try? values.decode(String.self, forKey: .status) {
            status = _status
        } else {
            status = "CREATED"
        }
        
    }
    
    // MARK: - Encoding the data
    public func encode(to encoder: Encoder) throws {
        do {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(uuid, forKey: .uuid)
            try container.encode(name, forKey: .name)
            
            try container.encode(date, forKey: .date)
            try container.encode(time, forKey: .time)
            try container.encode(category, forKey: .category)
            try container.encode(location, forKey: .location)
            try container.encode(isServerUpdated, forKey: .isServerUpdated)
            try container.encode(status, forKey: .status)
            
        } catch {
            print(error.localizedDescription)
        }
        
    }
}
