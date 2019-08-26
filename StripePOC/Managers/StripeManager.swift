//
//  Utility.swift
//  StripePOC
//
//  Created by Natalia Sibaja on 6/20/18.
//  Copyright © 2018 Natalia Sibaja. All rights reserved.
//

import UIKit
import Stripe


class StripeManager: NSObject {
    
    static let sharedInstance = StripeManager()
    
    private override init() {
        super.init()
    }
    
    internal func setupKey(){
        STPPaymentConfiguration.shared().publishableKey = Constants.publishableKey
    }
}
