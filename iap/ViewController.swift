//
//  ViewController.swift
//  iap
//
//  Created by Andrew Seeley on 1/1/17.
//  Copyright © 2017 Seemu. All rights reserved.
//

import UIKit
import StoreKit

class ViewController: UIViewController, SKProductsRequestDelegate, SKPaymentTransactionObserver {

    
    @IBOutlet var lblAd: UILabel!
    @IBOutlet var lblCoinAmount: UILabel!
    
    @IBOutlet var outRemoveAds: UIButton!
    @IBOutlet var outAddCoins: UIButton!
    @IBOutlet var outRestorePurchases: UIButton!
    
    var coins = 50
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        outRemoveAds.isEnabled = false
        outAddCoins.isEnabled = false
        outRestorePurchases.isEnabled = false
        
        if(SKPaymentQueue.canMakePayments()) {
            print("IAP is enabled, loading")
            let productID: NSSet = NSSet(objects: "seemu.iap.addcoins", "seemu.iap.removeads")
            let request: SKProductsRequest = SKProductsRequest(productIdentifiers: productID as! Set<String>)
            request.delegate = self
            request.start()
        } else {
            print("please enable IAPS")
        }
    }

    @IBAction func btnRemoveAds(_ sender: Any) {
        print("rem ads")
        for product in list {
            let prodID = product.productIdentifier
            if(prodID == "seemu.iap.removeads") {
                p = product
                buyProduct()
            }
        }
    }
    
    @IBAction func btnAddCoins(_ sender: Any) {
        for product in list {
            let prodID = product.productIdentifier
            if(prodID == "seemu.iap.addcoins") {
                p = product
                buyProduct()
            }
        }
    }
    
    @IBAction func btnRestorePurchases(_ sender: Any) {
        SKPaymentQueue.default().add(self)
        SKPaymentQueue.default().restoreCompletedTransactions()
    }
    
    func buyProduct() {
        print("buy " + p.productIdentifier)
        let pay = SKPayment(product: p)
        SKPaymentQueue.default().add(self)
        SKPaymentQueue.default().add(pay as SKPayment)
    }
    
    func removeAds() {
        lblAd.removeFromSuperview()
    }
    
    func addCoins() {
        coins += 50
        lblCoinAmount.text = "\(coins)"
    }
    
    var list = [SKProduct]()
    var p = SKProduct()
    
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        print("product request")
        let myProduct = response.products
        for product in myProduct {
            print("product added")
            print(product.productIdentifier)
            print(product.localizedTitle)
            print(product.localizedDescription)
            print(product.price)
            
            list.append(product)
        }
        
        outRemoveAds.isEnabled = true
        outAddCoins.isEnabled = true
        outRestorePurchases.isEnabled = true
    }
    
    func paymentQueueRestoreCompletedTransactionsFinished(_ queue: SKPaymentQueue) {
        print("transactions restored")
        for transaction in queue.transactions {
            let t: SKPaymentTransaction = transaction
            let prodID = t.payment.productIdentifier as String
            
            switch prodID {
                case "seemu.iap.removeads":
                    print("remove ads")
                    removeAds()
                case "seemu.iap.addcoins":
                    print("add coins to account")
                    addCoins()
                default:
                    print("IAP not found")
            }
        }
    }
    
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        print("add payment")
        
        for transaction: AnyObject in transactions {
            let trans = transaction as! SKPaymentTransaction
            print(trans.error)
            
            switch trans.transactionState {
            case .purchased:
                print("buy ok, unlock IAP HERE")
                print(p.productIdentifier)
                
                let prodID = p.productIdentifier
                switch prodID {
                    case "seemu.iap.removeads":
                        print("remove ads")
                        removeAds()
                    case "seemu.iap.addcoins":
                        print("add coins to account")
                        addCoins()
                    default:
                        print("IAP not found")
                }
                queue.finishTransaction(trans)
            case .failed:
                print("buy error")
                queue.finishTransaction(trans)
                break
            default:
                print("Default")
                break
            }
        }
    }
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

