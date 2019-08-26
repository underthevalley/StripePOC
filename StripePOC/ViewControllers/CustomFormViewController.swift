//
//  CustomFormViewController.swift
//  StripePOC
//
//  Created by Natalia Sibaja on 6/26/18.
//  Copyright © 2018 Natalia Sibaja. All rights reserved.
//

import UIKit
import Stripe

class CustomFormViewController: UIViewController {
    
    var viewModel: SubscriptionViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel = SubscriptionViewModel()
        
        //Login to Molekule BE
        LocalManager.shared.loginUser { requestCompleted in
            guard requestCompleted else {
                print("Request error")
                return
            }
            
            //Get customer_id from Chargify with user email
            LocalManager.shared.getChargifyId()
            //Get Molekule BE Subscriptions saved to /me
            LocalManager.shared.getSubscriptionId()
        }
    }
    
    @IBAction func renewTapped() {
        // Here we gonna gather the info from the IBOutlets
        let paymentInfo: [String: Any] = [
            "userCardName": "Natalia Test",
            "cardNumber": "4242424242424242",
            "expMonth": 10,
            "expYear": 21,
            "cvc": "422",
        ]
        
        viewModel.createStripeSource(paymentInfo: paymentInfo) { success, error in
            // Manage success and error variables here
            print("Success \(success)")
        }
    }
}

