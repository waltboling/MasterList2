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
