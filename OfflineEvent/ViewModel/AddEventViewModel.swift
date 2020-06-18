//
//  AddEventViewModel.swift
//  OfflineEvent
//
//  Created by Vijay on 15/06/20.
//  Copyright © 2020 Vijay. All rights reserved.
//

import Foundation


protocol AddEventViewDelegate: class {
    func addEventViewModel(viewModel: AddEventViewModel, didUpdateLocal status: Bool)
    func addEventViewModel(viewMoel: AddEventViewModel, didFailure error: String)

}


protocol AddEventCoordinateDelegate: class {
    func addEventViewModel(viewMode: AddEventViewModel, eventUpdateSuccessBack isBack: Bool)

}

class AddEventViewModel  {
    var editIndexPath: IndexPath? = nil
    weak var viewDelegate: AddEventViewDelegate?
    weak var coordinatorDelegate: AddEventCoordinateDelegate?
    let repository: Repository
    
    init(repository: Repository,viewDelegate: AddEventViewDelegate, coordinatorDelegate: AddEventCoordinateDelegate) {
        self.repository = repository
        self.viewDelegate = viewDelegate
        self.coordinatorDelegate = coordinatorDelegate
    }
    
    
    func addEvent(eventInfo: EventModel) {
        self.repository.addEvent(event: eventInfo) { (result) in
            switch result {
            case .success(let status):
                self.viewDelegate?.addEventViewModel(viewModel: self, didUpdateLocal: status)
            case .failure(let error):
                self.viewDelegate?.addEventViewModel(viewMoel: self, didFailure: error.errorString)
                
            }
        }
    }
    
    func deleteEvent(indexPath: IndexPath,eventInfo: EventModel) {
        self.repository.deleteEvent(event: eventInfo) { (result) in
            switch result {
            case .success(let status):
                self.repository.dataStore.eventList[indexPath.row] = eventInfo
                self.viewDelegate?.addEventViewModel(viewModel: self, didUpdateLocal: status)

            case .failure(let error):
                self.viewDelegate?.addEventViewModel(viewMoel: self, didFailure: error.errorString)
                
            }
        }
    }
    
    func updateEvent(indexPath: IndexPath,eventInfo: EventModel) {
        var event = eventInfo
        let excistEvent = self.repository.dataStore.eventList[indexPath.row]
        event.updateUUID(uuid: excistEvent.uuid)
        
        self.repository.updateEvent(event: event) { (result) in
            switch result {
            case .success(let status):
                self.repository.dataStore.eventList[indexPath.row] = event
                self.viewDelegate?.addEventViewModel(viewModel: self, didUpdateLocal: status)
                self.coordinatorDelegate?.addEventViewModel(viewMode: self, eventUpdateSuccessBack: true)
            case .failure(let error):
                self.viewDelegate?.addEventViewModel(viewMoel: self, didFailure: error.errorString)
                
            }
        }
    }
}
