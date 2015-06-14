//
//  Runtime.swift
//  finalproject
//
//  Created by Tai Huu Ho on 6/12/15.
//  Copyright (c) 2015 Tai Huu Ho. All rights reserved.
//

import UIKit


class Runtime : NSObject {
    
    var useRSA : Bool! = false
    var apiProtocolType : ApiProtocolType? = .HTTP
    
    var user : User?
    
    
    // MARK: SHARED INSTANCE
    class var sharedInstance : Runtime {
        struct Static {
            static let instance : Runtime = Runtime()
        }
        return Static.instance
    }
    
    
    override init(){
        useRSA = false
        apiProtocolType = .HTTP
    }
}
