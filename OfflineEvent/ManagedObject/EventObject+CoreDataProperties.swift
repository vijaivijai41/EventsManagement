//
//  EventObject+CoreDataProperties.swift
//  OfflineEvent
//
//  Created by Vijay on 12/06/20.
//  Copyright © 2020 Vijay. All rights reserved.
//
//

import Foundation
import CoreData


extension EventObject {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<EventObject> {
        return NSFetchRequest<EventObject>(entityName: "EventObject")
    }

    @NSManaged public var category: String?
    @NSManaged public var date: String?
    @NSManaged public var location: String?
    @NSManaged public var name: String?
    @NSManaged public var time: String?
    @NSManaged public var uuid: String?
    @NSManaged public var isServerUpdated: Bool
    @NSManaged public var status: String?

}
