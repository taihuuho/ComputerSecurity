//
//  ApiClient.swift
//  finalproject
//
//  Created by Tai Huu Ho on 6/12/15.
//  Copyright (c) 2015 Tai Huu Ho. All rights reserved.
//

import UIKit

class ApiClient: BaseApiClient {
    
    // MARK: API INTERFACE INSTANCE
    class var sharedInstance : ApiClient {
        struct Static {
            static let instance : ApiClient = ApiClient(baseURL: NSURL(string: "https://huung:443"))
        }
        return Static.instance
    }

    // add header fields
    override func configureRequest(request: NSMutableURLRequest) {
        request.addValue("1", forHTTPHeaderField: "isRSA")
    }
    
   
    func login(#account: String!, password: String!) -> RACSignal{
        var request = requestWithMethod(method: APIMethod.POST, path: "login", parameters: ["username" : account, "password" : password])
        return enqueueRequest(request)
    }
    
}
