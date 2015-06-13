//
//  User.swift
//  finalproject
//
//  Created by Tai Huu Ho on 6/12/15.
//  Copyright (c) 2015 Tai Huu Ho. All rights reserved.
//

import UIKit

class User: NSObject {
    var userName: String?
    var password: String?
    var firstName: String?
    var lastName: String?
    var dob: String?
    var address: String?
    var phone: String?
    var SSN: String?
    var email: String?
    var creditCard: String?
    var CVV: String?
    
    func signalLogin() -> RACSignal{
        let signal = RACSignal.createSignal { (subscriber : RACSubscriber!) -> RACDisposable! in
            
            ApiClient.sharedInstance.login(account: self.userName, password: self.password).subscribeNext({ (response : AnyObject!) -> Void in
                
                subscriber.sendNext(response)
                subscriber.sendCompleted()
                }, error: { (error: NSError!) -> Void in
                subscriber.sendError(error)
            })
            
            return nil
        }
        
        return signal.replayLazily()
    }
}