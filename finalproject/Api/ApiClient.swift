//
//  ApiClient.swift
//  finalproject
//
//  Created by Tai Huu Ho on 6/12/15.
//  Copyright (c) 2015 Tai Huu Ho. All rights reserved.
//

import UIKit

enum ApiProtocolType : Int{
    case HTTP = 0
    case HTTPs
}

class ApiClient: BaseApiClient {
    
    
    override init!(baseURL url: NSURL!) {
        super.init(baseURL: url)
        JSRSA.sharedInstance().publicKey = "g3.pub"
        
    }

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    // MARK: API INTERFACE INSTANCE
    
    class var httpsInstance : ApiClient {
        struct Static {
            static let instance : ApiClient = ApiClient(baseURL: NSURL(string: "https://huung:443"))
        }
        return Static.instance
    }
    
    class var hhtpInstance : ApiClient {
        struct Static {
            static let instance : ApiClient = ApiClient(baseURL: NSURL(string: "http://huung:3000"))
        }
        return Static.instance
    }
    
    class func sharedInstance() -> ApiClient{
        
        if Runtime.sharedInstance.apiProtocolType == .HTTP{
            return ApiClient.hhtpInstance
        }else{
            return ApiClient.httpsInstance
        }
    }
    

    // add header fields
    override func configureRequest(request: NSMutableURLRequest) {
        request.addValue(Runtime.sharedInstance.useRSA == true ? "true" : "false", forHTTPHeaderField: "isRSA")
    }
    
   
    func login(#account: String!, password: String!) -> RACSignal{
        
        let ac = Runtime.sharedInstance.useRSA == true ? JSRSA.sharedInstance().publicEncrypt(account) : account
        let pw = Runtime.sharedInstance.useRSA == true ? JSRSA.sharedInstance().publicEncrypt(password) : password
        
        var request = requestWithMethod(method: APIMethod.POST, path: "login", parameters: ["username" : ac, "password" : ac])
        return enqueueRequest(request)
    }
    
}
