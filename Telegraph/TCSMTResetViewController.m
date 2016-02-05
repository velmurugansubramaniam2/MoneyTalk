//
//  TCSMTResetViewController.m
//  Telegraph
//
//  Created by spb-EOrlova on 14.12.15.
//
//

#import "TCSMTResetViewController.h"
#import "TCSAPIClient+TCSAPIClient_CommonAPIRequests.h"
#import "TCSAuthorizationStateManager.h"
#import "TCSMTAccountGroupsDataController.h"
#import "TCSMTPinViewController.h"
#import "TCSMTConfirmationSMSBYIDViewController.h"
#import "TCSTGTelegramMoneyTalkProxy.h"
#import "TCSMacroses.h"

typedef enum
{
    TCSMTResetCellTypeChangePassword,
    TCSMTResetCellTypeResetSettings
} TCSMTResetCellType;


@interface TCSMTResetViewController ()
@property (nonatomic, strong) UITableViewCell *changePasswordCell;
@property (nonatomic, strong) UITableViewCell *resetSettingsCell;
@end

@implementation TCSMTResetViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = LOC(@"Reset.Title");
    
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:NSStringFromClass([UITableViewCell class])];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleShowConfirmationSMSViewController:) name:TCSNotificationShowConfirmationSMS object:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController.navigationBar setTintColor:[TCSTGTelegramMoneyTalkProxy tgAccentColor]];
}

- (UITableViewCell *)changePasswordCell
{
    if (!_changePasswordCell)
    {
        _changePasswordCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"changePasswordCell"];
        [_changePasswordCell.textLabel setText:LOC(@"Reset.ChangePassword")];
    }
    
    return _changePasswordCell;
}

- (UITableViewCell *)resetSettingsCell
{
    if (!_resetSettingsCell)
    {
        _resetSettingsCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"resetSettingsCell"];
        [_resetSettingsCell.textLabel setText:LOC(@"Reset.ResetSettings")];
    }
    
    return _resetSettingsCell;
}



#pragma mark - UITableViewDatasource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.row)
    {
        case TCSMTResetCellTypeChangePassword:
        {
            return self.changePasswordCell;
        }
            break;
        case TCSMTResetCellTypeResetSettings:
        {
            return self.resetSettingsCell;
        }
            break;
    }
    
    return nil;
}


#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    switch (indexPath.row)
    {
        case TCSMTResetCellTypeChangePassword:
        {
            [self changePassword];
        }
            break;
        case TCSMTResetCellTypeResetSettings:
        {
            [self resetSettings];
        }
            break;
    }
}

#pragma mark - Reset settings

- (void)resetSettings
{
    NSNotificationCenter *defaultCenter = [NSNotificationCenter defaultCenter];
    TCSAuthorizationState currentAuthorizationState = [[TCSAuthorizationStateManager sharedInstance] currentAuthorizationState];
    
    void (^authentiationSuccess)() = ^
    {
        void (^success)() = ^
        {
            [defaultCenter postNotificationName:TCSNotificationAccountResetActionPerformed object:nil];
            [[TCSMTAccountGroupsDataController sharedInstance] clearData];
        };
        
        void (^failure)(NSError *) = ^(NSError *error)
        {
            [[[UIAlertView alloc] initWithTitle:@"Error" message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
        };

        [[TCSAPIClient sharedInstance] api_resetWalletSuccess:success failure:failure];
    };

    [self showPinViewControllerWithState:TCSMTPinControllerStateAuthorization authorizationState:currentAuthorizationState andSuccessBlock:authentiationSuccess];
}

#pragma mark - Change password

- (void)changePassword
{
    TCSAuthorizationState currentAuthorizationState = [[TCSAuthorizationStateManager sharedInstance] currentAuthorizationState];
    
    __weak typeof(self) weakSelf = self;
    void (^successBlock)() = ^
    {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (strongSelf)
        {
            [strongSelf showPinViewControllerWithState:TCSMTPinControllerStateSetCode authorizationState:TCSAuthorizationStateSetPinCode andSuccessBlock:^
             {
                 [strongSelf.navigationController dismissViewControllerAnimated:YES completion:nil];
             }];
        }
    };
    
    [self showPinViewControllerWithState:TCSMTPinControllerStateAuthorization authorizationState:currentAuthorizationState andSuccessBlock:successBlock];
}

- (void)showPinViewControllerWithState:(TCSMTPinControllerState)pinState authorizationState:(TCSAuthorizationState)state andSuccessBlock:(void(^)(void))successBlock
{
    TCSMTPinViewController *pinViewController = [TCSMTPinViewController new];
    pinViewController.state = pinState;
    
    if (successBlock)
    {
        pinViewController.successBlock = successBlock;
    }
    pinViewController.successBlock = successBlock;
    
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:pinViewController];
    
    if (state == TCSAuthorizationStateNotDetermined)
    {
        [self.navigationController presentViewController:navigationController animated:YES completion:nil];
    }
    else if (state == TCSAuthorizationStateSessionIsRelevant)
    {
        if (pinState == TCSMTPinControllerStateAuthorization ||
            pinState == TCSMTPinControllerStateCheckUser)
        {
            [self.navigationController presentViewController:navigationController animated:YES completion:nil];
        }
    }
    else if (state == TCSAuthorizationStateSetPinCode)
    {
        if (pinState == TCSMTPinControllerStateSetCode)
        {
            [(UINavigationController *)(self.navigationController.presentedViewController) pushViewController:pinViewController animated:YES];
        }
    }
}

#pragma mark - Handle Notifications

- (void)handleShowConfirmationSMSViewController:(NSNotification *)__unused notification
{
    TCSMTConfirmationSMSBYIDViewController *confirmationSMSViewController = [[TCSMTConfirmationSMSBYIDViewController alloc] init];
    
    __weak typeof(self) weakSelf = self;
    [confirmationSMSViewController setDismissBlock:^
    {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (strongSelf)
        {
            [strongSelf.navigationController dismissViewControllerAnimated:YES completion:nil];
        }
    }];
    
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:confirmationSMSViewController];
    [confirmationSMSViewController setupWithParameters:notification.userInfo];
    [(UINavigationController *)self.navigationController.presentedViewController presentViewController:navigationController animated:YES completion:nil];
}


@end
