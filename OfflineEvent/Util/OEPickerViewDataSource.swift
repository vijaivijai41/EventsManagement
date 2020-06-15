//
//  OEPickerViewDataSource
//  OfflineEvent
//
//  Created by Vijay on 11/06/20.
//  Copyright © 2020 Vijay. All rights reserved.
//
//

import Foundation

// protocal for action sheet datasource
public protocol ActionSheetsDataSource {
    var list: [Any]? { get }
    var list2: [Any]? { get }
    var title: String { get }
    var leftButton :String { get }
    var rightButton: String { get }
    var selectionType: pickerMode { get }
}

// Picker Type Enumerations
public enum pickerMode {
    case content
    case date
    case time
}


/// DataSource Declarations with base of Actionsheet datasource
///
/// - date: Date components
/// - singleElement: singlePicker
/// - multipleElements: multiplePickerElement
/// - time: Time components
/// - dateAndTime: Date and Time components
public enum OEPickerViewDataSource: ActionSheetsDataSource {
    
    case date(title: String)
    case singleElement(array:[Any]?,title:String)
    case time(title: String)
    
    public var leftButton: String {
        let cencelButton = NSLocalizedString("cancel", comment: "")
        switch self {
        case .date(_):
            return cencelButton
        case .singleElement(_,_):
            return cencelButton
        case .time(_):
            return cencelButton
       
        }
    }
    
    public var rightButton: String {
        let doneButton = NSLocalizedString("Done", comment: "")
        switch self {
        case .date(_):
            return doneButton
        case .singleElement(_,_):
            return doneButton
        case .time(_):
            return doneButton
        
        }
    }
    
    public var list: [Any]? {
        switch self {
        case .date(_):
            return nil
        case .singleElement(let arrayList,_):
            return arrayList
        case .time(_):
            return nil
        }
    }
    
    public var list2: [Any]? {
        switch self {
        case .date(_):
            return nil
        case .singleElement( _, _):
            return nil
        case .time(_):
            return nil
        }
    }
    
    
    public var title: String {
        switch self {
        case .date(let title):
            return title
        case .singleElement(_,let title):
            return title
        case .time(let title):
            return title
        }
    }
    
    public var selectionType: pickerMode {
        switch self {
        case .date(_):
            return .date
        case .time(_):
            return .time
        case .singleElement(_ ,_ ):
            return .content
        }
    }
}
