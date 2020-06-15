//
//  Coordinator.swift
//  PaytapConfigure
//
//  Created by Vijay on 06/06/20.
//  Copyright © 2020 Vijay. All rights reserved.
//

import Foundation
import UIKit

public protocol Coordinator: class {
    
    var childCoordinator: [Coordinator]  { get set }
    func start()
}
