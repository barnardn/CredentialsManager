//
//  CDOMainViewController.m
//  CDOCredentialsManager
//
//  Created by Norm Barnard on 5/19/14.
//  Copyright (c) 2014 Clamdango. All rights reserved.
//

#import "CDOCredentialsManager.h"
#import "CDOMainViewController.h"

@interface CDOMainViewController () <UIPickerViewDataSource, UIPickerViewDelegate>

@property (weak, nonatomic) IBOutlet UITextField *apiField;
@property (weak, nonatomic) IBOutlet UITextField *usernameField;
@property (weak, nonatomic) IBOutlet UITextField *passwordField;
@property (weak, nonatomic) IBOutlet UIPickerView *credentialSetPickerView;
@property (strong, nonatomic) CDOCredentialsManager *credentialsManager;
@property (strong, nonatomic) NSArray *accounts;

@end

@implementation CDOMainViewController

- (id)init
{
    self = [super init];
    if (!self) return nil;
    _credentialsManager = [[CDOCredentialsManager alloc] initWithServiceName:@"test-service"];
    return self;
}

- (NSString *)nibName
{
    return @"CDOMainView";
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.accounts = [self.credentialsManager allAccounts];
    [self _displayCredentialsForAccountName:[self.accounts firstObject]];
}

- (void)_displayCredentialsForAccountName:(NSString *)accountName
{
    NSString *json = [self.credentialsManager credentialsForAccountName:accountName];
    NSDictionary *credentials = [NSJSONSerialization JSONObjectWithData:[json dataUsingEncoding:NSUTF8StringEncoding] options:0 error:nil];
    self.apiField.text = credentials[@"api"];
    self.usernameField.text = credentials[@"username"];
    self.passwordField.text = credentials[@"password"];
}


#pragma mark - UIPickerView data source 

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}


- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return [self.accounts count];
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return self.accounts[row];
}

#pragma mark = UIPickerView delegate

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    [self _displayCredentialsForAccountName:self.accounts[row]];
}


@end
