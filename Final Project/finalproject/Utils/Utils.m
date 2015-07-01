//
//  Utils.m
//  finalproject
//
//  Created by Tai Huu Ho on 6/12/15.
//  Copyright (c) 2015 Tai Huu Ho. All rights reserved.
//

#import "Utils.h"

@implementation Utils


+ (instancetype)sharedInstance{
    static Utils *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [Utils new];
    });
    
    return sharedInstance;
}

- (NSURLCredential *)credentialWithP21File:(NSString *)p12Name password:(NSString *)pw{
    NSString *p12Path = [[NSBundle mainBundle] pathForResource:p12Name ofType:@"p12"];
    NSData *p12Data = [[NSData alloc] initWithContentsOfFile:p12Path];
    
    
    CFStringRef password = (__bridge CFStringRef)pw;
    const void *keys[] = { kSecImportExportPassphrase };
    const void *values[] = { password };
    CFDictionaryRef optionsDictionary = CFDictionaryCreate(NULL, keys, values, 1, NULL, NULL);
    CFArrayRef p12Items;
    
    OSStatus result = SecPKCS12Import((__bridge CFDataRef)p12Data, optionsDictionary, &p12Items);
    
    if(result == noErr) {
        CFDictionaryRef identityDict = CFArrayGetValueAtIndex(p12Items, 0);
        SecIdentityRef identityApp =(SecIdentityRef)CFDictionaryGetValue(identityDict,kSecImportItemIdentity);
        
        SecCertificateRef certRef;
        SecIdentityCopyCertificate(identityApp, &certRef);
        
        SecCertificateRef certArray[1] = { certRef };
        CFArrayRef myCerts = CFArrayCreate(NULL, (void *)certArray, 1, NULL);
        CFRelease(certRef);
        
        NSURLCredential *credential = [NSURLCredential credentialWithIdentity:identityApp certificates:(__bridge NSArray *)myCerts persistence:NSURLCredentialPersistencePermanent];
        CFRelease(myCerts);
        
        return credential;
    }
    
    return nil;
}
@end
