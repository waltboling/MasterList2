//
//  AdManager.swift
//  MasterList
//
//  Created by Jon Boling on 8/29/18.
//  Copyright © 2018 Walt Boling. All rights reserved.
//

import Foundation
import UIKit
import GoogleMobileAds



class AdManager {
    
    var bannerView: GADBannerView!
    static let shared = AdManager()
    
    private init(){
        
    }
    
    func configureAds(viewController: UIViewController) {
        bannerView = GADBannerView(adSize: kGADAdSizeBanner)
        //viewController.addBannerViewToView(bannerView) cant get this to work
        bannerView.adUnitID = "ca-app-pub-3940256099942544/6300978111"
        bannerView.rootViewController = viewController
        let request = GADRequest()
        request.testDevices = [kGADSimulatorID]
        bannerView.load(request)
        bannerView.delegate = viewController as? GADBannerViewDelegate
        
        
    }
    
}
