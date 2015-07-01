//
//  RACSupport.swift
//  finalproject
//
//  Created by Tai Huu Ho on 6/13/15.
//  Copyright (c) 2015 Tai Huu Ho. All rights reserved.
//

import Foundation

struct RAC  {
    var target : NSObject!
    var keyPath : String!
    var nilValue : AnyObject!
    
    init(_ target: NSObject!, _ keyPath: String, nilValue: AnyObject? = nil) {
        self.target = target
        self.keyPath = keyPath
        self.nilValue = nilValue
    }
    
    
    func assignSignal(signal : RACSignal) {
        signal.setKeyPath(self.keyPath, onObject: self.target, nilValue: self.nilValue)
    }
}

infix operator <~ {}
func <~ (rac: RAC, signal: RACSignal) {
    rac.assignSignal(signal)
}

infix operator ~> {}
func ~> (signal: RACSignal, rac: RAC) {
    rac.assignSignal(signal)
}


func RACObserve(target: NSObject!, keyPath: String) -> RACSignal  {
    return target.rac_valuesForKeyPath(keyPath, observer: target)
}



extension RACSignal {
    
    class func combineLatestAs<T, U, R: AnyObject>(signals:[RACSignal], reduce:(T,U) -> R) -> RACSignal {
        return RACSignal.combineLatest(signals).mapAs {
            (tuple: RACTuple) -> R in
            return reduce(tuple.first as T, tuple.second as U)
        }
    }
    
    func subscribeNextAs<T>(nextClosure:(T) -> ()) -> () {
        self.subscribeNext {
            (next: AnyObject!) -> () in
            let nextAsT = next! as T
            nextClosure(nextAsT)
        }
    }
    
    func mapAs<T: AnyObject, U: AnyObject>(mapClosure:(T) -> U) -> RACSignal {
        return self.map {
            (next: AnyObject!) -> AnyObject! in
            let nextAsT = next as T
            return mapClosure(nextAsT)
        }
    }
    
    func filterAs<T: AnyObject>(filterClosure:(T) -> Bool) -> RACSignal {
        return self.filter {
            (next: AnyObject!) -> Bool in
            let nextAsT = next as T
            return filterClosure(nextAsT)
        }
    }
    
    func doNextAs<T: AnyObject>(nextClosure:(T) -> ()) -> RACSignal {
        return self.doNext {
            (next: AnyObject!) -> () in
            let nextAsT = next as T
            nextClosure(nextAsT)
        }
    }
    
    
    
    func reduces(reduceBlock : ([AnyObject] ) -> (AnyObject)) -> RACSignal{
        return self.map { (a :AnyObject!) -> AnyObject! in
            if let tuple = a as? RACTuple{
                return reduceBlock(tuple.allObjects())
            }
            return reduceBlock([a])
        }
    }
}