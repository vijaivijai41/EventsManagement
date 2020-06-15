//
//  Date+Extension.swift
//  ExpenceDiary
//
//  Created by Vijay on 16/05/20.
//  Copyright © 2020 Vijay. All rights reserved.
//

import Foundation

let currentdate = Date()

extension Date {
    
    var displayFormatedDate: String {
        let dateformat = DateFormatter()
        dateformat.dateFormat = "dd-MM-yyyy"
        return dateformat.string(from: self)
    }
    
    var displayFormatedTime: String {
        let dateformat = DateFormatter()
        dateformat.dateFormat = "HH:mm"
        return dateformat.string(from: self)
    }
}

