//
//  OEPickerView
//  OfflineEvent
//
//  Created by Vijay on 11/06/20.
//  Copyright © 2020 Vijay. All rights reserved.
//
//

import UIKit

//Closure Properties for action and selection Handler
public typealias ButtonActionHandler = () -> ()
public typealias DoneActionHandler = (_ isDate:Bool, _ selectedObj: Any? , _ selectedindex: [Int]?) -> ()


class OEPickerView: UIView,UIPopoverPresentationControllerDelegate {
    
    @IBOutlet public weak var elementPicker: UIPickerView!
    @IBOutlet public weak var dateTimePicker: UIDatePicker!
    @IBOutlet weak var pickerBaseView: UIView!
    @IBOutlet weak var cancelButton: UIBarButtonItem!
    @IBOutlet weak var doneButton: UIBarButtonItem!
    @IBOutlet weak var titleLable: UILabel!
    @IBOutlet weak var toolBar: UIToolbar!
    
    private var doneHandler: DoneActionHandler?
    private var cancelHandler: ButtonActionHandler?
    private var currentIndex: Int = 0
    private var selectDate:Date = Date()
    private var selectedIndex: Int = 0
    private var sourceController: UIViewController?
    private var sourceView: UIView = UIView()
    private var datasource: ActionSheetsDataSource?
    // ListItems Updated
    private var listElement = [Any]() {
        didSet {
            if listElement.count > 0 {
                DispatchQueue.main.async {
                    self.elementPicker.reloadAllComponents()
                }
            }
        }
    }
    
    private var firstElement: [Any] = []
    private var secondElment = [Any]() {
        didSet {
            if secondElment.count > 0 {
                DispatchQueue.main.async {
                    self.elementPicker.reloadAllComponents()
                }
            }
        }
    }
    
    /// Load View
    override open func awakeFromNib() {
        super.awakeFromNib()
        self.toolBar.isHidden = UIDevice.isIPAD()
    }
    
    /// Unchanged button not show in done button
    public func doneButtonShowHide() {
        if self.datasource?.selectionType == .content {
            let row = self.elementPicker.selectedRow(inComponent: 0)
            if row == selectedIndex {
                self.doneButton.isEnabled = false
                self.doneButton.tintColor = UIColor.clear
            } else {
                self.doneButton.isEnabled = true
                self.doneButton.tintColor = UIView().tintColor
            }
        }
    }
    
    /// Load view from xib
    ///
    /// - Returns: return OEPickerView
    class func loadFromNib() -> OEPickerView? {
        let bundle = Bundle.init(for: OEPickerView.self)
        let view = bundle.loadNibNamed("OEPickerView", owner: self, options: nil)?.first as? OEPickerView
        view?.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        return view
    }
    
    /// CancelAction
    ///
    /// - Parameter sender: cancel UIButton
    @IBAction func cancelAction(_ sender: Any) {
        cancelHandler?()
        OEPickerView.actionSheetBackgroundTapped()
    }
    
    /// Done Button Action
    ///
    /// - Parameter sender: UIButton passing params
    @IBAction func doneAction(_ sender: Any) {
        
        if self.datasource?.selectionType == .content {
            let row = self.elementPicker.selectedRow(inComponent: 0)
            if self.listElement.count > 0 {
                let obj = self.listElement[row]
                doneHandler?(false,obj,[row])
            }
        } else {
            doneHandler?(true,selectDate,nil)
        }
        OEPickerView.actionSheetBackgroundTapped()
        
    }
    
    /// Date Picker value change observer
    ///
    /// - Parameter sender: date picker
    @objc func datePickerValueChanged(_ sender: UIDatePicker){
        // Create date formatter
        let dateFormatter: DateFormatter = DateFormatter()
        
        // Set date format
        dateFormatter.dateFormat = "MM/dd/yyyy hh:mm a"
        
        // Apply date format
        let selectedDate: String = dateFormatter.string(from: sender.date)
        selectDate = sender.date
        print("Selected value \(selectedDate)")
    }
    
    
    
    /// Load dataSource Elements
    ///
    /// - Parameter dataSource: Datasource
    public func loadDataSource(dataSource: ActionSheetsDataSource?) {
        if let source = self.datasource {
            if source.selectionType == .content {
                if let list = source.list {
                    self.listElement = list
                }
                self.elementPicker.isHidden = false
                self.dateTimePicker.isHidden = true
                self.elementPicker.delegate = self
                self.elementPicker.dataSource = self
                self.elementPicker.selectRow(selectedIndex, inComponent: 0, animated: true)
                //doneButtonShowHide()
            } else {
                self.dateTimePicker.addTarget(self, action: #selector(datePickerValueChanged(_:)), for: .valueChanged)
                self.dateTimePicker.datePickerMode = self.returnModePicker(type: source.selectionType)
                self.elementPicker.isHidden = true
                self.dateTimePicker.isHidden = false
            }
            self.cancelButton.title = source.leftButton
            self.doneButton.title = source.rightButton
            self.titleLable.text = source.title
            self.datasource = source
        }
    }
    
    /// Return picker type idendification
    ///
    /// - Parameter type: type of source
    /// - Returns: mode of picker view
    private func returnModePicker(type: pickerMode) -> UIDatePicker.Mode{
        var pickerMode = UIDatePicker.Mode(rawValue: 0)!
        if type == .date {
            pickerMode = .date
        } else {
            pickerMode = .time
        }
        return pickerMode
    }
    
    
    /// Show picker value for any controller
    ///
    /// - Parameters:
    ///   - dataSource: ActionAheet Datasource
    ///   - selectedIndex: Preselected Index
    ///   - orgin: Orgin View
    ///   - doneHandler: Done button action Handler and closure return seleced values
    ///   - cancelHandler: Cancel Button Handler
    /// - Returns: Return Custom picker view
    class func showPicker(dataSource: ActionSheetsDataSource,selectedIndex:Int ,orgin:UIView?,doneHandler:DoneActionHandler?,cancelHandler:ButtonActionHandler?) ->  OEPickerView? {
        
        let alertController = UIAlertController(title: "", message: nil, preferredStyle: .actionSheet)
        let pickerView = OEPickerView.loadFromNib()
        alertController.view.addSubview(pickerView!)
        
        pickerView?.addConstrins(alertController)
        pickerView?.datasource = dataSource
        pickerView?.doneHandler = doneHandler
        pickerView?.sourceView = orgin ?? UIView()
        pickerView?.selectedIndex = selectedIndex
        pickerView?.sourceController = UIApplication.getTopViewController()
        pickerView?.cancelHandler = cancelHandler
        pickerView?.loadDataSource(dataSource: dataSource)
        
        if let popoverController = alertController.popoverPresentationController {
            popoverController.sourceView = pickerView?.sourceView
            popoverController.sourceRect = pickerView?.sourceView.bounds ?? CGRect.zero
            popoverController.permittedArrowDirections = UIPopoverArrowDirection.up
            popoverController.delegate = pickerView
            
        }
        
        UIApplication.getTopViewController()?.present(alertController, animated: true) {
            // Enabling Interaction for Transperent Full Screen Overlay
            alertController.view.superview?.subviews.first?.isUserInteractionEnabled = true
            // Adding Tap Gesture to Overlay
            alertController.view.superview?.subviews.first?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(OEPickerView.actionSheetBackgroundTapped)))
            
        }
        return pickerView
    }
    
    /// PickerView ActionSheet add subview constrains
    ///
    /// - Parameter controller: AlertController
    private func addConstrins(_ controller: UIAlertController) {
        self.translatesAutoresizingMaskIntoConstraints = false
        self.layer.cornerRadius = 5
        self.layer.masksToBounds = true
        self.topAnchor.constraint(equalTo: controller.view.topAnchor).isActive = true
        self.bottomAnchor.constraint(equalTo: controller.view.bottomAnchor).isActive = true
        self.leftAnchor.constraint(equalTo: controller.view.leftAnchor).isActive = true
        self.rightAnchor.constraint(equalTo: controller.view.rightAnchor).isActive = true
        controller.view.translatesAutoresizingMaskIntoConstraints = false
    }
    
    /// Outter Tap close ActionSheet
    @objc class func actionSheetBackgroundTapped() {
        UIApplication.getTopViewController()?.dismiss(animated: true, completion: nil)
    }
    
    public func popoverPresentationControllerDidDismissPopover(_ popoverPresentationController: UIPopoverPresentationController) {
        if UIDevice.isIPAD() {
            if self.selectedIndex == 0 {
                self.ipadSelection()
            }
        }
    }
    
    
}


//MARK: Extension Picker view Elements
extension OEPickerView :UIPickerViewDelegate,UIPickerViewDataSource {
    
    open func numberOfComponents(in pickerView: UIPickerView) -> Int {
        if self.datasource?.selectionType == .content {
            return 1
        } else {
            return 2
        }
    }
    
    open func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if self.datasource?.selectionType == .content {
            return listElement.count
        } else {
            if component == 0 {
                return firstElement.count
            } else {
                return (secondElment[currentIndex] as AnyObject).count
            }
        }
        
    }
    
    open func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if self.datasource?.selectionType == .content {
            return listElement[row] as? String
        } else {
            if component == 0 {
                return firstElement[row] as? String
            } else {
                return (secondElment[currentIndex] as! [String])[row]
                
            }
        }
    }
    
    open func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        // Check is IPAD
        if UIDevice.isIPAD() {
            ipadSelection()
        }
    }
    
    func ipadSelection() {
        if self.datasource?.selectionType == .content {
            let row = self.elementPicker.selectedRow(inComponent: 0)
            let obj = self.listElement[row]
            doneHandler?(false,obj,[row])
        }  else {
            doneHandler?(true,selectDate,nil)
        }
    }
    
}
