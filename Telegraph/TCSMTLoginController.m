//
//  TCSMTLoginController.m
//  Telegraph
//
//  Created by spb-EOrlova on 21.12.15.
//
//

#import "TCSMTLoginController.h"
#import "TCSMTSignUpController.h"
#import "TCSMTAccountGroupsDataController.h"

#import "TCSMTPinViewController.h"
#import "TCSMTConfirmationSMSBYIDViewController.h"
#import "TCSTGTelegramMoneyTalkProxy.h"

#import <LocalAuthentication/LocalAuthentication.h>

#import "TCSMTLocalConstants.h"
#import "TCSMacroses.h"

@interface TCSMTLoginController ()
@property (nonatomic, strong, readwrite) UIViewController *fromViewController;
@property (nonatomic, strong, readwrite) UIViewController *destinationViewController;
@end

@implementation TCSMTLoginController
{
    TCSMTSignUpController *_signUpController;
}


#pragma mark - Singleton

+ (instancetype)sharedInstance
{
    static TCSMTLoginController *_sharedInstance = nil;
    static dispatch_once_t oncePredicate;
    
    dispatch_once(&oncePredicate, ^
    {
        _sharedInstance = [[TCSMTLoginController alloc] init];
    });
    
    return _sharedInstance;
}

#pragma mark - Init

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        [self registerForNotifications];
        _signUpController = [[TCSMTSignUpController alloc] init];
    }
    
    return self;
}

- (void)showViewController:(UIViewController *)destinationViewController
        fromViewController:(UIViewController *)fromViewController
{
    [self setFromViewController:fromViewController];
    [self setDestinationViewController:destinationViewController];
    
    [self performLogin];
}

- (void)performLogin
{
    TCSAuthorizationState currentState = [TCSAuthorizationStateManager sharedInstance].currentAuthorizationState;
    [[TCSAuthorizationStateManager sharedInstance] setStateChangedBlock:[self createAuthorizationStateChangedBlock]];
    
    switch (currentState)
    {
        case TCSAuthorizationStateNoSession:
        {
            [[TCSTGTelegramMoneyTalkProxy sharedInstance] showProgressWindowAnimated:YES];
            __weak typeof(self) weakSelf = self;
            [_signUpController performSignUpWithCompletion:^(NSError *error)
             {
                 __strong typeof(weakSelf) strongSelf = weakSelf;
                 if (strongSelf)
                 {
                     [[TCSTGTelegramMoneyTalkProxy sharedInstance] dismissProgressWindowAnimated:YES];;
                     
                     if (error)
                     {
                         [TCSTGTelegramMoneyTalkProxy showAlertViewWithTitle:LOC(@"Error.ErrorTitle") message:error.userInfo[TCSAPIKey_errorMessage] cancelButtonTitle:nil okButtonTitle:LOC(@"OK") completionBlock:nil];
                     }
                     else
                     {
                         [strongSelf enableTouchIdAuthorization];
                     }
                 }
             }];
        }
            break;
        case TCSAuthorizationStateSessionExpiredPinAuth:
        {
            TCSMTPinViewController *pinViewController = [[TCSMTPinViewController alloc] init];
            pinViewController.state = TCSMTPinControllerStateAuthorization;
            
            __weak typeof(self) weakSelf = self;
            [pinViewController setSuccessBlock:^
             {
                 __strong typeof(weakSelf) strongSelf = weakSelf;
                 if (strongSelf)
                 {
                     [[TCSMTAccountGroupsDataController sharedInstance] updateAccountsAndPerformBlockWithAccountsGroupsList:^(__unused TCSAccountGroupsList *accountGroupsList)
                      {
                          __strong typeof(weakSelf) strongSelf1 = weakSelf;
                          if (strongSelf1)
                          {
                              [strongSelf openDestinationViewControllerViewController];
                          }
                      }];
                 }
             }];
            
            UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:pinViewController];
            navigationController.modalPresentationStyle = UIModalPresentationFormSheet;
            [self.fromViewController presentViewController:navigationController animated:YES completion:nil];
        }
            break;
        case TCSAuthorizationStateSessionIsRelevant:
        {
            [self openDestinationViewControllerViewController];
        }
            break;
            
        default:
            break;
    }
}

- (StateChangedBlock)createAuthorizationStateChangedBlock
{
    __weak typeof(self) weakSelf = self;
    StateChangedBlock stateChangedBlock = ^(TCSAuthorizationState stateOld, TCSAuthorizationState stateNew)
    {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if ((stateNew == TCSAuthorizationStateSessionExpiredPinAuth && stateOld == TCSAuthorizationStateSessionIsRelevant) || stateOld == TCSAuthorizationStateNoSession)
        {
            [strongSelf.fromViewController dismissViewControllerAnimated:YES completion:^
             {
                 TCSMTPinViewController *pinViewController = [[TCSMTPinViewController alloc] init];
                 pinViewController.state = stateOld == TCSAuthorizationStateNoSession ? TCSMTPinControllerStateSetCode : TCSMTPinControllerStateAuthorization;
                 
                 [pinViewController setSuccessBlock:^
                 {
                     [[TCSMTAccountGroupsDataController sharedInstance] updateAccountsAndPerformBlockWithAccountsGroupsList:^(__unused TCSAccountGroupsList *accountGroupsList)
                      {
                          __strong typeof(weakSelf) strongSelf1 = weakSelf;
                          if (strongSelf1)
                          {
                              [strongSelf1 openDestinationViewControllerViewController];
                          }
                      }];
                  }];
                 
                 UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:pinViewController];
                 navigationController.modalPresentationStyle = UIModalPresentationFormSheet;
                 [strongSelf.fromViewController presentViewController:navigationController animated:YES completion:nil];
             }];
        }
        else if (stateNew == TCSAuthorizationStateNoSession && stateOld == TCSAuthorizationStateSessionIsRelevant)
        {
            [strongSelf.fromViewController dismissViewControllerAnimated:YES completion:nil];
        }
    };
    
    return stateChangedBlock;
}

- (void)openDestinationViewControllerViewController
{
    if (self.fromViewController.presentedViewController)
    {
        __weak typeof(self) weakSelf = self;
        [self.fromViewController dismissViewControllerAnimated:YES completion:^
         {
             __strong typeof(weakSelf) strongSelf = weakSelf;
             if (strongSelf)
             {
                 [strongSelf.fromViewController presentViewController:strongSelf.destinationViewController animated:YES completion:nil];
             }
         }];
    }
    else
    {
        [self.fromViewController presentViewController:self.destinationViewController animated:YES completion:nil];
    }
}

#pragma mark - TouchID

- (void)enableTouchIdAuthorization
{
    LAContext *context = [LAContext new];
    NSError *error = nil;
    
    if ([context canEvaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics error:&error])
    {
        NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
        [standardUserDefaults setObject:@YES forKey:kIsFingerAuthOn];
        [standardUserDefaults synchronize];
    }
}

#pragma mark - Notifications

- (void)registerForNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleShowConfirmationSMSNotification:)
                                                 name:TCSNotificationShowConfirmationSMS
                                               object:nil];
}

- (void)handleShowConfirmationSMSNotification:(NSNotification *)notification
{
    [[TCSTGTelegramMoneyTalkProxy sharedInstance] dismissProgressWindowAnimated:YES];

    TCSMTConfirmationSMSBYIDViewController *confirmationSMSViewController = [[TCSMTConfirmationSMSBYIDViewController alloc] init];
    [confirmationSMSViewController setupWithParameters:notification.userInfo];
    __weak typeof(self) weakSelf = self;
    [confirmationSMSViewController setDismissBlock:^
     {
         __strong typeof(weakSelf)strongSelf = weakSelf;
         if (strongSelf)
         {
             [strongSelf.fromViewController dismissViewControllerAnimated:YES completion:nil];
         }
     }];
    
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:confirmationSMSViewController];
    [self.fromViewController presentViewController:navigationController animated:YES completion:nil];
}

@end
