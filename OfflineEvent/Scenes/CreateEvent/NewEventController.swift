//
//  NewEventController.swift
//  OfflineEvent
//
//  Created by Vijay on 15/06/20.
//  Copyright © 2020 Vijay. All rights reserved.
//

import UIKit

class NewEventController: UITableViewController {

    @IBOutlet weak var eventNameTxt: UITextField!
    @IBOutlet weak var categoryText: UITextField!
    @IBOutlet weak var locationText: UITextField!
    @IBOutlet weak var dateText: UITextField!
    @IBOutlet weak var timeTxt: UITextField!
    
    var viewModel: AddEventViewModel!
    let category: [String] = ["Music", "Sports", "Movie", "Drama", "Dance", "Other"]
   
    override func viewDidLoad() {
        super.viewDidLoad()

        if let indexpath = viewModel.editIndexPath {
            self.updateEventDate(event: self.viewModel.repository.dataStore.eventList[indexpath.row])
        }
    }
    
    func updateEventDate(event: EventModel) {
        self.eventNameTxt.text = event.name
        self.locationText.text = event.location
        self.categoryText.text = event.category
        self.timeTxt.text = event.time
        self.dateText.text = event.date
    }
  
    @IBAction func categoryDidBegin(_ sender: Any) {
        categoryText.resignFirstResponder()
        let dataSource = OEPickerViewDataSource.singleElement(array: category, title: "Category")
        _ = OEPickerView.showPicker(dataSource: dataSource, selectedIndex: 0, orgin: categoryText, doneHandler: { (isDate, obj, indexes) in
            if let _indexes = indexes {
                let index = _indexes[0]
                let value = self.category[index]
                self.categoryText.text = value
            }
        }, cancelHandler: nil)
    }
    
    @IBAction func dateDidBegin(_ sender: Any) {
        dateText.resignFirstResponder()
        let dataSource = OEPickerViewDataSource.date(title: "Date")
        _ = OEPickerView.showPicker(dataSource: dataSource, selectedIndex: 0, orgin: categoryText, doneHandler: { (isDate, obj, nil) in
            if let date = obj as? Date {
                self.dateText.text = date.displayFormatedDate
            }
        }, cancelHandler: nil)
        
    }
    @IBAction func timeDidBegin(_ sender: Any) {
        timeTxt.resignFirstResponder()
        let dataSource = OEPickerViewDataSource.time(title: "Time")
        _ = OEPickerView.showPicker(dataSource: dataSource, selectedIndex: 0, orgin: categoryText, doneHandler: { (isDate, obj, nil) in
            if let date = obj as? Date {
                self.timeTxt.text = date.displayFormatedTime
            }
        }, cancelHandler: nil)
        
    }
    
    @IBAction func saveButtonDidTap(_ sender: Any) {
        guard let eventname  = eventNameTxt.text , !eventname.isEmpty else {
            self.showAlert(message: "Please enter event name", okButtonAction: nil)
            return
        }
        
        guard let category  = categoryText.text, !category.isEmpty else {
            self.showAlert(message: "Please choose your category", okButtonAction: nil)
            return
        }
        
        guard let location  = locationText.text, !location.isEmpty else {
            self.showAlert(message: "Please enter your location", okButtonAction: nil)
            return
        }
        guard let date  = dateText.text , !date.isEmpty else {
            self.showAlert(message: "Please select your date", okButtonAction: nil)
           
            return
        }
        guard let time  = timeTxt.text, !time.isEmpty else {
            self.showAlert(message: "Please select your time", okButtonAction: nil)
            return
        }
        
        let uuid = eventname+date+time
        let eventInfo = EventModel(uuid:uuid , name: eventname, location: location, date: date, time: time, category: category, isServerUpdated: false, status: .created)
       
        self.showLoader()
      
        if let indexPath = viewModel.editIndexPath {
            self.viewModel.updateEvent(indexPath: indexPath, eventInfo: eventInfo)
        } else {
            self.viewModel.addEvent(eventInfo: eventInfo)
        }
        
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 5
    }

}


extension NewEventController: AddEventViewDelegate {
    
    func addEventViewModel(viewModel: AddEventViewModel, didUpdateLocal status: Bool) {
        self.hideLoader()
        self.viewModel.coordinatorDelegate?.addEventViewModel(viewMode: self.viewModel, eventUpdateSuccessBack: true)
    }
    
    func addEventViewModel(viewMoel: AddEventViewModel, didFailure error: String) {
        self.hideLoader()
        self.showAlert(message: error, okButtonAction: nil)

    }
    
}


extension NewEventController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
