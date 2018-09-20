//
//  IAPService.swift
//  Tully Dev
//
//  Created by Kathan on 05/08/18.
//  Copyright © 2018 Tully. All rights reserved.
//

import Foundation
import StoreKit

class IAPService: NSObject{
    
    private override init() {}
    
    private let itcAccountSecret = "bab4e3da6b8247fd9f2cfb446ffa2c49"
    
    static let shared = IAPService()
    var products = [SKProduct]()
    let paymentQueue = SKPaymentQueue.default()
    
    func getProducts(){
        let products : Set = [IAPProduct.autoRenewingSubscription.rawValue,
                              IAPProduct.basicEngineerSubscription.rawValue,
                              IAPProduct.UnlimitedEngineerSubscription.rawValue,
                              IAPProduct.inviteCollaboratorSubscription.rawValue]
        
        let request = SKProductsRequest(productIdentifiers: products)
        request.delegate = self
        request.start()
        paymentQueue.add(self)
        
    }
    
    
    func purchase(product: IAPProduct){
        guard let productToPurchase = products.filter({ $0.productIdentifier == product.rawValue }).first else { return }
        let payment = SKPayment(product: productToPurchase)
        paymentQueue.add(payment)
    }
    
    func restoreProduct(){
        print("restoring product")
        paymentQueue.restoreCompletedTransactions()
    }
    
    
    func handlePurchasingState(for transaction: SKPaymentTransaction, in queue: SKPaymentQueue) {
        print("User is attempting to purchase product id: \(transaction.payment.productIdentifier)")
    }
    
    func handlePurchasedState(for transaction: SKPaymentTransaction, in queue: SKPaymentQueue) {
        print("User purchased product id: \(transaction.payment.productIdentifier)")
        NotificationCenter.default.post(name: Notification.Name(rawValue: "purchaseComplete"), object: nil)
        
        queue.finishTransaction(transaction)
//        SubscriptionService.shared.uploadReceipt { (success) in
//            DispatchQueue.main.async {
//                NotificationCenter.default.post(name: SubscriptionService.purchaseSuccessfulNotification, object: nil)
//            }
//        }
        
    }
    
    func handleRestoredState(for transaction: SKPaymentTransaction, in queue: SKPaymentQueue) {
        print("Purchase restored for product id: \(transaction.payment.productIdentifier)")
    }
    
    func handleFailedState(for transaction: SKPaymentTransaction, in queue: SKPaymentQueue) {
        NotificationCenter.default.post(name: Notification.Name(rawValue: "purchaseFailed"), object: nil)
        print("Purchase failed for product id: \(transaction.payment.productIdentifier)")
    }
    
    func handleDeferredState(for transaction: SKPaymentTransaction, in queue: SKPaymentQueue) {
        print("Purchase deferred for product id: \(transaction.payment.productIdentifier)")
    }

    
}

extension IAPService : SKProductsRequestDelegate{
    
    
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        
        self.products = response.products
        print(response.products)
        
        for product in response.products{
            print("payment complete")
            print(product.localizedDescription)
        }
    }
    
    func request(_ request: SKRequest, didFailWithError error: Error) {
        if request is SKProductsRequest {
            print("Subscription Options Failed Loading: \(error.localizedDescription)")
        }
    }
    
}


extension IAPService : SKPaymentTransactionObserver{
    
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        
        
        for transaction in transactions {
            switch transaction.transactionState {
            case .purchasing:
                handlePurchasingState(for: transaction, in: queue)
            case .purchased:
                handlePurchasedState(for: transaction, in: queue)
            case .restored:
                handleRestoredState(for: transaction, in: queue)
            case .failed:
                handleFailedState(for: transaction, in: queue)
            case .deferred:
                handleDeferredState(for: transaction, in: queue)
            }
        }

        
//        for transaction in transactions{
//            print(transaction.transactionState)
//            print(transaction.transactionState.status(), transaction.payment.productIdentifier)
//
//            switch transaction.transactionState{
//                case .purchasing: break
//                default: queue.finishTransaction(transaction)
//            }
//        }
        
        
    }
    
    
}


extension SKPaymentTransactionState{
    func status() -> String{
        switch self {
        case .deferred:
            return "deferred"
        case .failed:
            return "failed"
        case .purchased:
            return "purchased"
        case .purchasing:
            return "purchasing"
        case .restored:
            return "restored"
        }
    }
}






