//
//  JSRSA.m
//  RSA Example
//
//  Created by Js on 12/23/14.
//  Copyright (c) 2014 JS Lim. All rights reserved.
//

#include "js_rsa.h"
#import "JSRSA.h"

@implementation JSRSA

#pragma mark - helper
- (NSString *)publicKeyPath
{
    if (_publicKeyName == nil || [_publicKeyName isEqualToString:@""]) return nil;
    
    NSMutableArray *filenameChunks = [[_publicKeyName componentsSeparatedByString:@"."] mutableCopy];
    NSString *extension = filenameChunks[[filenameChunks count] - 1];
    [filenameChunks removeLastObject]; // remove the extension
    NSString *filename = [filenameChunks componentsJoinedByString:@"."]; // reconstruct the filename with no extension
        
    NSString *keyPath = [[NSBundle mainBundle] pathForResource:filename ofType:extension];
    
    return keyPath;
}

- (NSString *)privateKeyPath
{
    if (_privateKeyName == nil || [_privateKeyName isEqualToString:@""]) return nil;
    
    NSMutableArray *filenameChunks = [[_privateKeyName componentsSeparatedByString:@"."] mutableCopy];
    NSString *extension = filenameChunks[[filenameChunks count] - 1];
    [filenameChunks removeLastObject]; // remove the extension
    NSString *filename = [filenameChunks componentsJoinedByString:@"."]; // reconstruct the filename with no extension
        
    NSString *keyPath = [[NSBundle mainBundle] pathForResource:filename ofType:extension];
    
    return keyPath;
}

- (void)setPublicKeyName:(NSString *)publicKeyName{
    _publicKeyName = publicKeyName;
    
    NSString *publicKeyPath = [self publicKeyPath];
    
    if (publicKeyPath == nil) {
        NSLog(@"Can not find pub.der");
        return ;
    }
    
    NSData *publicKeyFileContent = [NSData dataWithContentsOfFile:publicKeyPath];
    if (publicKeyFileContent == nil) {
        NSLog(@"Can not read from pub.der");
        return ;
    }
    
    certificate = SecCertificateCreateWithData(kCFAllocatorDefault, ( __bridge CFDataRef)publicKeyFileContent);
    if (certificate == nil) {
        NSLog(@"Can not read certificate from pub.der");
        return ;
    }
    
    policy = SecPolicyCreateBasicX509();
    OSStatus returnCode = SecTrustCreateWithCertificates(certificate, policy, &trust);
    if (returnCode != 0) {
        NSLog(@"SecTrustCreateWithCertificates fail. Error Code: %d", (int)returnCode);
        return ;
    }
    
    SecTrustResultType trustResultType;
    returnCode = SecTrustEvaluate(trust, &trustResultType);
    if (returnCode != 0) {
        return ;
    }
    
    publicKey = SecTrustCopyPublicKey(trust);
    if (publicKey == nil) {
        NSLog(@"SecTrustCopyPublicKey fail");
        return ;
    }
    
    maxPlainLen = SecKeyGetBlockSize(publicKey) - 12;
}

#pragma mark - implementation
- (NSString *)publicEncrypt:(NSString *)plainText
{
    NSString *keyPath = [self publicKeyPath];
    if (keyPath == nil) return nil;
        
    char *cipherText = js_public_encrypt([plainText UTF8String], [keyPath UTF8String]);
    
    return [NSString stringWithUTF8String:cipherText];
}

- (NSString *)privateDecrypt:(NSString *)cipherText
{
    NSString *keyPath = [self privateKeyPath];
    if (keyPath == nil) return nil;
    
    char *plainText = js_private_decrypt([cipherText UTF8String], [keyPath UTF8String]);
    
    return [NSString stringWithUTF8String:plainText];
}

- (NSString *)privateEncrypt:(NSString *)plainText
{
    NSString *keyPath = [self privateKeyPath];
    if (keyPath == nil) return nil;
        
    char *cipherText = js_private_encrypt([plainText UTF8String], [keyPath UTF8String]);
    
    return [NSString stringWithUTF8String:cipherText];
}

- (NSString *)publicDecrypt:(NSString *)cipherText
{
    NSString *keyPath = [self publicKeyPath];
    if (keyPath == nil) return nil;
    
    char *plainText = js_public_decrypt([cipherText UTF8String], [keyPath UTF8String]);
    
    return [NSString stringWithUTF8String:plainText];
}

- (NSData *) publicEncryptWithData:(NSData *)content {
    
    size_t plainLen = [content length];
    if (plainLen > maxPlainLen) {
        NSLog(@"content(%ld) is too long, must < %ld", plainLen, maxPlainLen);
        return nil;
    }
    
    void *plain = malloc(plainLen);
    [content getBytes:plain
               length:plainLen];
    
    size_t cipherLen = 128; // currently RSA key length is set to 128 bytes
    void *cipher = malloc(cipherLen);
    
    OSStatus returnCode = SecKeyEncrypt(publicKey, kSecPaddingPKCS1, plain,
                                        plainLen, cipher, &cipherLen);
    
    NSData *result = nil;
    if (returnCode != 0) {
        NSLog(@"SecKeyEncrypt fail. Error Code: %d", (int)returnCode);
    }
    else {
        result = [NSData dataWithBytes:cipher
                                length:cipherLen];
    }
    
    free(plain);
    free(cipher);
    
    return result;
}

- (NSData *) publicEncryptWithString:(NSString *)content {
    return [self publicEncryptWithData:[content dataUsingEncoding:NSUTF8StringEncoding]];
}

- (NSString *) publicEncryptToString:(NSString *)content {
    NSData *data = [self publicEncryptWithString:content];
    return [self base64forData:data];
}

// convert NSData to NSString
- (NSString*)base64forData:(NSData*)theData {
    const uint8_t* input = (const uint8_t*)[theData bytes];
    NSInteger length = [theData length];
    
    static char table[] = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/=";
    
    NSMutableData* data = [NSMutableData dataWithLength:((length + 2) / 3) * 4];
    uint8_t* output = (uint8_t*)data.mutableBytes;
    
    NSInteger i;
    for (i=0; i < length; i += 3) {
        NSInteger value = 0;
        NSInteger j;
        for (j = i; j < (i + 3); j++) {
            value <<= 8;
            
            if (j < length) {
                value |= (0xFF & input[j]);
            }
        }
        
        NSInteger theIndex = (i / 3) * 4;
        output[theIndex + 0] =                    table[(value >> 18) & 0x3F];
        output[theIndex + 1] =                    table[(value >> 12) & 0x3F];
        output[theIndex + 2] = (i + 1) < length ? table[(value >> 6)  & 0x3F] : '=';
        output[theIndex + 3] = (i + 2) < length ? table[(value >> 0)  & 0x3F] : '=';
    }
    
    return [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
}

- (void)dealloc{
    CFRelease(certificate);
    CFRelease(trust);
    CFRelease(policy);
    CFRelease(publicKey);
}


#pragma mark - instance method
+ (JSRSA *)sharedInstance
{
    static JSRSA *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[[self class] alloc] init];
    });
    return sharedInstance;
}

@end
