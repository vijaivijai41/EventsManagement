//
//  EventListController.swift
//  OfflineEvent
//
//  Created by Vijay on 11/06/20.
//  Copyright © 2020 Vijay. All rights reserved.
//

import UIKit


class EventListCell: UITableViewCell {
    
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
   
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    func displayData(eventObj: EventModel) {
        self.nameLabel.text = eventObj.name
        self.categoryLabel.text = eventObj.category
        self.dateLabel.text = eventObj.date + " " + eventObj.time
        self.locationLabel.text = eventObj.location
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}


class EventListController: UIViewController {

    var viewModel: EventListViewModel!
    @IBOutlet weak var eventTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Events"
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.showLoader()
        self.viewModel.fetchEventlist()
    }
    
    @IBAction func addNewEventButtonDidTap(_ sender: Any) {
        self.viewModel.createNewEvent(indexPath: nil)
    }
}


extension EventListController: UITableViewDelegate,UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.viewModel.eventList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "EventListCell", for: indexPath) as! EventListCell
        cell.displayData(eventObj: self.viewModel.eventList[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .normal, title: "Delete") { (action, view, completion) in
            // Perform your action here
            self.showLoader()
            self.viewModel.deleteEvent(indexPath: indexPath, eventInfo: self.viewModel.eventList[indexPath.row])
            completion(true)
        }
        
        let editAction = UIContextualAction(style: .normal, title: "Edit") { (action, view, completion) in
            // Perform your action here
            self.showLoader()
            self.viewModel.updateEvent(indexPath: indexPath, eventInfo: self.viewModel.eventList[indexPath.row])
            completion(true)
        }
        editAction.backgroundColor = .blue
        deleteAction.backgroundColor = .red
        return UISwipeActionsConfiguration(actions: [deleteAction, editAction])
    }
    
}


extension EventListController: EventListViewModelViewDelegte {
    func eventVieModel(viewMoel: EventListViewModel, didFailure error: String) {
        self.hideLoader()
        self.showAlert(message: error, okButtonAction: nil)
    }
    
    func eventVieModel(viewModel: EventListViewModel, didUpdateLocal status: Bool) {
        self.hideLoader()
        self.eventTableView.reloadData()
    }
    
    func eventViewModel(viewModel: EventListViewModel, didFetchEventList eventInfo: [EventModel]) {
        self.hideLoader()
        self.eventTableView.reloadData()

    }
   
}
