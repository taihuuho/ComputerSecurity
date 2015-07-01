//
//  JSRSA.h
//  RSA Example
//
//  Created by Js on 12/23/14.
//  Copyright (c) 2014 JS Lim. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JSRSA : NSObject
/*!
 * The public key file name
 */
@property (nonatomic) NSString *publicKeyName;

/*!
 * The private key file name
 */
@property (nonatomic) NSString *privateKeyName;

- (NSString *)publicEncrypt:(NSString *)plainText;
- (NSString *)privateDecrypt:(NSString *)cipherText;
- (NSString *)privateEncrypt:(NSString *)plainText;
- (NSString *)publicDecrypt:(NSString *)cipherText;

+ (JSRSA *)sharedInstance;

@end
