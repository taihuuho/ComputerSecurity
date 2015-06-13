//
//  Utils.h
//  finalproject
//
//  Created by Tai Huu Ho on 6/12/15.
//  Copyright (c) 2015 Tai Huu Ho. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Utils : NSObject

+ (instancetype)sharedInstance;

- (NSURLCredential*)credentialWithP21File:(NSString*)p12Name password:(NSString*)password;
@end
