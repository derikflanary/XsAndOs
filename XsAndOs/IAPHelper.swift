//
//  IAPHelper.swift
//  inappragedemo
//
//  Created by Ray Fix on 5/1/15.
//  Copyright (c) 2015 Razeware LLC. All rights reserved.
//

import StoreKit

/// Notification that is generated when a product is purchased.
public let IAPHelperProductPurchasedNotification = "IAPHelperProductPurchasedNotification"

/// Product identifiers are unique strings registered on the app store.
public typealias ProductIdentifier = String

/// Completion handler called when products are fetched.
public typealias RequestProductsCompletionHandler = (_ success: Bool, _ products: [SKProduct]) -> ()


/// A Helper class for In-App-Purchases, it can fetch products, tell you if a product has been purchased,
/// purchase products, and restore purchases.  Uses NSUserDefaults to cache if a product has been purchased.
open class IAPHelper : NSObject  {
  
  /// MARK: - Private Properties
  
  // Used to keep track of the possible products and which ones have been purchased.
    
    fileprivate let productIdentifiers: Set<ProductIdentifier>
    fileprivate var purchasedProductIdentifiers = Set<ProductIdentifier>()
  
  // Used by SKProductsRequestDelegate
    fileprivate var productRequest: SKProductsRequest?
    fileprivate var completionHandler: RequestProductsCompletionHandler?
  
  /// MARK: - User facing API
  
  /// Initialize the helper.  Pass in the set of ProductIdentifiers supported by the app.
  public init(productIdentifiers: Set<String>) {
    
    self.productIdentifiers = productIdentifiers
    
    for productIdentifier in productIdentifiers {
      let purchased = UserDefaults.standard.bool(forKey: productIdentifier)
      if purchased {
        purchasedProductIdentifiers.insert(productIdentifier)
        print("Previously purchased: \(productIdentifier)")
      }
      else {
        print("Not purchased: \(productIdentifier)")
      }
    }
    super.init()
    SKPaymentQueue.default().add(self)
  }
    
  
  /// Gets the list of SKProducts from the Apple server calls the handler with the list of products.
  public func requestProductsWithCompletionHandler(handler: @escaping RequestProductsCompletionHandler) {
    if (SKPaymentQueue.canMakePayments()) {
        completionHandler = handler
        productRequest = SKProductsRequest(productIdentifiers: productIdentifiers)
        productRequest?.delegate = self
        productRequest?.start()
    }
    
  }
  
  /// Initiates purchase of a product.
  public func purchaseProduct(product: SKProduct) {
    print("Buying \(product.productIdentifier)...")
    let payment = SKPayment(product: product)
    SKPaymentQueue.default().add(payment)
  }
  
  /// Given the product identifier, returns true if that product has been purchased.
  public func isProductPurchased(productIdentifier: ProductIdentifier) -> Bool {
    return purchasedProductIdentifiers.contains(productIdentifier)
  }
  
  /// If the state of whether purchases have been made is lost  (e.g. the
  /// user deletes and reinstalls the app) this will recover the purchases.
  public func restoreCompletedTransactions() {
    SKPaymentQueue.default().restoreCompletedTransactions()
  }
  
  public class func canMakePayments() -> Bool {
    return SKPaymentQueue.canMakePayments()
  }
}

// This extension is used to get a list of products, their titles, descriptions,
// and prices from the Apple server.

extension IAPHelper: SKProductsRequestDelegate {
  public func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
    print("Loaded list of products...")
    print(response.products)
    let products = response.products 
    completionHandler?(true, products)
    clearRequest()
    
    // debug printing
    for p in products {
      print("Found product: \(p.productIdentifier) \(p.localizedTitle) \(p.price.floatValue)")
    }
  }
  
  @nonobjc public func request(_ request: SKRequest, didFailWithError error: NSError) {
    print("Failed to load list of products.")
    print("Error: \(error)")
    clearRequest()
  }
  
  fileprivate func clearRequest() {
    productRequest = nil
    completionHandler = nil
  }
}


extension IAPHelper: SKPaymentTransactionObserver {
  /// This is a function called by the payment queue, not to be called directly.
  /// For each transaction act accordingly, save in the purchased cache, issue notifications,
  /// mark the transaction as complete.
    public func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions {
            switch (transaction.transactionState) {
            case .purchased:
                completeTransaction(transaction)
                break
            case .failed:
                failedTransaction(transaction: transaction)
                break
            case .restored:
                restoreTransaction(transaction: transaction)
                break
            case .deferred:
                break
            case .purchasing:
                break
            }
        }

    }
    
       
  fileprivate func completeTransaction(_ transaction: SKPaymentTransaction) {
    print("completeTransaction...")
    provideContentForProductIdentifier(productIdentifier: transaction.payment.productIdentifier)
    SKPaymentQueue.default().finishTransaction(transaction)
  }
  
  private func restoreTransaction(transaction: SKPaymentTransaction) {
    let productIdentifier = transaction.original!.payment.productIdentifier
    print("restoreTransaction... \(productIdentifier)")
    provideContentForProductIdentifier(productIdentifier: productIdentifier)
    SKPaymentQueue.default().finishTransaction(transaction)
  }
  
  // Helper: Saves the fact that the product has been purchased and posts a notification.
  private func provideContentForProductIdentifier(productIdentifier: String) {
    purchasedProductIdentifiers.insert(productIdentifier)
    UserDefaults.standard.set(true, forKey: "removeAds")
    NotificationCenter.default.post(name: NSNotification.Name(rawValue: IAPHelperProductPurchasedNotification), object: productIdentifier)
  }
  
  private func failedTransaction(transaction: SKPaymentTransaction) {
    print("failedTransaction...")
    if transaction.error != nil {
      print("Transaction error: \(transaction.error!.localizedDescription)")
    }
    SKPaymentQueue.default().finishTransaction(transaction)
  }
}
