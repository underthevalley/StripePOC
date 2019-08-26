//
//  Constants.swift
//  StripePOC
//
//  Created by Natalia Sibaja on 6/25/18.
//  Copyright © 2018 Natalia Sibaja. All rights reserved.
//

import UIKit
import SwiftyJSON

typealias ResultRequestCompletion = (_ result: Result) -> Void
typealias JSONRequestCompletion = (_ json: JSON?, _ error: Error?) -> Void

enum Constants {
    static let publishableKey = "pk_test_XXXXXX"
    static let baseURLString = "https://[YOUR STRIPE ENCRYPT URL]"
    static let defaultCurrency = "usd"
    static let defaultDescription = "Subscription"
}

enum Cloud {
    static let baseURL = "https://[YOUR API]"
    static let login = ""
    static let subscriptions = ""
    static let defaultUser = "user@email.com"
    static let defaultPassword = "1234"
}

enum Chargify {
    static let baseURL = "https://[YOUR API].chargify.com/"
    static let apiKey =  "[YOUR API KEY]"
    static let customer = "customers.json?q="
    static let subscriptions = "subscriptions/%i/payment_profiles/%i/change_payment_profile.json"
    static let payment = "payment_profiles.json"
}

struct kUserDefaultKeys {
    static let Token = "token"
    static let UserToken = "encryptedUserId"
    static let Email = "email"
    static let FirstName = "firstName"
    static let LastName = "lastName"
    static let DeviceToken = "deviceToken"
}
