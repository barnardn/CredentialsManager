//
//  CDOCredentialsManagerTests.m
//  CDOCredentialsManagerTests
//
//  Created by Norm Barnard on 5/5/14.
//  Copyright (c) 2014 Clamdango. All rights reserved.
//

#import "CDOCredentialsManager.h"
#import "NSData+AES128Crypto.h"
#import "NSString+AESCrypto.h"
#import <XCTest/XCTest.h>

@interface CDOCredentialsManagerTests : XCTestCase

@end

@implementation CDOCredentialsManagerTests

- (void)setUp
{
    [super setUp];
}

- (void)tearDown
{
    [super tearDown];
}


- (void)testDecrypt
{
    NSURL *testURL = [[NSBundle bundleForClass:[self class]] URLForResource:@"test-crypto" withExtension:@"json"];
    XCTAssert(testURL != nil, @"Bah testurl is nil");
 
    CDOCredentialsManager *cm = [[CDOCredentialsManager alloc] initWithServiceName:@"test-service"];
    NSArray *accounts = @[@"staging", @"production", @"development"];
    [accounts enumerateObjectsUsingBlock:^(NSString *acctName, NSUInteger idx, BOOL *stop) {
        
        NSString *credentials = [cm credentialsForAccountName:acctName];
        XCTAssertNil(credentials, @"Credentials for %@ was %@ not nil", acctName, credentials);
        
    }];
        
    NSError *error;
    BOOL ok = [cm importCredentialsFromKeymasterFileAtURL:testURL error:&error];
    XCTAssert(ok, @"Import failed: %@", error);
}

- (void)testGetAccount
{
    NSArray *accounts = @[@"staging", @"production", @"development"];
    CDOCredentialsManager *cm = [[CDOCredentialsManager alloc] initWithServiceName:@"test-service"];
    [accounts enumerateObjectsUsingBlock:^(NSString *acctName, NSUInteger idx, BOOL *stop) {
        NSString *credentials = [cm credentialsForAccountName:acctName];
        XCTAssert(credentials.length > 0, @"No credentials founds for account %@", acctName);
        NSError *error;
        NSDictionary *credJson = [NSJSONSerialization JSONObjectWithData:[credentials dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingAllowFragments error:&error];
        XCTAssert(error == nil, @"Unable to decode credentials json: %@", error);
        NSLog(@"credentials json: %@", credJson);
    }];
    
    [cm purgeAllAccounts];
    
    
}

- (void)testEncrypt
{
    NSString *plainText = @"Id quod mazim placerat facer possim assum typi non habent claritatem? Humanitatis per seacula quarta decima et quinta decima eodem modo typi qui nunc nobis videntur parum.";
    
    NSString *key = @"SuperPasssword";
    NSData *salt = [NSData CDO_randomBytesOfLength:8];
    XCTAssert(salt != nil, @"salt failed");
    NSData *derivedKey = [key CDO_deriveAES128KeyWithSalt:salt];
    XCTAssert(derivedKey != nil, @"derived key failed");
    NSData *initVector = [NSData CDO_randomBytesOfLength:16];
    XCTAssert(initVector != nil, @"salt failed");
    NSData *cryptData = [[plainText dataUsingEncoding:NSUTF8StringEncoding] CDO_encryptAES128WithKey:(unsigned char *)derivedKey.bytes initVector:(unsigned char *)initVector.bytes];
    XCTAssertNotNil(cryptData, @"crypt data is nil");
    NSData *decrypted = [cryptData CDO_decryptAES128WithKey:(unsigned char *)derivedKey.bytes initVector:(unsigned char *)initVector.bytes];
    XCTAssertNotNil(decrypted, @"decrypted data is nil");
    NSString *testText = [[NSString alloc] initWithData:decrypted encoding:NSUTF8StringEncoding];
    
    XCTAssert([plainText isEqualToString:testText], @"string decrypted to %@", testText);
}



@end
