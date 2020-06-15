//
//  EventNetworkResource.swift
//  OfflineEvent
//
//  Created by Vijay on 12/06/20.
//  Copyright © 2020 Vijay. All rights reserved.
//

import Foundation


enum EventResource: OEServiceResource {
    
    case fetchEvent
    case addEvent(event: EventModel)
    case updateEvent(event: EventModel)
    case deleteEvent(event: EventModel)
    
    var baseURL: URL {
        return URL(string: "https://iostest.ajrgroup.in/event/vijayEvents")!
    }
    
    var method: String {
        switch self {
        case .fetchEvent:
            return ""
        case .deleteEvent(let event):
            return event.uuid
        case .updateEvent(let event):
            return event.uuid
        case .addEvent(_):
            return ""
        }
    }
    
    var params: [String : String] {
        switch self {
        case .fetchEvent:
            return [:]
        case .addEvent(let event),.updateEvent(let event):
            return  [
                "uuid": event.uuid,
                "name": event.name,
                "category": event.category,
                "location": event.location,
                "date": event.date,
                "time": event.time ]
            
        case .deleteEvent(event: ):
            return [:]
        }
    }
    
    var httpMethod: HttpMethod {
        switch self {
        case .fetchEvent:
            return .get
        case .addEvent(_):
            return .post
        case .deleteEvent(_):
            return .delete
        case .updateEvent(_):
            return .put
        }
    }
}
