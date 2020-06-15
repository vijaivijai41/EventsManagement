//
//  UIViewController+Extension.swift
//  OfflineEvent
//
//  Created by Vijay on 15/06/20.
//  Copyright © 2020 Vijay. All rights reserved.
//

import Foundation
import UIKit

extension UIViewController {
    
    func showAlert(message: String, okButtonAction:((UIAlertAction)->())?) {
        let alert = UIAlertController(title: "Information", message: message, preferredStyle: .alert)
        let okButtonAction = UIAlertAction(title: "Ok", style: .default, handler: okButtonAction)
        
        alert.addAction(okButtonAction)
        self.present(alert, animated: true, completion: nil)
    }
    
    
    private var activityIndicatorTag: Int { return 999999 }
    func showLoader() {
        
        let activitySize: CGSize = CGSize(width: 80.0, height: 80.0)
        
        DispatchQueue.main.async {
            guard !self.isLoaderVisible() else {
                return
            }
            let transparentOverlayView = UIView(frame: self.view.bounds)
            transparentOverlayView.tag = self.activityIndicatorTag
            
            let activityIndicator = UIActivityIndicatorView()
            activityIndicator.backgroundColor = UIColor.lightGray.withAlphaComponent(0.3)
            self.view.addSubview(transparentOverlayView)
            transparentOverlayView.addSubview(activityIndicator)
            self.view.bringSubviewToFront(transparentOverlayView)
            
            activityIndicator.translatesAutoresizingMaskIntoConstraints = false
            activityIndicator.centerXAnchor.constraint(equalTo: self.view.centerXAnchor, constant:0).isActive = true
            activityIndicator.centerYAnchor.constraint(equalTo: self.view.centerYAnchor, constant:0).isActive = true
            activityIndicator.widthAnchor.constraint(equalToConstant: activitySize.width).isActive = true
            activityIndicator.heightAnchor.constraint(equalToConstant: activitySize.height).isActive = true
            
            activityIndicator.style = UIActivityIndicatorView.Style.medium
            activityIndicator.layer.cornerRadius = 4.0
            activityIndicator.startAnimating()
            transparentOverlayView.layer.zPosition = 1
        }
    }
    
    func hideLoader() {
        DispatchQueue.main.async {
            guard self.isLoaderVisible() else {
                return
            }
            if let activityIndicator = self.view.subviews.filter(
                { $0.tag == self.activityIndicatorTag}).first {
                activityIndicator.removeFromSuperview()
            }
        }
    }
    
    func isLoaderVisible() -> Bool {
        return self.view.subviews.filter({ $0.tag == self.activityIndicatorTag}).count > 0
    }
    
}

