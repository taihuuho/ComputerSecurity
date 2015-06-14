//
//  BaseApiClient.swift
//  finalproject
//
//  Created by Tai Huu Ho on 6/12/15.
//  Copyright (c) 2015 Tai Huu Ho. All rights reserved.
//

import UIKit

enum APIMethod : String{
    case POST = "POST"
    case GET = "GET"
}

class BaseApiClient: AFHTTPRequestOperationManager {
    
    override init!(baseURL url: NSURL!) {
        super.init(baseURL: url);
        self.completionQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)
        self.requestSerializer = AFJSONRequestSerializer() as AFJSONRequestSerializer
        self.responseSerializer = AFJSONResponseSerializer() as AFJSONResponseSerializer
        
        AFNetworkActivityIndicatorManager.sharedManager().enabled = true
    
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func configureRequest(request : NSMutableURLRequest){
        
    }
    
    // MARK: FOR TESTING
    func enqueueDummyRequest(#response: AnyObject, error: NSError?) -> RACSignal {
        let delay = 1 * Double(NSEC_PER_SEC)
        let time = dispatch_time(DISPATCH_TIME_NOW, Int64(delay))
        let application = UIApplication.sharedApplication()
        application.networkActivityIndicatorVisible = true
        let signal:RACSignal = RACSignal.createSignal { (subscriber:RACSubscriber!) -> RACDisposable! in
            dispatch_after(time, dispatch_get_main_queue(), { () -> Void in
                if let possibleError = error {
                    subscriber.sendError(possibleError)
                }
                else {
                    subscriber.sendNext(response)
                    subscriber.sendCompleted()
                }
                application.networkActivityIndicatorVisible = false
            })
            
            return RACDisposable(block: { () -> Void in
                
            })
        }
        
        return signal.replayLazily()
    }
    
    // MARK: EQUEUE API REQUEST
    func enqueueRequest(request: NSURLRequest) -> RACSignal{
        
        let signal:RACSignal = RACSignal.createSignal { (subscriber:RACSubscriber!) -> RACDisposable! in
            let operation : AFHTTPRequestOperation = self.HTTPRequestOperationWithRequest(request, success: { (operation:AFHTTPRequestOperation!, response:AnyObject!) -> Void in
                #if DEBUG
                    NSLog("request for %@ :\n %@",request.URL.absoluteString! , operation.responseString)
                #endif
                print(response)
                subscriber.sendNext(response)
                subscriber.sendCompleted()
                
                }, failure: { (operation:AFHTTPRequestOperation!, error:NSError!) -> Void in
                    #if DEBUG
                        NSLog("request fail %@",error.description)
                    #endif
                    if let responeString = operation.responseString {
                        let error = NSError(domain: operation.responseString, code: operation.response.statusCode, userInfo: nil)
                        subscriber.sendError(error)
                    }else {
                        subscriber.sendError(error)
                    }
                    
            })
            
            operation.securityPolicy = AFSecurityPolicy(pinningMode: .Certificate)
            operation.securityPolicy.allowInvalidCertificates = true
            operation.setWillSendRequestForAuthenticationChallengeBlock({ (connection : NSURLConnection!, challenge : NSURLAuthenticationChallenge!) -> Void in
                if challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust{
                    challenge.sender.useCredential(NSURLCredential(forTrust: challenge.protectionSpace.serverTrust), forAuthenticationChallenge: challenge)
                
                }else if challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodClientCertificate{

                    let credential = Utils.sharedInstance().credentialWithP21File("user", password: "client")
                    if credential != nil{
                        challenge.sender.useCredential(credential, forAuthenticationChallenge: challenge)
                    }else{
                        challenge.sender.cancelAuthenticationChallenge(challenge)
                    }
                }else{
                    challenge.sender.cancelAuthenticationChallenge(challenge)
                }
            })
            
            self.operationQueue.addOperation(operation);
            
            return RACDisposable(block: { () -> Void in
                operation.cancel();
                
            })
        }
        
        return signal.replayLazily()
    }
    
    // MARK: MULTIPART REQUEST
    func enqueueMultipartRequest(request:NSURLRequest) -> RACSignal{
        let signal : RACSignal = RACSignal.createSignal { (subscriber : RACSubscriber!) -> RACDisposable! in
            let operation : AFHTTPRequestOperation = self.HTTPRequestOperationWithRequest(request, success: { (operation : AFHTTPRequestOperation!, response : AnyObject!) -> Void in
                subscriber.sendNext(response)
                subscriber.sendCompleted()
                }, failure: { (operation : AFHTTPRequestOperation!, error : NSError!) -> Void in
                    subscriber.sendNext(error)
            })
            
            // progress tracking
            operation.setUploadProgressBlock({ (bytesWritten : UInt, totalBytesWritten : Int64, totalBytesExpectedToWrite : Int64) -> Void in
                let progress = totalBytesWritten / totalBytesExpectedToWrite
                subscriber.sendNext(Float32(progress))
            })
            
            // handle when the app go to background
            operation.setShouldExecuteAsBackgroundTaskWithExpirationHandler({ () -> Void in
                self.settingsForRemindUploadNotification()
            })
            
            self.completionQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)
            self.operationQueue.addOperation(operation);
            
            return RACDisposable(block: { () -> Void in
                operation.cancel();
            })
        }
        
        return signal.replayLazily();
    }
    
    // MARK: RESUME UPLOADING
    private func settingsForRemindUploadNotification() -> Void{
        // show notification after 1 second
        let timeInterval : NSTimeInterval = NSDate.timeIntervalSinceReferenceDate() + 60*1;
        let date : NSDate = NSDate(timeIntervalSinceReferenceDate: timeInterval)
        
        let notification : UILocalNotification = UILocalNotification()
        notification.fireDate = date
        notification.timeZone = NSTimeZone.defaultTimeZone()
        notification.alertBody = NSLocalizedString("You need to open SecurityDemo to continue the uploading", comment:"")
        notification.alertAction = "Resume";
        notification.soundName = UILocalNotificationDefaultSoundName
        
        UIApplication.sharedApplication().scheduleLocalNotification(notification)
    }
    
    //MARK: REQUEST METHOD
    func requestWithMethod(#method : APIMethod, path : String, parameters : Dictionary<String, AnyObject>?) -> NSURLRequest!{
        var error : NSError?
        var request : NSMutableURLRequest  = self.requestSerializer.requestWithMethod(method.rawValue, URLString: NSURL(string: path, relativeToURL: self.baseURL)?.absoluteString, parameters: parameters, error: &error)
        
        // configure request
        configureRequest(request)
        
        return request;
        
    }
    
    func requestMultipart(#path : NSString, parameters : Dictionary<String, AnyObject>, filePath : String, name : String) -> NSURLRequest{
        var error : NSError?
        
        var request : NSMutableURLRequest = AFHTTPRequestSerializer().multipartFormRequestWithMethod("POST", URLString: NSURL(string: path, relativeToURL: self.baseURL)?.absoluteString, parameters: parameters, constructingBodyWithBlock: { (form : AFMultipartFormData!) -> Void in
            var appendError : NSError?
            form.appendPartWithFileURL(NSURL(fileURLWithPath: filePath), name: name, fileName: "upload.jpg", mimeType: "image/jpeg", error: &appendError)
            
            }, error: &error)
        
        // configure reqquest
        configureRequest(request)
        
        return request
    }
}
