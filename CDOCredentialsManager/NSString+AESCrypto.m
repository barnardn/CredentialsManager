//
//  NSString+AESCrypto.m
//  CDOCredentialsManager
//
//  Created by Norm Barnard on 5/12/14.
//  Copyright (c) 2014 Clamdango. All rights reserved.
//
//
//  Based on the work posted here: http://robnapier.net/aes-commoncrypto/ 

#import <CommonCrypto/CommonCrypto.h>
#import "NSData+AES128Crypto.h"
#import "NSString+AESCrypto.h"

static const NSInteger kTenthOfOneSecondInMilliseconds = 100;

@implementation NSString (AESCrypto)

- (NSData *)CDO_deriveAES128KeyWithSalt:(NSData *)salt;
{
    NSParameterAssert(salt.length == 8);
    
    NSMutableData *derivedKey = [NSMutableData dataWithLength:kCCKeySizeAES128];
    
    NSInteger nRounds = [self _cdo_numberOfRoundsForSalt:salt derivedKeyLength:derivedKey.length targetTimeInMilliseconds:kTenthOfOneSecondInMilliseconds];
    
    NSInteger retv = CCKeyDerivationPBKDF(kCCPBKDF2, self.UTF8String, [self lengthOfBytesUsingEncoding:NSUTF8StringEncoding], salt.bytes, salt.length, kCCPRFHmacAlgSHA1, nRounds, derivedKey.mutableBytes, derivedKey.length);
    
    return (retv == kCCSuccess) ? derivedKey : nil;
}

- (NSInteger)_cdo_numberOfRoundsForSalt:(NSData *)salt derivedKeyLength:(NSInteger)keyLength targetTimeInMilliseconds:(NSInteger)targetTime
{
    NSInteger totalRounds = 0;
    for (NSInteger i = 0; i < 10; i++) {
        totalRounds += CCCalibratePBKDF(kCCPBKDF2, [self lengthOfBytesUsingEncoding:NSUTF8StringEncoding], salt.length, kCCPRFHmacAlgSHA256, keyLength, targetTime);
    }
    return totalRounds / 10;
}


@end
