//
//  NSData+AES128Crypto.m
//  CDOCredentialsManager
//
//  Created by Norm Barnard on 5/5/14.
//  Copyright (c) 2014 Clamdango. All rights reserved.
//
//  Based on the work described by Rob Napier : http://robnapier.net/aes-commoncrypto/ 

#import <CommonCrypto/CommonCrypto.h>
#import "NSData+AES128Crypto.h"

@implementation NSData (AES128Crypto)

- (NSData *)CDO_encryptAES128WithKey:(unsigned char *)key initVector:(unsigned char *)initVector;
{
    size_t nBytesEncrypted = 0;
    
    NSMutableData *outData = [NSMutableData dataWithLength:self.length + kCCBlockSizeAES128];

    CCCryptorStatus cryptStat = CCCrypt(kCCEncrypt, kCCAlgorithmAES128, kCCOptionPKCS7Padding, key, kCCKeySizeAES128, initVector, self.bytes, self.length, [outData mutableBytes], outData.length, &nBytesEncrypted);
    
    if (cryptStat == kCCSuccess) {
        outData.length = nBytesEncrypted;
        return outData;
    }
    
    return nil;
}

- (NSData *)CDO_decryptAES128WithKey:(unsigned char *)key initVector:(unsigned char *)initVector;
{
    NSMutableData *outData = [NSMutableData dataWithLength:self.length];
    
    size_t nBytesDecrypted = 0;

    CCCryptorStatus cryptStat = CCCrypt(kCCDecrypt, kCCAlgorithmAES128, kCCOptionPKCS7Padding, key, kCCKeySizeAES128, initVector, [self bytes], [self length], [outData mutableBytes], outData.length, &nBytesDecrypted);
    
    if (cryptStat == kCCSuccess) {
        outData.length = nBytesDecrypted;
        return outData;
    }
    
    return nil;
}

+ (NSData *)CDO_randomBytesOfLength:(NSInteger)length
{
    NSMutableData *randomData = [NSMutableData dataWithLength:length];
    
    NSInteger retv = SecRandomCopyBytes(kSecRandomDefault, length, randomData.mutableBytes);
    return (retv < 0) ? nil : randomData;
}

@end
