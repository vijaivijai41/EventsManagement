//
//  Connectivuty.swift
//  OfflineEvent
//
//  Created by Vijay on 12/06/20.
//  Copyright © 2020 Vijay. All rights reserved.
//

import Foundation

class Connectivity {
    
    var connectionStatusUpdate: ((_ isConnectedStaus: Bool)->())? = nil
    let reachability: Reachability
    var netorkStatus: Bool = false
    
    static let instance = Connectivity()

    private init() {
        do {
            self.reachability = try! Reachability(hostname: "google.com")
            try reachability.startNotifier()
        } catch {
            reachability.stopNotifier()
        }
    }
    
    func connectionStatus() -> Bool {
        reachability.whenReachable = { reachability in
            self.connectionStatusUpdate?(true)
        }
        reachability.whenUnreachable = { reachability in
            self.connectionStatusUpdate?(false)
        }

        switch reachability.connection {
        case .cellular,.wifi:
            self.connectionStatusUpdate?(true)
        case .unavailable,.none:
            self.connectionStatusUpdate?(false)
        }
        
        return reachability.isConnectedToNetwork()
    }
    
    
}
