//
//  RSA.h
//  finalproject
//
//  Created by Tai Huu Ho on 6/13/15.
//  Copyright (c) 2015 Tai Huu Ho. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RSA : NSObject {
    SecKeyRef publicKey;
    SecCertificateRef certificate;
    SecPolicyRef policy;
    SecTrustRef trust;
    size_t maxPlainLen;
}

- (instancetype)initWithPublicKeyPath:(NSString*)publicKeyPath;
- (NSData *) encryptWithData:(NSData *)content;
- (NSData *) encryptWithString:(NSString *)content;
- (NSString *) encryptToString:(NSString *)content;

@end
