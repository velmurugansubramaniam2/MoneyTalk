//
//  TCSMTSettingsTableViewController.m
//  MT
//
//  Created by Andrey Ilskiy on 06/10/14.
//  Copyright (c) 2014 “Tinkoff Credit Systems” Bank (closed joint-stock company). All rights reserved.
//

#import "TCSMTSettingsTableViewController.h"

//@import AssetsLibrary;

#import "TCSMTAccountGroupsDataController.h"
#import "TCSMTCardsViewsController.h"
#import "TCSMTConfigManager.h"

#import "TCSMTSwitchCellTableViewCell.h"

#import <LocalAuthentication/LocalAuthentication.h>

#import "UIDevice+Helpers.h"

#import "TCSAPIClient.h"

#import "TCSMacroses.h"

#import "TCSMTLocalConstants.h"
#import "TCSMTResetViewController.h"

#import "TCSUtils.h"
#import "TCSMTConfigManager.h"
#import "TCSTGTelegramMoneyTalkProxy.h"


@interface TCSMTSettingsTableViewController () <UIAlertViewDelegate, UIActionSheetDelegate>

@property (nonatomic, strong) UITableViewCell *mainCardCell;
//@property (nonatomic, weak) IBOutlet TCSMTActivityIndicatorView *activityIndicatorView;
@property (strong, nonatomic) UITableViewCell *helpTableViewCell;
@property (nonatomic, strong) UITableViewCell *resetCell;
@property (nonatomic, strong) UITableViewCell *ofertaCell;
@property (nonatomic, strong) TCSMTSwitchCellTableViewCell *touchIDCell;

@property (nonatomic, strong) IBInspectable UIImage *visaImage;
@property (nonatomic, strong) IBInspectable UIImage *masterCardImage;
@property (nonatomic, strong) IBInspectable UIImage *maestroImage;

@property (weak, nonatomic) IBOutlet UILabel *resetLabel;
@property (weak, nonatomic) IBOutlet UILabel *helpLabel;
@property (weak, nonatomic) IBOutlet UILabel *feedbackLabel;
@property (weak, nonatomic) IBOutlet UILabel *aboutLabel;

- (void)updateMainCardInfo;

@end

@implementation TCSMTSettingsTableViewController
{
//    TCSMTAccountGroupsDataController *_sharedAccountGroupsDataController;
//    TCSCard *_primaryCardNumber;
    NSUserDefaults *_standardUserDefaults;
//    UIImage *_addCardImage;
}

@synthesize visaImage = _visaImage;
@synthesize masterCardImage = _masterCardImage;
@synthesize maestroImage = _maestroImage;

#pragma mark -
#pragma mark - Getters

- (UITableViewCell *)mainCardCell
{
    if (!_mainCardCell)
    {
        _mainCardCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"mainCardCell"];
        _mainCardCell.textLabel.text = LOC(@"Settings.Card");
        [_mainCardCell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
    }
    
    return _mainCardCell;
}

- (UITableViewCell *)resetCell
{
    if (!_resetCell)
    {
        _resetCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"resetCell"];
        _resetCell.textLabel.text = LOC(@"Settings.Reset");
    }
    
    return _resetCell;
}

- (UITableViewCell *)ofertaCell
{
    if (!_ofertaCell)
    {
        _ofertaCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"ofertaCell"];
        _ofertaCell.textLabel.text = LOC(@"Oferta.Oferta");
    }
    
    return _ofertaCell;
}

- (TCSMTSwitchCellTableViewCell *)touchIDCell
{
    if (!_touchIDCell)
    {
        _touchIDCell = [TCSMTSwitchCellTableViewCell newCell];
        _touchIDCell.titleLabel.text = LOC(@"Settings.TouchID");
        [_touchIDCell.switchItem addTarget:self action:@selector(onTouchIDSwitchChangeValueChangedAction:) forControlEvents:UIControlEventValueChanged];
    }
    
    return _touchIDCell;
}




#pragma mark - 
#pragma mark - View Controller Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = LOC(@"Settings.MoneyTalk.Title");

//    _sharedAccountGroupsDataController = TCSMTAccountGroupsDataController.sharedInstance;
//    
//    if (_sharedAccountGroupsDataController)
//    {
//        [self registerForNotifications];
//    }
//
//    [self handleDataSourceUpdate:nil];
//
//    [_sharedAccountGroupsDataController requestDataFromServer];
    
    [self setupTouchIDCell];
    
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithTitle:LOC(@"Common.Done") style:UIBarButtonItemStyleDone target:self action:@selector(cancelAction)];
    [self.navigationItem setRightBarButtonItem:doneButton];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController.navigationBar setTintColor:[TCSTGTelegramMoneyTalkProxy tgAccentColor]];
    
    [self.tableView reloadData];
}

- (void)dealloc
{
//    [self unregisterFromNotifications];
    [_standardUserDefaults synchronize];
}

- (void)cancelAction
{
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}




#pragma mark -
#pragma mark - Updates

//- (void)updateMainCardInfo
//{
//    if (_primaryCardNumber)
//    {
//        NSString *value = _primaryCardNumber.value;
//        TCSMTCardTableViewCell *cell = _mainCardCell;
//        if (cell && value && value.length > 0)
//        {
//            cell.cardNameLabel.text = [NSString stringWithFormat:@"%@ %@", _primaryCardNumber.lcsCardInfo.bankName,_primaryCardNumber.numberExtraShort];
//            
//            NSString *cardTypeImageString = nil;
//            
//            switch ([TCSUtils cardTypeByCardNumberString:value])
//            {
//                case TCSP2PCardTypeVisa:
//                {
//                    cardTypeImageString = @"psIconVisa";
//                }
//                    break;
//                case TCSP2PCardTypeMasterCard:
//                {
//                    cardTypeImageString = @"psIconMastercard";
//                }
//                    break;
//                case TCSP2PCardTypeMaestro:
//                {
//                    cardTypeImageString = @"psIconMaestro";
//                }
//                    break;
//
//                default:
//                    NSAssert(false, @"Invalid card type - should never be reached");
//                    break;
//            }
//            
//            cell.paymentSystemLogoImageView.image = [UIImage imageNamed:cardTypeImageString];
//        }
//    }
//    
//    if (_sharedAccountGroupsDataController.groupsList.externalCards.count > 1)
//    {
//        [self.mainCardCell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
//        [self.mainCardCell setSelectionStyle:UITableViewCellSelectionStyleDefault];
//    }
//    else
//    {
//        [self.mainCardCell setAccessoryType:UITableViewCellAccessoryNone];
//        [self.mainCardCell setSelectionStyle:UITableViewCellSelectionStyleNone];
//    }
//}

- (void)setupTouchIDCell
{
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    BOOL isFingerAuthOn = [[prefs objectForKey:kIsFingerAuthOn] boolValue];
    
    [self.touchIDCell.switchItem setOn:isFingerAuthOn];
}





#pragma mark - 
#pragma mark - Touch ID

- (BOOL)isSystemTouchIdOn
{
    LAContext *myContext = [[LAContext alloc] init];
    NSError *authError = nil;
    
    if ([myContext canEvaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics error:&authError])
    {
        return YES;
    }
    else
    {
        return NO;
    }
}

- (void)onTouchIDSwitchChangeValueChangedAction:(id)sender
{
    UISwitch *switchView = sender;
    
    if (switchView.isOn)
    {
        if ([self isSystemTouchIdOn])
        {
            [self turnTouchIDOn:YES];
        }
        else
        {
            [[[UIAlertView alloc] initWithTitle:nil
                                        message:[NSString stringWithFormat:@"%@\n%@",LOC(@"TurnOnTouchID.Suggest.Line1"), LOC(@"TurnOnTouchID.Suggest.Line2")]
                                       delegate:nil
                              cancelButtonTitle:LOC(@"TurnOnTouchID.Suggest.Ok")
                              otherButtonTitles:nil, nil] show];
            
            [switchView setOn:NO animated:YES];
        }
    }
    else
    {
        [self turnTouchIDOn:NO];
    }
}

- (void)turnTouchIDOn:(BOOL)isON
{
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    
    [prefs setObject:[NSNumber numberWithBool:isON] forKey:kIsFingerAuthOn];
    
    if (isON)
    {
        [prefs setObject:@YES forKey:kIsNotFirstLaunchOnIOS8];
    }
    
    [prefs synchronize];
}


#pragma mark -
#pragma mark UITableViewDatasource

- (BOOL)isDeviceInDevicesList:(NSArray *)supportedDevices
{
    NSString *machineName = [UIDevice deviceModelName];
    
    for (NSString *deviceModelSubstring in supportedDevices)
    {
        if ([machineName rangeOfString:deviceModelSubstring].location != NSNotFound)
        {
            return YES;
        }
    }
    
    return NO;
}

- (BOOL)shouldShowTouchIdCell
{
    if ([[UIDevice deviceOS] doubleValue] >= 8)
    {
        NSArray *devicesWithTID = [[[TCSMTConfigManager sharedInstance] config] mtTouchIdDevices];
        
        return [self isDeviceInDevicesList:devicesWithTID];
    }
    
    return NO;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section)
    {
        case 0:
            return [[[TCSMTAccountGroupsDataController sharedInstance] groupsList]externalCards].count > 0 ? 1 : 0;
            break;
            
            
        case 1:
        {
            if ([self shouldShowTouchIdCell])
            {
                return 1;
            }
            
            return 0;
        }
            break;
            
        case 2:
            return 2;
            break;
            
        default:
            return 0;
            break;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section)
    {
        case 0:
        {
//            if (_sharedAccountGroupsDataController.groupsList.externalCards.count > 1)
//            {
//                [self.mainCardCell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
//                [self.mainCardCell setSelectionStyle:UITableViewCellSelectionStyleDefault];
//            }
//            else
//            {
//                [self.mainCardCell setAccessoryType:UITableViewCellAccessoryNone];
//                [self.mainCardCell setSelectionStyle:UITableViewCellSelectionStyleNone];
//            }
            
            return self.mainCardCell;
        }
            break;
            
            
        case 1:
        {
            if ([self shouldShowTouchIdCell])
            {
                return self.touchIDCell;
            }
        }
            break;
            
        case 2:
            switch (indexPath.row)
        {
            case 0:
                return self.ofertaCell;
                break;
            case 1:
                return self.resetCell;
                break;
        }
            break;
            
        default:
            return nil;
            break;
    }
    
    return nil;
}




#pragma mark -
#pragma mark UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 0)
    {
        if ([[[TCSMTAccountGroupsDataController sharedInstance] groupsList]externalCards].count == 0)
        {
            return 0.01f;
        }
    }
    else if (section == 1)
    {
        if (![self shouldShowTouchIdCell])
        {
            return 0.01f;
        }
    }
    
    return [super tableView:tableView heightForHeaderInSection:section];
}

//- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
//{
//    if (section == 0)
//    {
//        if ([[[TCSMTAccountGroupsDataController sharedInstance] groupsList]externalCards].count == 0)
//        {
//            return 0.01f;
//        }
//    }
//    else if (section == 1)
//    {
//        if (![self shouldShowTouchIdCell])
//        {
//            return 0.01f;
//        }
//    }
//    
//    return [super tableView:tableView heightForHeaderInSection:section];
//}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    
    if ([cell isEqual:self.resetCell])
    {
        TCSMTResetViewController *resetViewController = [TCSMTResetViewController new];
        [self.navigationController pushViewController:resetViewController animated:YES];
    }
    else if ([cell isEqual:self.mainCardCell])
    {
//        if (_sharedAccountGroupsDataController.groupsList.externalCards.count > 1)
        {
            TCSMTCardsViewsController *vc = [[TCSMTCardsViewsController alloc] initWithStyle:UITableViewStyleGrouped];
            [self.navigationController pushViewController:vc animated:YES];
        }
    }
    else if ([cell isEqual:self.ofertaCell])
    {
        [self openOfertaActionSheet];
    }
}

- (void)openOfertaActionSheet
{
    TGActionSheetAction *ofertaAction = [TCSTGTelegramMoneyTalkProxy tgActionSheetActionWithTitle:LOC(@"Oferta.Oferta")  action:@"oferta"];
    TGActionSheetAction *transfersConditionsAction = [TCSTGTelegramMoneyTalkProxy tgActionSheetActionWithTitle:LOC(@"Oferta.TransferConditions") action:@"transferConditions"];
    TGActionSheetAction *cancelAction = [TCSTGTelegramMoneyTalkProxy tgActionSheetActionWithTitle:LOC(@"Common.Cancel") action:@"cancel" type:TGActionSheetActionTypeCancel];
    
    NSArray *actions = @[ofertaAction, transfersConditionsAction, cancelAction];
    
    TGActionSheet *actionSheet = [TCSTGTelegramMoneyTalkProxy tgActionSheetWithTitle:nil
                                                                            actions:actions
                                                                        actionBlock:^(__unused TCSMTSettingsTableViewController *controller, NSString *action)
                                  {
                                      if ([action isEqualToString:@"oferta"])
                                      {
                                          NSURL *url = [NSURL URLWithString:[[[TCSMTConfigManager sharedInstance] config] ofertaUrl]];
                                          [[UIApplication sharedApplication] openURL:url];
                                      }
                                      else if ([action isEqualToString:@"transferConditions"])
                                      {
                                          NSURL *url = [NSURL URLWithString:[[[TCSMTConfigManager sharedInstance] config] transferConditionsUrl]];
                                          [[UIApplication sharedApplication] openURL:url];
                                      }
                                  }
                                                               target:self];
    
    [actionSheet showInView:self.view];
}



#pragma mark -
#pragma mark - UI Actions


#pragma mark -
#pragma mark - Helpers


#pragma mark -
#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{

}

@end

