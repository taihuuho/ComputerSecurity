//
//  RSA.h
//  RSA
//
//  Created by Tai Huu Ho on 6/24/15.
//  Copyright (c) 2015 Tai Huu Ho. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RSA : NSObject
{
    size_t cipherLen;
}
@property (nonatomic)   NSString *xmlPublicKeyPath;

- (NSString*)encrypt:(NSString*)plainText;
@end
