//
//  RSA.m
//  RSA
//
//  Created by Tai Huu Ho on 6/24/15.
//  Copyright (c) 2015 Tai Huu Ho. All rights reserved.
//

#import "RSA.h"
#import "BasicEncodingRules.h"
#import "NSData+Base64.h"
#import "NSString+Base64.h"

@interface RSA()
{
    SecKeyRef publicKey;
    NSString *modulusString;
    NSString *exponentString;
}

@end

@implementation RSA


- (instancetype)init{
    if (self = [super init]) {
//        cipherLen = 1024/8;
    }
    return self;
}


- (void)setXmlPublicKeyPath:(NSString *)xmlPublicKeyPath{
    
    [self createPublicKeyFromXMLRSAKeyValue:xmlPublicKeyPath];
}

- (void)createPublicKeyFromXMLRSAKeyValue:(NSString *)xmlPublicKeyPath{
    
    NSString *xmlString = [NSString stringWithContentsOfFile:xmlPublicKeyPath encoding:NSUTF8StringEncoding error:nil];
    
    //<BitStrength>(\\d+)</BitStrength><RSAKeyValue><Modulus>(.+)</Modulus><Exponent>(\\w+)</Exponent></RSAKeyValue>
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"<BitStrength>(\\d+)</BitStrength><RSAKeyValue><Modulus>(.+)</Modulus><Exponent>(\\w+)</Exponent></RSAKeyValue>" options:NSRegularExpressionCaseInsensitive error:nil];
    
    [regex enumerateMatchesInString:xmlString options:0 range:NSMakeRange(0, xmlString.length) usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
        NSLog(@"BitStrength: %@", [xmlString substringWithRange:[result rangeAtIndex:1]]);
        NSLog(@"Modulus: %@", [xmlString substringWithRange:[result rangeAtIndex:2]]);
        NSLog(@"Exponent: %@", [xmlString substringWithRange:[result rangeAtIndex:3]]);
        
        // get cipher Length
        cipherLen = [xmlString substringWithRange:[result rangeAtIndex:1]].integerValue / 8;
        // get Modulus
        modulusString = [xmlString substringWithRange:[result rangeAtIndex:2]];
        // get Exponent
        exponentString = [xmlString substringWithRange:[result rangeAtIndex:3]];
    }];
    
    NSAssert(modulusString != nil, @"Invalid Modulus");
    NSAssert(exponentString != nil, @"Invalid Exponent");
    
    // create Public Key Data
    NSData *pubKeyModData = [NSData dataWithBase64EncodedString:modulusString];
    NSData *pubKeyExpData = [NSData dataWithBase64EncodedString:exponentString];
    NSArray *keyArray = @[pubKeyModData, pubKeyExpData];
    
    NSData *berData = [keyArray berData];
    
    NSString *publicKeyString = [berData base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength]; // Base64 encoded key
    
    // add Public Key to Keychain
    [self setPublicKey:publicKeyString
                   tag:[self publicKeyIdentifier]];
    
    // retrieve the Public Key Ref from KeyChain
    publicKey = [self keyRefWithTag:[self publicKeyIdentifier]];
}

#pragma mark Private Methods

- (void)setPublicKey:(NSString *)key
                 tag:(NSString *)tag{

    // remove existing key
    [self removeKey:tag];
    
    // strip Public Key Data
    NSData *strippedPublicKeyData = [self strippedPublicKey:key];
    
    if (!strippedPublicKeyData) {
        NSAssert(NO, @"Wrong Public Key");
        return;
    }
    
    // Add Public Key to KeyChain
    CFTypeRef persistKey = nil;
    
    NSMutableDictionary *keyQueryDictionary = [self keyQueryDictionary:tag];
    [keyQueryDictionary setObject:strippedPublicKeyData forKey:(__bridge id)kSecValueData];
    [keyQueryDictionary setObject:(__bridge id)kSecAttrKeyClassPublic forKey:(__bridge id)kSecAttrKeyClass];
    [keyQueryDictionary setObject:[NSNumber numberWithBool:YES] forKey:(__bridge id)kSecReturnPersistentRef];
    
    OSStatus secStatus = SecItemAdd((__bridge CFDictionaryRef)keyQueryDictionary, &persistKey);
    
    if (persistKey != nil)
    {
        CFRelease(persistKey);
    }
    
    if ((secStatus != noErr) && (secStatus != errSecDuplicateItem))
    {
        NSAssert(NO, @"Error add key");
        return;
    }
    
    return;
    
}

- (SecKeyRef)keyRefWithTag:(NSString *)tag{
    NSMutableDictionary *queryKey = [self keyQueryDictionary:tag];
    [queryKey setObject:[NSNumber numberWithBool:YES] forKey:(__bridge id)kSecReturnRef];
    
    SecKeyRef key = NULL;
    OSStatus err = SecItemCopyMatching((__bridge CFDictionaryRef)queryKey, (CFTypeRef *)&key);
    
    if (err != noErr)
    {
        NSAssert(NO, @"Error copy key");
        return nil;
    }
    
    return key;
}

- (NSString *)publicKeyIdentifier
{
    return [NSString stringWithFormat:@"%@.publicKey", [[NSBundle mainBundle] bundleIdentifier]];
}

- (NSString *)strippedKey:(NSString *)key
                   header:(NSString *)header
                   footer:(NSString *)footer
{
    NSString *result = [[key stringByReplacingOccurrencesOfString:header
                                                       withString:@""] stringByReplacingOccurrencesOfString:footer withString:@""];
    
    return [[result stringByReplacingOccurrencesOfString:@"\n"
                                              withString:@""] stringByReplacingOccurrencesOfString:@" " withString:@""];
}

- (BOOL)isX509PublicKey:(NSString *)key
{
    if (([key rangeOfString:[self X509PublicHeader]].location != NSNotFound) && ([key rangeOfString:[self X509PublicFooter]].location != NSNotFound))
    {
        return YES;
    }
    
    return NO;
}


- (NSString *)X509PublicHeader
{
    return @"-----BEGIN PUBLIC KEY-----";
}


- (NSString *)X509PublicFooter
{
    return @"-----END PUBLIC KEY-----";
}

- (NSData *)strippedPublicKey:(NSString *)key
{
    NSString *strippedKey = strippedKey = [self strippedKey:key
                                                     header:[self X509PublicHeader]
                                                     footer:[self X509PublicFooter]];;
    
    NSData *strippedPublicKeyData = [strippedKey base64DecodedData];
    if ([self isX509PublicKey:key])
    {
        unsigned char * bytes = (unsigned char *)[strippedPublicKeyData bytes];
        size_t bytesLen = [strippedPublicKeyData length];
        
        size_t i = 0;
        if (bytes[i++] != 0x30)
        {
            return nil;
        }
        
        if (bytes[i] > 0x80)
        {
            i += bytes[i] - 0x80 + 1;
        }
        else
        {
            i++;
        }
        
        if (i >= bytesLen)
        {
            return nil;
        }
        if (bytes[i] != 0x30)
        {
            return nil;
        }
        
        i += 15;
        
        if (i >= bytesLen - 2)
        {
            
            return nil;
        }
        if (bytes[i++] != 0x03)
        {
            return nil;
        }
        
        if (bytes[i] > 0x80)
        {
            i += bytes[i] - 0x80 + 1;
        }
        else
        {
            i++;
        }
        
        if (i >= bytesLen)
        {
            return nil;
        }
        if (bytes[i++] != 0x00)
        {
            return nil;
        }
        if (i >= bytesLen)
        {
            return nil;
        }
        
        strippedPublicKeyData = [NSData dataWithBytes:&bytes[i]
                                               length:bytesLen - i];
    }
    
    if (!strippedPublicKeyData)
    {
        
        return nil;
    }
    
    return strippedPublicKeyData;
}

- (void)removeKey:(NSString *)tag
{
    NSDictionary *queryKey = [self keyQueryDictionary:tag];
    OSStatus secStatus = SecItemDelete((__bridge CFDictionaryRef)queryKey);
    
    if ((secStatus != noErr) && (secStatus != errSecDuplicateItem) && (secStatus != errSecItemNotFound) )
    {
        NSAssert(NO, @"Error remove key");
    }
}

- (NSMutableDictionary *)keyQueryDictionary:(NSString *)tag
{
    NSData *keyTag = [tag dataUsingEncoding:NSUTF8StringEncoding];
    
    NSMutableDictionary *result = [[NSMutableDictionary alloc] init];
    [result setObject:(__bridge id)kSecClassKey forKey:(__bridge id)kSecClass];
    [result setObject:(__bridge id)kSecAttrKeyTypeRSA forKey:(__bridge id)kSecAttrKeyType];
    [result setObject:keyTag forKey:(__bridge id)kSecAttrApplicationTag];
    [result setObject:(__bridge id)kSecAttrAccessibleWhenUnlocked forKey:(__bridge id)kSecAttrAccessible];
    
    return result;
}


- (NSData *) encryptWithData:(NSData *)content {
    
    if (!publicKey) {
        NSAssert(NO, @"Need to set Public Key");
        return nil;
    }
    
    size_t plainLen = [content length];
    
    void *plain = malloc(plainLen);
    [content getBytes:plain
               length:plainLen];
    
    
    void *cipher = malloc(cipherLen);
    
    OSStatus returnCode = SecKeyEncrypt(publicKey, kSecPaddingPKCS1, plain,
                                        plainLen, cipher, &cipherLen);
    
    NSData *result = nil;
    if (returnCode != 0) {
        NSString *e = [NSString stringWithFormat:@"SecKeyEncrypt fail. Error Code: %d", returnCode];
        NSAssert(NO, e);
    }
    else {
        result = [NSData dataWithBytes:cipher
                                length:cipherLen];
    }
    
    free(plain);
    free(cipher);
    
    return result;
}

#pragma mark Public Methods
- (NSString *)encrypt:(NSString *)plainText{
    NSData *data = [self encryptWithData:[plainText dataUsingEncoding:NSUTF8StringEncoding]];
    return [data base64EncodedString];
}
@end
