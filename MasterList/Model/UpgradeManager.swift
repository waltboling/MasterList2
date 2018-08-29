//
//  UpgradeManager.swift
//  MasterList2
//
//  Created by Jon Boling on 8/23/18.
//  Copyright © 2018 Walt Boling. All rights reserved.
//

import Foundation
import StoreKit

class UpgradeManager: NSObject, SKProductsRequestDelegate, SKPaymentTransactionObserver {
    static let sharedInstance = UpgradeManager()
    let productIdentifier = "waltboling.MasterList.addlist"
    typealias SuccessHandler = (_ succeeded: Bool) -> (Void)
    var upgradeCompletionHandler: SuccessHandler?
    var restoreCompletionHandler: SuccessHandler?
    var priceCompletionHandler: ((_ price: Float) -> Void)?
    var addListProduct: SKProduct?
    
    let userDefaultsKey = "HasUpgradedUserDefaultsKey"
    
    func hasUpgraded() -> Bool {
        return UserDefaults.standard.bool(forKey: userDefaultsKey)
    }
    
    func upgrade(_ success: @escaping SuccessHandler) {
        upgradeCompletionHandler = success
        SKPaymentQueue.default().add(self)
        
        if let product = addListProduct {
            let payment = SKPayment(product: product)
            SKPaymentQueue.default().add(payment)
        }
    }
    
    func restorePurchases(_ success: @escaping SuccessHandler) {
        restoreCompletionHandler = success
        SKPaymentQueue.default().add(self)
        
        SKPaymentQueue.default().restoreCompletedTransactions()
    }
    
    func priceForUpgrade(_ success: @escaping (_ price: Float) -> Void) {
        //success(0.0)
        priceCompletionHandler = success
        
        let identifiers: Set<String> = [productIdentifier]
        let request = SKProductsRequest(productIdentifiers: identifiers)
        request.delegate = self
        request.start()
    }
    
    // MARK: SKPaymentTransactionObserver
    
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions {
            switch transaction.transactionState {
            case .purchased:
                UserDefaults.standard.set(true, forKey: userDefaultsKey)
                upgradeCompletionHandler?(true)
            case .restored:
                UserDefaults.standard.set(true, forKey: userDefaultsKey)
                restoreCompletionHandler?(true)
            case .failed:
                upgradeCompletionHandler?(false)
            default:
                return
            }
            
            SKPaymentQueue.default().finishTransaction(transaction)
        }
    }
    
    // MARK: SKProductsRequestDelegate
    
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        print(response)
        print(response.products)
        print(response.products.count)
        if let masterListProduct = response.products.first {
            addListProduct = masterListProduct
            priceCompletionHandler?(Float(truncating: masterListProduct.price))
        }
        else {
            print("error retrieving pricing")
        }
    }
}
