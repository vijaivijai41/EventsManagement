//
//  EventModel.swift
//  OfflineEvent
//
//  Created by Vijay on 11/06/20.
//  Copyright © 2020 Vijay. All rights reserved.
//

import Foundation

enum EventStatus: String,Codable {
    case created = "CREATED"
    case updated = "UPDATED"
    case deleted = "DELETED"
}

struct EventModel: Codable {
    let uuid : String
    let name: String
    let location: String
    let date: String
    let time: String
    let category: String
    var isServerUpdated: Bool?
    var status: EventStatus?
    
    mutating func isServerUpdate(status: Bool) {
        self.isServerUpdated = status
    }
}

