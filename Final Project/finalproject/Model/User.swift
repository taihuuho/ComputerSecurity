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
            
            ApiClient.sharedInstance().login(account: self.userName, password: self.password).subscribeNext({ (response : AnyObject!) -> Void in
                
                if let dict = response["data"] as? NSDictionary{
                    self.firstName = dict["firstName"] as? String
                    self.lastName = dict["lastName"] as? String
                    self.dob = dict["dob"] as? String
                    self.creditCard = dict["creditCard"] as? String
                    self.CVV = dict["cvv"] as? String
                    self.SSN = dict["ssn"] as? String
                    self.email = dict["email"] as? String
                    self.phone = dict["phone"] as? String
                    self.address = dict["address"] as? String
                    
                    if Runtime.sharedInstance.useRSA == true{
                        self.firstName = JSRSA.sharedInstance().privateDecrypt(self.firstName)
                        self.lastName = JSRSA.sharedInstance().privateDecrypt(self.lastName)
                        self.dob = JSRSA.sharedInstance().privateDecrypt(self.dob)
                        self.creditCard = JSRSA.sharedInstance().privateDecrypt(self.creditCard)
                        self.CVV = JSRSA.sharedInstance().privateDecrypt(self.CVV)
                        self.SSN = JSRSA.sharedInstance().privateDecrypt(self.SSN)
                        self.email = JSRSA.sharedInstance().privateDecrypt(self.email)
                        self.phone = JSRSA.sharedInstance().privateDecrypt(self.phone)
                        self.address = JSRSA.sharedInstance().privateDecrypt(self.address)
                    }
                    
                }
                
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
