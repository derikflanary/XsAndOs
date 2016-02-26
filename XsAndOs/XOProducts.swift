//
//  XOProducts.swift
//  XsAndOs
//
//  Created by Derik Flanary on 2/25/16.
//  Copyright © 2016 Derik Flanary. All rights reserved.
//

import Foundation

import Foundation

// Use enum as a simple namespace.  (It has no cases so you can't instantiate it.)
public enum XOProducts {
    
    /// TODO:  Change this to whatever you set on iTunes connect
    private static let Prefix = "com.derikflanary.XsAndOs."
    
    /// MARK: - Supported Product Identifiers
    public static let RemoveAds = Prefix + "removeAds"
    
    // All of the products assembled into a set of product identifiers.
    private static let productIdentifiers: Set<ProductIdentifier> = ["com.derikflanary.XsAndOs.removeAds"]

    
    /// Static instance of IAPHelper that for rage products.
    public static let store = IAPHelper(productIdentifiers: XOProducts.productIdentifiers)
}

/// Return the resourcename for the product identifier.
func resourceNameForProductIdentifier(productIdentifier: String) -> String? {
    return productIdentifier.componentsSeparatedByString(".").last
}