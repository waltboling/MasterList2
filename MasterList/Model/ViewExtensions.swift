//
//  Extensions.swift
//  MasterList
//
//  Created by Jon Boling on 8/29/18.
//  Copyright © 2018 Walt Boling. All rights reserved.
//

import Foundation
import UIKit
import ChameleonFramework

extension UIView {
    func shake() {
        let animation = CAKeyframeAnimation(keyPath: "transform.translation.x")
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
        animation.duration = 0.6
        animation.values = [-20.0, 20.0, -20.0, 20.0, -10.0, 10.0, -5.0, 5.0, 0.0 ]
        layer.add(animation, forKey: "shake")
    }
    
    func fadeInElements(duration: TimeInterval = 1.0) {
        UIView.animate(withDuration: duration) {
            self.alpha = 1.0
        }
    }
}

extension UIViewController {
    func showAlert(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
        let settingsAction = UIAlertAction(title: "Settings", style: .default) {(action) in self.openSettings()}
        
        alertController.addAction(okAction)
        alertController.addAction(settingsAction)
        
        DispatchQueue.main.async {
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    @objc func openSettings() {
        guard let settingsURL = URL(string: UIApplicationOpenSettingsURLString) else {
            print("failed")
            return
        }
        if UIApplication.shared.canOpenURL(settingsURL) {
            UIApplication.shared.open(settingsURL, completionHandler:{(success) in
                print ("SettingsOpened: \(success)")
            })
        }
    }
}
