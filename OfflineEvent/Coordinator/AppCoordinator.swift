//
//  AppCoordinator.swift
//  PaytapConfigure
//
//  Created by Vijay on 06/06/20.
//  Copyright © 2020 Vijay. All rights reserved.
//

import Foundation
import UIKit

@objcMembers class AppCoordinator: Coordinator {
    
    let navigationController: UINavigationController
    var childCoordinator: [Coordinator] = []
    let repository: Repository
    
    init(navigationController: UINavigationController, repository: Repository) {
        self.repository = repository
        self.navigationController = navigationController
    }
   
    func start() {
        let storyboard = UIStoryboard.init(name: "Main", bundle: .main)
        let eventListController = storyboard.instantiateViewController(identifier: "EventListController") as! EventListController
        let viewModel = EventListViewModel(viewDelegate: eventListController, coordinatorDelaget: self, repository: self.repository)
        eventListController.viewModel = viewModel
        self.navigationController.viewControllers = [eventListController]

    }
    
    // add coordinator append
    func addCoordinator(coordinator: Coordinator) {
        if !childCoordinator.contains(where: { $0 === coordinator}) {
            childCoordinator.append(coordinator)
        }
    }
    
    // remove coordinator releade coordinator
    func removeCoordinator(coordinator: Coordinator) {
        childCoordinator = childCoordinator.filter { $0 !== coordinator }
    }
    
    deinit {
        print("deinitialize App coodinator")
    }
}



extension AppCoordinator: EventListCoordinatorDelegate {
   
    func eventViewModel(viewModel: EventListViewModel, editEventWith indexPath: IndexPath?) {
        self.showEventCreateScreen( isEdit: true, indexPath: indexPath)
    }
    
    func eventViewModelDidProceedCreateNewEvent(viewModel: EventListViewModel) {
        self.showEventCreateScreen( isEdit: false, indexPath: nil)
    }
    
    func showEventCreateScreen(isEdit: Bool, indexPath: IndexPath?) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "NewEventController") as! NewEventController
        let viewModel = AddEventViewModel(repository: repository, viewDelegate: vc, coordinatorDelegate: self)
        viewModel.editIndexPath = indexPath
        vc.viewModel = viewModel
        self.navigationController.pushViewController(vc, animated: true)
    }
    
    func eventViewModel(viewMode: EventListViewModel, eventUpdateSuccessBack isBack: Bool) {
        self.navigationController.popToRootViewController(animated: true)
    }
}


extension AppCoordinator: AddEventCoordinateDelegate {
    func addEventViewModel(viewMode: AddEventViewModel, eventUpdateSuccessBack isBack: Bool) {
        self.navigationController.popToRootViewController(animated: true)
    }
}
