//
//  LocalManager.swift
//  StripePOC
//
//  Created by Natalia Sibaja on 6/22/18.
//  Copyright © 2018 Natalia Sibaja. All rights reserved.
//

import UIKit
import Stripe
import SwiftyJSON

class LocalManager: NSObject {
    
    static let shared = LocalManager()
    typealias RequestCompletion = (Bool) -> Void
    
    override init() {
        super.init()
    }
    
    func loginUser(completion: @escaping RequestCompletion) {
        CloudClient.shared.loginUser() { result in
            switch result {
            case .success:
                print("User logged in")
                completion(true)
            case .failure(let error):
                print(error)
                completion(false)
            }
        }
    }
    
    func getChargifyId() {
        ChargifyClient.shared.getCustomerWithEmail() { result, error in
            guard let result = result else {
                print(error?.localizedDescription as Any)
                return
            }
            
            let customerId = result[0]["customer"]["id"].int!
            UserDefaults.standard.set(customerId, forKey: "chargifyUserId")
        }
    }
    
    func getSubscriptionId() {
        CloudClient.shared.getSubscriptions() { result, error in
            guard let result = result else {
                print(error?.localizedDescription as Any)
                return
            }
            
            let subscriptions = result["data"]["subscriptions"].arrayValue
            let subscriptionId = subscriptions[0]["chargifySubscriptionId"].int!
            UserDefaults.standard.set(subscriptionId, forKey: "subscriptionId")
        }
    }
}
