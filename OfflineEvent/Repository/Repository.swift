//
//  Repository.swift
//  PaytapConfigure
//
//  Created by Vijay on 10/06/20.
//  Copyright © 2020 Vijay. All rights reserved.
//

import Foundation
import CoreData

public enum serviceCallType {
    case create
    case update
    case delete
    case read
}

class Repository {
        
    let dataStore: DataStore
    let apiHandler: OEWebserviceHandler
    let localDataHandler: OELocalDbHandler
    
    init(dataStore: DataStore, apiHandler: OEWebserviceHandler,localDataHandler: OELocalDbHandler = OELocalDbHandler()) {
        self.dataStore = dataStore
        self.apiHandler = apiHandler
        self.localDataHandler = localDataHandler
        
        dataStore.connectivity?.connectionStatusUpdate = { [weak self] status in
            guard let self = self else { return }
            if status {
                self.serverConnectionUpdate()
            }
        }
    }
    
    // fetch all events
    var getAllEvents: [EventModel] {
        return self.dataStore.eventList
    }
    
    func fetchAllEvent(onCompletion: @escaping(Result<[EventModel], ErrorHandler>) ->()) {
        let resource = EventResource.fetchEvent
        if Connectivity.instance.connectionStatus() {
            self.apiHandler.loadApiCall(networkResource: resource) { [weak self] (result) in
                guard let self = self else { return }
                switch result {
                case .success(let codable):
                    if let events = codable as? [EventModel] {
                        self.dataStore.eventList = events.filter({($0.status?.rawValue) != "DELETED"})
                        
                        if self.localDataHandler.fetchLocalDataIsExcists(entityName: "EventObject", count: events.count) {
                            if let data = self.convertData(object: events) {
                                self.localDataHandler.saveCoreData(data, returnClass: [EventObject].self) { (result) in
                                    switch result {
                                    case .success(_):
                                        print("save Successfully")
                                        
                                    case .failure(let error):
                                         onCompletion(.failure(error))
                                    }
                                }
                            }
                        }
                        onCompletion(.success(events))
                    } else {
                        onCompletion(.failure(.nodata))
                    }
                
                    
                case .failure(let error):
                    onCompletion(.failure(error))
                }
            }
        } else {
            self.localDataHandler.fetchLocalData(entityName: "EventObject") { [weak self] (result) in
                guard let self = self else { return }

                switch result {
                case .success(let model):
                    let events = assignModel(result: model) ?? []
                    self.dataStore.eventList = events
                    onCompletion(.success(events))
                case .failure(let error):
                    onCompletion(.failure(error))
                }
            }
        }
    }
    
    func fetchFromServer() {
        
    }
    
    
    
    
    func updateEvent(event: EventModel ,onCompletion: @escaping(Result<Bool, ErrorHandler>)->()) {
        if Connectivity.instance.connectionStatus() {
            let resource = EventResource.updateEvent(event: event)
            self.performCURD(event: event, type: .update, resource: resource, onCompletion: onCompletion)
        } else {
            self.localDataHandler.updateEvent(updateObject: event,isServerUpdate: false, isupdate: true, completionHandler: onCompletion)
        }
    }
    
    func deleteEvent(event: EventModel, onCompletion: @escaping(Result<Bool, ErrorHandler>)->()) {
        if Connectivity.instance.connectionStatus() {
            let resource = EventResource.deleteEvent(event: event)
            self.performCURD(event: event, type: .delete, resource: resource, onCompletion: onCompletion)
        } else {
            self.localDataHandler.updateEvent(updateObject: event, isServerUpdate: false, isupdate: false, completionHandler: onCompletion)
        }
    }
    
    func addEvent(event: EventModel, onCompletion: @escaping(Result<Bool, ErrorHandler>)->()) {
        if Connectivity.instance.connectionStatus() {
            let resource = EventResource.addEvent(event: event)
            self.performCURD(event: event, type: .create, resource: resource, onCompletion: onCompletion)
        } else {
            if let data = convertData(object: event) {
                self.localDataHandler.saveCoreData(data, returnClass: EventObject.self, completionHandler: onCompletion)
            }
        }
    }
    
    private func performCURD(event: EventModel,type: serviceCallType , resource: OEServiceResource, onCompletion: @escaping(Result<Bool, ErrorHandler>)->()) {
        self.apiHandler.loadApiCall(networkResource: resource) { [weak self] (result) in
            guard let self = self else { return }

            switch result {
            case .success(let status):
                if let _status = status as? String, _status == "OK"{
                    var eventInfo = event
                    switch type {
                    case .create:
                        
                        eventInfo.isServerUpdate(status: true)
                        if let data = self.convertData(object: eventInfo) {
                            self.dataStore.eventList.append(eventInfo)
                            self.localDataHandler.saveCoreData(data, returnClass: EventObject.self, completionHandler: onCompletion)
                        }
                    case .delete:
                        if let index = self.dataStore.eventList.firstIndex(where: { $0.name == eventInfo.name }) {
                            self.dataStore.eventList.remove(at: index)
                        }
                        self.localDataHandler.deleteEvent(name: event.name, completionHandler: onCompletion)
                    case .update:
                        if let index = self.getAllEvents.firstIndex(where: { $0.name == eventInfo.name }) {
                            self.dataStore.eventList[index] = event
                        }

                        self.localDataHandler.updateEvent(updateObject: eventInfo, isServerUpdate: true, isupdate: true, completionHandler: onCompletion)
                    case .read:
                        print("not update")
                    }
                }
            case .failure(let error):
                onCompletion(.failure(error))
            }
        }
    }
    
    
    func serverConnectionUpdate() {
        let event = getAllEvents.filter({$0.isServerUpdated ?? false == false})
        let needToAdd = event.filter({$0.status == EventStatus.created})
    
        // Add Event
        for event in needToAdd {
            self.addEvent(event: event) { (result) in
                switch result {
                case .success(_):
                    print("add success")
                case .failure(_):
                    print("add failure")
                }
            }
        }
        
        // Delete event
        let needToDelete = event.filter({$0.status == EventStatus.deleted})
        
        for event in needToDelete {
            self.deleteEvent(event: event) { (result) in
                switch result {
                case .success(_):
                    print("delete success")
                case .failure(_):
                    print("delete failure")
                }
            }
        }
        
        // Update Event
        let needToUpdate = event.filter({$0.status == EventStatus.updated})
        for event in needToUpdate {
            self.updateEvent(event: event) { (result) in
                switch result {
                case .success(_):
                    print("update success")
                case .failure(_):
                    print("update failure")
                }
            }
        }
    }
    
    
    /// Assign model values to the core data results
    /// - Parameter result: core data result for NSManagedObject Class
    func assignModel(result: [NSManagedObject]?)->[EventModel]? {
        if let _result = result {
            let res = _result as! [EventObject]
            let resu = res.compactMap { (results) -> EventModel? in
                let name = results.name ?? ""
                let category = results.category ?? ""
                let uuid = results.uuid ?? ""
                let location = results.location ?? ""
                let date = results.date ?? ""
                let time = results.time ?? ""
                let status = results.status ?? "CREATED"
                let isServer = results.isServerUpdated
                
                return EventModel(uuid: uuid, name: name, location: location, date:date , time: time, category: category, isServerUpdated: isServer, status: EventStatus(rawValue: status))
            }
            return resu
        }
        return nil
    }
    
    func convertData<T: Codable>(object: T) -> Data? {
        let encoder = JSONEncoder()
        if let jsonData = try? encoder.encode(object) {
            return jsonData
        }
        return nil
    }
    

    
}
