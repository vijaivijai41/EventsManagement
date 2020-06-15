//
//  UIDevice+Extension.swift
//  OfflineEvent
//
//  Created by Vijay on 12/06/20.
//  Copyright © 2020 Vijay. All rights reserved.
//

import Foundation
import UIKit

public extension UIDevice {
    
    /// Check the size class value wise is IPAD
    ///
    /// - Returns: is Ipad or not
    class func isIPAD() -> Bool {
        if UIScreen.main.traitCollection.horizontalSizeClass == UIUserInterfaceSizeClass.regular &&  UIScreen.main.traitCollection.verticalSizeClass == UIUserInterfaceSizeClass.regular {
            return true
        }
        return false
    }
}
