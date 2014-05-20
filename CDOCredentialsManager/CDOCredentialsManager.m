//
//  CDOCredentialsManager.m
//  CDOCredentialsManager
//
//  Created by Norm Barnard on 5/5/14.
//  Copyright (c) 2014 Clamdango. All rights reserved.
//

#import <SSKeychain/SSKeychain.h>

#import "CDOCredentialsManager.h"
#import "NSData+AES128Crypto.h"

static NSString * const kErrorDomain = @"com.clamdango.cdocredentialsmanager";
static NSString * const kKeymasterCypherKeyKey = @"cypherKey";
static NSString * const kKeymasterCypherTextKey = @"cypherText";


@interface CDOCredentialsManager()

@property (strong, nonatomic, readwrite) NSString *serviceName;

@end


@implementation CDOCredentialsManager


- (instancetype)initWithServiceName:(NSString *)serviceName
{
    self = [super init];
    if (!self) return nil;
    _serviceName = serviceName;
    return self;
}


#pragma mark - public api methods

- (BOOL)setCredentials:(NSString *)credentials forAccountName:(NSString *)accountName error:(NSError * __autoreleasing *)error;
{
    BOOL ok = [SSKeychain setPassword:credentials forService:self.serviceName account:accountName error:error];
    return ok;
}

- (NSString *)credentialsForAccountName:(NSString *)accountName;
{
    return [SSKeychain passwordForService:self.serviceName account:accountName];
}

- (NSArray *)allAccounts;
{
    NSArray *accounts = [SSKeychain allAccounts];
    NSMutableArray *accountNames = [NSMutableArray arrayWithCapacity:accounts.count];
    for (NSDictionary *ci in accounts) {
        [accountNames addObject:ci[kSSKeychainAccountKey]];
    }
    return accountNames;
}

- (void)purgeAllAccounts
{
    NSArray *accounts = [self allAccounts];
    [accounts enumerateObjectsUsingBlock:^(NSDictionary *acct, NSUInteger idx, BOOL *stop) {

        [self deleteCredentialsForAccountName:acct[kSSKeychainAccountKey]];
        
    }];
}

- (void)deleteCredentialsForAccountName:(NSString *)accountName
{
    
    [SSKeychain deletePasswordForService:self.serviceName account:accountName];
    
}



- (BOOL)importCredentialsFromKeymasterFileAtURL:(NSURL *)fileURL error:(NSError * __autoreleasing *)error;
{

    NSDictionary *json = [self _deserializeKeymasterFileAtURL:fileURL embeddedKey:YES error:error];
    if (!json) return NO;
    
    NSUUID *uuidKey = [[NSUUID alloc] initWithUUIDString:json[kKeymasterCypherKeyKey]];
    
    NSString *cypherText = [json[kKeymasterCypherTextKey] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSData *cypherData = [[NSData alloc] initWithBase64EncodedString:cypherText options:0];
    if (!cypherData) {
        *error = [NSError errorWithDomain:kErrorDomain code:1001 userInfo:@{ NSLocalizedDescriptionKey : NSLocalizedString(@"Bad or missing cypher data", @"bad or missing cypher data error message")}];
        return NO;
    }
    return [self _importCredentialsData:cypherData usingKey:uuidKey error:error];
}

- (BOOL)importCredentialsFromKeymasterFileAtURL:(NSURL *)fileURL key:(NSUUID *)cypherKey error:(NSError * __autoreleasing *)error;
{

    NSDictionary *json = [self _deserializeKeymasterFileAtURL:fileURL embeddedKey:YES error:error];
    if (!json) return NO;

    NSString *cypherText = [json[kKeymasterCypherTextKey] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSData *cypherData = [[NSData alloc] initWithBase64EncodedString:cypherText options:0];
    if (!cypherData) {
        *error = [NSError errorWithDomain:kErrorDomain code:1001 userInfo:@{ NSLocalizedDescriptionKey : NSLocalizedString(@"Bad or missing cypher data", @"bad or missing cypher data error message")}];
        return NO;
    }
    return [self _importCredentialsData:cypherData usingKey:cypherKey error:error];
    
    return YES;
}


#pragma mark - private methods


- (NSDictionary *)_deserializeKeymasterFileAtURL:(NSURL *)url embeddedKey:(BOOL)embeddedKey error:(NSError * __autoreleasing *)error;
{
    if (![url checkResourceIsReachableAndReturnError:error]) return nil;
    
    NSData *keymasterData = [NSData dataWithContentsOfURL:url];
    NSDictionary *keymasterJson = [NSJSONSerialization JSONObjectWithData:keymasterData options:0 error:error];
    if (*error) return nil;
    if (embeddedKey) {
        if (!keymasterJson[kKeymasterCypherKeyKey]) {
            *error = [NSError errorWithDomain:kErrorDomain code:1001 userInfo:@{ NSLocalizedDescriptionKey : NSLocalizedString(@"Invalid keymaster credential format, missing 'cypherKey'", @"bad or missing cypherkey key message")}];
            return NO;
        }
    }
    if (!keymasterJson[kKeymasterCypherTextKey]) {
        *error = [NSError errorWithDomain:kErrorDomain code:1001 userInfo:@{ NSLocalizedDescriptionKey : NSLocalizedString(@"Invalid keymaster credential format, missing 'cypherText'", @"bad or missing cypherText key message")}];
        return NO;
    }
    return keymasterJson;
}


- (BOOL)_importCredentialsData:(NSData *)encryptedData usingKey:(NSUUID *)key error:(NSError * __autoreleasing *)error;
{
    uuid_t rawUUID;
    [key getUUIDBytes:rawUUID];
    NSData *decrypted = [encryptedData CDO_decryptAES128WithKey:(unsigned char *)rawUUID initVector:(unsigned char *)rawUUID];
    
    // * jockey the bytes to a string and back to strip out trailing nulls - they cause the json serializer to hork!
    NSString *s = [NSString stringWithUTF8String:decrypted.bytes];
    NSData *d = [s dataUsingEncoding:NSUTF8StringEncoding];
    
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:d options:NSJSONReadingAllowFragments error:error];
    if (*error) return NO;

    [json enumerateKeysAndObjectsUsingBlock:^(NSString *accountKey, NSString *credString, BOOL *stop) {
        [self setCredentials:credString forAccountName:accountKey error:error];
        if (*error) *stop = YES;
    }];
    return (*error == nil);
}




@end
