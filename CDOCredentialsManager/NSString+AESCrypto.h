//
//  NSString+AESCrypto.h
//  CDOCredentialsManager
//
//  Created by Norm Barnard on 5/12/14.
//  Copyright (c) 2014 Clamdango. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (AESCrypto)

- (NSData *)CDO_deriveAES128KeyWithSalt:(NSData *)salt;



@end
