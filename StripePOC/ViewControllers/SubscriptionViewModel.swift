//
//  SubscriptionViewModel.swift
//  StripePOC
//
//  Created by Ernesto Gonzalez on 8/7/18.
//  Copyright © 2018 Natalia Sibaja. All rights reserved.
//

import Foundation
import Stripe

class SubscriptionViewModel: NSObject {
    
    var customerID: String = ""
    var source: STPSource!
    typealias SubscriptionResult = (_ success: Bool, _ error: Error?) -> Void
    
    func createStripeSource(paymentInfo: [String: Any], completion: @escaping SubscriptionResult) {
        let group = DispatchGroup()
        group.enter()
        
        DispatchQueue.main.async { [weak self] in
            guard let strongSelf = self else { return }
            
            let sourceParams = STPSourceParams.cardParams(withCard: strongSelf.createSTPCard(paymentInfo))
            //Create a card source with cardParams
            STPAPIClient.shared().createSource(with: sourceParams) { (source, error) in
                guard let source = source, source.flow == .none && source.status == .chargeable else {
                    completion(false, error)
                    return
                }
                
                //with Source object returned attachSource to customer
                let costumerContext = STPCustomerContext(keyProvider: StripeClient.shared)
                costumerContext.attachSource(toCustomer: source, completion: { (error: Error?) in
                    if let error = error {
                        completion(false, error)
                    }
                    
                    strongSelf.source = source
                    //Gets cus_ALPHA id to use on Chargify vault_token.retrieve
                    costumerContext.retrieveCustomer({ (customer: STPCustomer?, error: Error?) in
                        guard let customer = customer else {
                            completion(false, error)
                            return
                        }
                        
                        strongSelf.customerID = customer.stripeID
                        group.leave()
                    })
                })
            }
        }
        
        group.notify(queue: .main) { [weak self] in
            //Once Stripe customer_id is saved
            guard let strongSelf = self else { return }
            
            if strongSelf.customerID.isEmpty == false {
                strongSelf.createChargifyPaymentMethod(completion: { success, error in
                    completion(success, error)
                })
            }
        }
    }
    
    private func createSTPCard(_ paymentInfo: [String: Any]) -> STPCardParams {
        let cardParams = STPCardParams()
        cardParams.name = paymentInfo["userCardName"] as? String ?? ""
        cardParams.number = paymentInfo["cardNumber"] as? String ?? ""
        cardParams.expMonth = UInt(paymentInfo["expMonth"] as? Int ?? 0)
        cardParams.expYear = UInt(paymentInfo["expYear"] as? Int ?? 0)
        cardParams.cvc = paymentInfo["cvc"] as? String ?? ""
        return cardParams
    }
    
    private func createCardParameters(vault_token: String, chargifyId: Int) -> [String: Any] {
        return [
            "first_name": "Natalia",//(cardSource.owner?.name)!
            "last_name": "Test",
            "last_four": (source.cardDetails?.last4)!,
            "card_type": "visa", // source.cardDetails?.brand
            "expiration_month": source.cardDetails?.expMonth as Any,
            "expiration_year": source.cardDetails?.expYear as Any,
            "customer_id": chargifyId, //Chargify customer ID
            "current_vault": "stripe_connect",
            "vault_token": vault_token, //vault_token is the cus_alpha id
            "billing_address": source.owner?.address?.line1 as Any,
            "billing_city": source.owner?.address?.city as Any,
            "billing_state": source.owner?.address?.state as Any,
            "billing_zip": source.owner?.address?.postalCode as Any,
            "billing_country": source.owner?.address?.country as Any,
            "customer_vault_token": "",
            "billing_address_2": source.owner?.address?.line2 as Any,
            "payment_type": "credit_card"
        ]
    }
    
    private func createChargifyPaymentMethod(completion: @escaping SubscriptionResult) {
        let chargifyUserId = UserDefaults.standard.integer(forKey: "chargifyUserId")
        ChargifyClient.shared.createPaymentMethod(paymentParameters: createCardParameters(vault_token: customerID, chargifyId: chargifyUserId), completion: { result, error  in
            guard let result = result else {
                completion(false, error)
                return
            }
            
            if let paymentId = result["payment_profile"]["id"].int {
                print("Payment method created")
                self.updateChargifySubscription(paymentId, completion: { success, error in
                    completion(success, error)
                })
            }
        })
    }
    
    private func updateChargifySubscription(_ paymentId: Int, completion: @escaping SubscriptionResult) {
        let subscriptionId = UserDefaults.standard.integer(forKey: "subscriptionId")
        ChargifyClient.shared.updateSubscriptionPayment(subscriptionId: subscriptionId, paymentId: paymentId, completion: { result, error in
            guard result != nil else {
                completion(false, error)
                return
            }
            
            print("Payment added to subscription")
            completion(true, nil)
        })
    }
}
