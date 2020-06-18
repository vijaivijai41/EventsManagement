//
//  DataStore.swift
//  PaytapConfigure
//
//  Created by Vijay on 10/06/20.
//  Copyright © 2020 Vijay. All rights reserved.
//

import Foundation

class DataStore {
    static let shared: DataStore = DataStore()
    var connectivity: Connectivity?

    private init() {
        connectivity = Connectivity.instance
    }

    deinit {
        print("DataStore deinit")
    }
    
    var eventList: [EventModel] = []
    
}

