//
//  TCSMTConfirmationSMSBYIDViewController.m
//  TCSMT
//
//  Created by Max Zhdanov on 26.08.13.
//  Copyright (c) 2013 “Tinkoff Credit Systems” Bank (closed joint-stock company). All rights reserved.
//

#import "TCSMTConfirmationSMSBYIDViewController.h"
#import "TCSiCoreNetworking.h"
#import "TCSAPIClient+TCSAPIClient_CommonAPIRequests.h"
#import "TCSMacroses.h"
#import "TCSMTPinViewController.h"
#import "TCSTGTelegramMoneyTalkProxy.h"

#define kCodeLengthBackupForSMS	4
#define kSeparatorHeight 0.5f

@interface TCSMTConfirmationSMSBYIDViewController () <UITextFieldDelegate, UIAlertViewDelegate>

@property (nonatomic, assign) NSUInteger confirmationCodeLength;

@property (nonatomic, weak) IBOutlet UILabel *infoLabel;
@property (nonatomic, weak) IBOutlet UITextField *inputTextField;
@property (nonatomic, weak) IBOutlet UIButton *confirmationButton;
@property (weak, nonatomic) IBOutlet UILabel *phoneNumberLabel;

@property (nonatomic, strong) IBOutletCollection (NSLayoutConstraint) NSArray *separatorsHeightConstraints;

@end

@implementation TCSMTConfirmationSMSBYIDViewController
{
    NSCharacterSet *_symbolCharacterSet;
}

#pragma mark - Initial setup

- (void)setupWithParameters:(NSDictionary *)parameters
{
	[super setupWithParameters:parameters];

	self.confirmationCodeLength = [parameters[kCodeLength] unsignedIntegerValue];
}



#pragma mark - Getters

- (BOOL)canBeConfirmedWithPush
{
	return YES;
}


- (NSUInteger)confirmationCodeLength
{
	if (_confirmationCodeLength == 0)
	{
		_confirmationCodeLength = kCodeLengthBackupForSMS;
	}

	return _confirmationCodeLength;
}



#pragma mark - View Controller Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.infoLabel.text = LOC(@"SMS.CodeDescription");
    [self.confirmationButton setTitle:LOC(@"SMS.ResendCode") forState:UIControlStateNormal];
    [self.confirmationButton setTitleColor:[TCSTGTelegramMoneyTalkProxy tgAccentColor] forState:UIControlStateNormal];
    [self.inputTextField setPlaceholder:LOC(@"Login.Code")];

    _symbolCharacterSet = [NSCharacterSet decimalDigitCharacterSet].invertedSet;
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:LOC(@"Common.Cancel") style:UIBarButtonItemStylePlain target:self action:@selector(closeAction)];
    
    TGUser *selfUser = [TCSTGTelegramMoneyTalkProxy selfUser];
    [self.phoneNumberLabel setText:[TCSTGTelegramMoneyTalkProxy formatPhone:selfUser.phoneNumber forceInternational:true]];
}

- (void)viewDidLayoutSubviews
{
    for (NSLayoutConstraint *constraint in self.separatorsHeightConstraints)
    {
        [constraint setConstant:kSeparatorHeight];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController.navigationBar setTintColor:[TCSTGTelegramMoneyTalkProxy tgAccentColor]];
}

- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
    [self.inputTextField becomeFirstResponder];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(openKeyboardToEnterSMSCode) name:UIApplicationDidBecomeActiveNotification object:nil];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.view endEditing:YES];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidBecomeActiveNotification object:nil];
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(__unused UIAlertView *)alertView didDismissWithButtonIndex:(__unused NSInteger)buttonIndex
{
    [self openKeyboardToEnterSMSCode];
}


#pragma mark - UIActions

- (void)openKeyboardToEnterSMSCode
{
    [self.inputTextField becomeFirstResponder];
}

- (void)closeAction
{
	[NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(openKeyboardToEnterSMSCode) object:nil];
    
    [self.view endEditing:YES];
    
    if (self.dismissBlock)
    {
        self.dismissBlock();
    }
}

- (IBAction)confirmationButtonAction:(UIButton *)__unused sender
{
    if (self.inputTextField)
    {
        if (self.inputTextField.userInteractionEnabled)
        {
            self.inputTextField.text = [NSString new];
            
            [[TCSTGTelegramMoneyTalkProxy sharedInstance] showProgressWindowAnimated:YES];
            [[TCSAPIClient sharedInstance] api_resendSMSCodeForInitialOperationTicket:self.initialOperationTicket success:^
             {
                 [[TCSTGTelegramMoneyTalkProxy sharedInstance] dismissProgressWindowAnimated:YES];
             }
                                                                              failure:^(__unused NSError *error)
             {
                 [[TCSTGTelegramMoneyTalkProxy sharedInstance] dismissProgressWindowAnimated:YES];
                 
                 [TCSTGTelegramMoneyTalkProxy showAlertViewWithTitle:LOC(@"Error.ErrorTitle") message:error.userInfo[NSLocalizedDescriptionKey] cancelButtonTitle:nil okButtonTitle:LOC(@"OK") completionBlock:nil];
             }];
        }
        else
        {
            [self codeDidEntered:self.inputTextField.text];
        }
    }
}



#pragma mark - UITextFieldDelegate

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    BOOL result = YES;

    if ([string rangeOfCharacterFromSet:_symbolCharacterSet options:NSBackwardsSearch].location == NSNotFound)
    {

        NSString *newString = [textField.text stringByReplacingCharactersInRange:range withString:string];

        if (newString.length == _confirmationCodeLength)
        {
            [self codeDidEntered:newString];
            textField.text = newString;
            result = NO;
        }
        else if (newString.length > _confirmationCodeLength)
        {
            newString = [newString substringToIndex:_confirmationCodeLength];
            result = NO;
        }
    } else
    {
        result = NO;
    }

    return result;
}



#pragma mark TCSMTConfirmationSMSBYIDCellDelegate

- (void)codeDidEntered:(NSString *)code
{
    [[TCSTGTelegramMoneyTalkProxy sharedInstance] showProgressWindowAnimated:YES];
//    [self.inputTextField setUserInteractionEnabled:NO];
    
    __weak typeof(self) weakSelf = self;
    [[TCSAPIClient sharedInstance] api_confirmWithSMSCode:code initialOperation:self.initialOperation initialOperationTicket:self.initialOperationTicket confirmationType:self.confirmationType success:^(MKNetworkOperation *operation)
     {
         [[TCSTGTelegramMoneyTalkProxy sharedInstance] dismissProgressWindowAnimated:YES];
         
         [weakSelf confirmedWithOperation:operation];
     }
                                                  failure:^(__unused NSError *error)
     {
         [[TCSTGTelegramMoneyTalkProxy sharedInstance] dismissProgressWindowAnimated:YES];
//         [weakSelf.inputTextField setUserInteractionEnabled:YES];
         
         if ([error.userInfo[kResultCode] isEqualToString:kOPERATION_REJECTED])
         {
             [weakSelf closeAction];
         }
         else
         {
             [TCSTGTelegramMoneyTalkProxy showAlertViewWithTitle:LOC(@"Error.ErrorTitle") message:error.userInfo[TCSAPIKey_errorMessage] cancelButtonTitle:nil okButtonTitle:LOC(@"OK") completionBlock:^(bool okButtonPressed)
             {
                 if (okButtonPressed)
                 {
                     [self openKeyboardToEnterSMSCode];
                 }
             }];
         }
     }];
}



- (void)confirmedWithOperation:(MKNetworkOperation *)operation
{
    if (self.success)
    {
        self.success(operation);
    }
    
    [self.view endEditing:YES];
}


#ifdef SHOULD_GET_SMS_FROM_SERVER
- (void)getSMSCodeForTest
{
    __weak __typeof(self) weakSelf = self;
    [[TCSMTAPIClient sharedInstance] api_testRequestSMSCodeWithOperationTicket:self.initialOperationTicket confirmationType:self.confirmationType success:^(NSString *securityCode)
    {
        __strong __typeof(weakSelf) strongSelf = weakSelf;
        if (strongSelf)
        {
            UITextField *textField = strongSelf.inputTextField;
            if (textField)
            {
                textField.placeholder = securityCode;
            }
        }
    }
                                                                       failure:^(NSString *errorString)
    {
        NSLog(@"%@", errorString);
    }];
}
#endif

- (void)setCodeFromPush:(NSString *)code
{
    if (_confirmationCodeLength == code.length)
    {
        UITextField *textField = self.inputTextField;
        if (textField)
        {
            textField.text = code;
            textField.userInteractionEnabled = NO;

            UIButton *button = self.confirmationButton;
            if (button)
            {
                [UIView animateWithDuration:0.3 animations:^
                {
                    [button setTitle:LOC(@"title_confirm") forState:UIControlStateNormal];
                }];
            }
        }
    }
}

@end
