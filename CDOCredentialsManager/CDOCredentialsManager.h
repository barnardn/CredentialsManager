//
//  CDOCredentialsManager.h
//  CDOCredentialsManager
//
//  Created by Norm Barnard on 5/5/14.
//  Copyright (c) 2014 Clamdango. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CDOCredentialsManager : NSObject

@property (strong, nonatomic, readonly) NSString *serviceName;


- (instancetype)initWithServiceName:(NSString *)serviceName;

- (BOOL)setCredentials:(NSString *)credentials forAccountName:(NSString *)accountName error:(NSError * __autoreleasing *)error;
- (NSString *)credentialsForAccountName:(NSString *)accountName;

- (void)purgeAllAccounts;
- (void)deleteCredentialsForAccountName:(NSString *)accountName;

- (NSArray *)allAccounts;

- (BOOL)importCredentialsFromKeymasterFileAtURL:(NSURL *)fileURL error:(NSError * __autoreleasing *)error;
- (BOOL)importCredentialsFromKeymasterFileAtURL:(NSURL *)fileURL key:(NSUUID *)cypherKey error:(NSError * __autoreleasing *)error;

@end
