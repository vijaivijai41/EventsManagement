//
//  EventListViewModel.swift
//  OfflineEvent
//
//  Created by Vijay on 11/06/20.
//  Copyright © 2020 Vijay. All rights reserved.
//

import Foundation

protocol EventListViewModelViewDelegte : class {
    func eventViewModel(viewModel: EventListViewModel, didFetchEventList eventInfo: [EventModel])
    func eventVieModel(viewMoel: EventListViewModel, didFailure error: String)
    func eventVieModel(viewModel: EventListViewModel, didUpdateLocal status: Bool)

}

protocol EventListCoordinatorDelegate: class {
    func eventViewModelDidProceedCreateNewEvent(viewModel: EventListViewModel)
    func eventViewModel(viewModel: EventListViewModel, editEventWith indexPath: IndexPath?)
    
}

class EventListViewModel {
    
    weak var viewDelegate: EventListViewModelViewDelegte?
    weak var coordinatorDelaget: EventListCoordinatorDelegate?
    let repository: Repository
    
    var eventList: [EventModel]  {
        return self.repository.dataStore.eventList
    }
    
    init(viewDelegate: EventListViewModelViewDelegte, coordinatorDelaget: EventListCoordinatorDelegate, repository: Repository) {
        self.coordinatorDelaget = coordinatorDelaget
        self.viewDelegate = viewDelegate
        self.repository = repository
    }
    
    
    func fetchEventlist() {
        self.repository.fetchAllEvent { (result) in
            switch result {
            case .success(let model):
                self.viewDelegate?.eventViewModel(viewModel: self, didFetchEventList: model)
            case .failure(let error):
                self.viewDelegate?.eventVieModel(viewMoel: self, didFailure: error.errorString)
            }
        }
    }
        
    
    func createNewEvent(indexPath: IndexPath?) {
        if let _indexPath = indexPath {
            self.coordinatorDelaget?.eventViewModel(viewModel: self, editEventWith: _indexPath)

        } else {
            self.coordinatorDelaget?.eventViewModelDidProceedCreateNewEvent(viewModel: self)
        }
    }
    
    
    
    func addEvent(eventInfo: EventModel) {
        self.coordinatorDelaget?.eventViewModel(viewModel: self, editEventWith: nil)
    }
    
    func deleteEvent(indexPath: IndexPath,eventInfo: EventModel) {
        self.repository.deleteEvent(event: eventInfo) { (result) in
            switch result {
            case .success(let status):
                self.viewDelegate?.eventVieModel(viewModel: self, didUpdateLocal: status)
            case .failure(let error):
                self.viewDelegate?.eventVieModel(viewMoel: self, didFailure: error.errorString)
                
            }
        }
    }
    
    func updateEvent(indexPath: IndexPath,eventInfo: EventModel) {
        self.coordinatorDelaget?.eventViewModel(viewModel: self, editEventWith: indexPath)

    }
}
