//
//  NSData+AES128Crypto.h
//  CDOCredentialsManager
//
//  Created by Norm Barnard on 5/5/14.
//  Copyright (c) 2014 Clamdango. All rights reserved.
//
//  Based on the work described by Rob Napier : http://robnapier.net/aes-commoncrypto/ 

#import <Foundation/Foundation.h>

@interface NSData (AES128Crypto)

- (NSData *)CDO_encryptAES128WithKey:(unsigned char *)key initVector:(unsigned char *)initVector;
- (NSData *)CDO_decryptAES128WithKey:(unsigned char *)key initVector:(unsigned char *)initVector;
+ (NSData *)CDO_randomBytesOfLength:(NSInteger)length;

@end
