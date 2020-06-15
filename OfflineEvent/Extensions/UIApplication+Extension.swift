//
//  UIApplication+Extension.swift
//  OfflineEvent
//
//  Created by Vijay on 12/06/20.
//  Copyright © 2020 Vijay. All rights reserved.
//

import Foundation
import UIKit

extension UIApplication {
    
    /// Fetch Top Controller from stack
    ///
    /// - Parameter base: Base controller
    /// - Returns: return Top Controller
    class func getTopViewController(base: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> UIViewController? {
        
        if let nav = base as? UINavigationController {
            return getTopViewController(base: nav.visibleViewController)
            
        } else if let tab = base as? UITabBarController, let selected = tab.selectedViewController {
            return getTopViewController(base: selected)
            
        } else if let presented = base?.presentedViewController {
            return getTopViewController(base: presented)
        }
        return base
    }
}
