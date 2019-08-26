//
//  ChargifyClient.swift
//  StripePOC
//
//  Created by Natalia Sibaja on 7/10/18.
//  Copyright © 2018 Natalia Sibaja. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import Stripe

final class ChargifyClient {
    
    static let shared = ChargifyClient()
    
    private lazy var baseURL: URL = {
        guard let url = URL(string: Chargify.baseURL) else {
            fatalError("Invalid URL")
        }
        return url
    }()
    
    private init() { }
    
    func getCustomerWithEmail(completion: @escaping JSONRequestCompletion) {
        let url = Chargify.baseURL + Chargify.customer + Cloud.defaultUser
        Alamofire.request(url, method: .get, parameters: nil, encoding: JSONEncoding.default)
            .authenticate(user: Chargify.apiKey, password: "X")
            .validate(statusCode: 200..<600)
            .validate().responseJSON { response in
                switch response.result {
                case .success(let data):
                    let jsonData = JSON(data)
                    completion(jsonData, nil)
                case .failure(let error):
                    print("Request failed with error: \(error)")
                    completion(nil, error)
                }
        }
    }
    
    func createPaymentMethod(paymentParameters: [String: Any], completion: @escaping JSONRequestCompletion) {
        let url = Chargify.baseURL + Chargify.payment
        let parameter = ["payment_profile": paymentParameters]
        
        Alamofire.request(url, method: .post, parameters: parameter, encoding: JSONEncoding.default)
            .authenticate(user: Chargify.apiKey, password: "X")
            .validate(statusCode: 200..<600)
            .validate().responseJSON { response in
                switch response.result {
                case .success(let data):
                    let jsonData = JSON(data)
                    completion(jsonData, nil)
                case .failure(let error):
                    print("Request failed with error: \(error)")
                    completion(nil, error)
                }
        }
    }
    
    func updateSubscriptionPayment(subscriptionId: Int, paymentId: Int, completion: @escaping JSONRequestCompletion) {
        let url = Chargify.baseURL + String(format: Chargify.subscriptions, subscriptionId, paymentId)
        Alamofire.request(url, method: .post, parameters: nil, encoding: JSONEncoding.default)
            .authenticate(user: Chargify.apiKey, password: "X")
            .validate(statusCode: 200..<600)
            .validate().responseJSON { response in
                switch response.result {
                case .success(let data):
                    let jsonData = JSON(data)
                    completion(jsonData, nil)
                case .failure(let error):
                    print("Request failed with error: \(error)")
                    completion(nil, error)
                }
        }
    }
}

