//
//  CloudClient.swift
//  StripePOC
//
//  Created by Natalia Sibaja on 7/2/18.
//  Copyright © 2018 Natalia Sibaja. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

final class CloudClient {
    
    static let shared = CloudClient()
    
    private init() { }
    
    private lazy var apiURL: URL = {
        guard let url = URL(string: Cloud.baseURL) else {
            fatalError("Invalid URL")
        }
        return url
    }()
    
    func loginUser(completion: @escaping ResultRequestCompletion) {
        let url = apiURL.appendingPathComponent(Cloud.login)
        let params: [String: Any] = [
            "email": Cloud.defaultUser,
            "password": Cloud.defaultPassword,
            "deviceId" : UIDevice.current.identifierForVendor!.uuidString,
            "deviceTypeId" : "1",
            "appVersion" : "1.5",
            "deviceToken" : ""
        ]
        
        Alamofire.request(url, method: .post, parameters: params, encoding: JSONEncoding.default)
            .validate(statusCode: 200..<500)
            .responseJSON { response in
                switch response.result {
                case .success:
                    let data = JSON(response.result.value!)
                    if let dictObj  = data["data"].dictionary {
                        let token = dictObj["token"]?.rawValue as! String
                        UserDefaults.standard.set(token, forKey: kUserDefaultKeys.Token)
                    }
                    completion(Result.success)
                case .failure(let error):
                    completion(Result.failure(error))
                }
        }
    }
    
    func getSubscriptions(completion: @escaping JSONRequestCompletion) {
        let url = apiURL.appendingPathComponent(Cloud.subscriptions)
        let headers : HTTPHeaders = [
            "token": UserDefaults.standard.value(forKey: kUserDefaultKeys.Token) as! String]
        Alamofire.request(url, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers)
            .validate(statusCode: 200..<300)
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
