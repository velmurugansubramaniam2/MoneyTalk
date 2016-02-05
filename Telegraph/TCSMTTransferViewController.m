//
//  TCSMTTransferViewController.m
//  Telegraph
//
//  Created by spb-EOrlova on 20.11.15.
//
//

#import "TCSMTTransferViewController.h"
#import "KeychainWrapper.h"

#import "TCSMBiOSCardInputTableViewCell.h"
#import "TCSMTCellWithSegmentedControl.h"
#import "TCSMTAmountCell.h"
#import "TCSMTCellWithButton.h"
#import "TCSAPIClient+TCSAPIClient_CommonAPIRequests.h"
#import "TCSResponseProcessingManager.h"
#import "TCSMTConfirmation3DSViewController.h"
#import "TCSMTAccountGroupsDataController.h"
#import "TCSAPIDefinitions.h"
#import "MTKeychainController.h"
#import <AVFoundation/AVFoundation.h>
#import "CardIO.h"
#import "CardIOPaymentViewController.h"

#import "TCSUtils.h"
#import "TCSMTCardTableViewCell.h"

#import "TCSMTPhoneCell.h"

#import "TCSMTConfigManager.h"
#import "TCSTGTelegramMoneyTalkProxy.h"
#import "NSNumberFormatter+SummAmount.h"

#import "TCSAnalytics.h"

#define kKeychainWrapperCardRequisitesIdentifier @"TCSMTTelegram.cardRequisites"
#define kKeychainWrapperCards @"TCSMTTelegramCards"
#define kCommissionLoadTimeInterval 0.5

typedef enum
{
    TCSMTSectionTypeSenderData,
    TCSMTSectionTypeReceiverData,
    TCSMTSectionTypeSumm,
    TCSMTSectionTypeActions
} TCSMTSectionType;

typedef enum
{
    TCSMTRowTypePerformTransfer,
    TCSMTRowTypeClose
} TCSMTRowType;

typedef enum
{
    TCSMTDestinationTypePhone = 0,
    TCSMTDestinationTypeCard
} TCSMTDestinationType;

@interface TCSMTTransferViewController() <UITextFieldDelegate, CardIOPaymentViewControllerDelegate, UIActionSheetDelegate, TCSMBiOSCardInputTableViewCellDelegate, TCSMBiOSTextFieldKeyInputDelegate>
{
    int64_t _conversationId;
    NSArray *_externalCards;
    
    UITextField *_currentTextField;
    
    UIInterfaceOrientation _currentDeviceOrientation;
}

//@property (nonatomic, strong) KeychainWrapper *keychainWrapper;

@property (weak, nonatomic) UITextField *cardNumberTextField;
@property (weak, nonatomic) UITextField *cvvTextField;

@property (nonatomic, strong) TCSMTCardTableViewCell *cardNumberCell;
@property (nonatomic, strong) TCSMBiOSCardInputTableViewCell *cardInputCell;
@property (nonatomic, strong) TCSMTBaseCellWithSeparators *otherCardsCell;

@property (nonatomic, strong) TCSMTCellWithSegmentedControl *destinationTypeCell;
@property (nonatomic, strong) TCSMTPhoneCell *destinationPhoneCell;
@property (nonatomic, strong) TCSMBiOSCardInputTableViewCell *destinationCardCell;

@property (nonatomic, strong) TCSMTAmountCell *moneyAmountCell;

@property (nonatomic, strong) TCSMTCellWithButton *transferCell;

@property (nonatomic, strong) TGUser *receiver;
@property (nonatomic, weak) NSTimer *timer;

@property (nonatomic, strong) TCSCard *selectedCard;

@property (nonatomic, strong) TCSMBiOSCardInputTableViewCell *nowScanningCardCell;

@end

@implementation TCSMTTransferViewController

#pragma mark - Init

- (instancetype)initWithConversationId:(int64_t)conversationId
{
    self = [super init];
    if (self)
    {
        _conversationId = conversationId;
    }
    
    return self;
}


#pragma mark - View Controller Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = LOC(@"Transfer.Title");
    
    NSArray *cells = @[[TCSMTCellWithTextField class], [TCSMTCellWithSegmentedControl class], [TCSMTAmountCell class], [UITableViewCell class], [TCSMTCellWithButton class], [TCSMBiOSCardInputTableViewCell class]];
    for (Class class in cells)
    {
        [self.tableView registerNib:[UINib nibWithNibName:NSStringFromClass(class) bundle:[NSBundle mainBundle]] forCellReuseIdentifier:NSStringFromClass(class)];
        if (class == [UITableViewCell class])
        {
            [self.tableView registerClass:class forCellReuseIdentifier:NSStringFromClass(class)];
        }
    }
    [self.tableView setKeyboardDismissMode:UIScrollViewKeyboardDismissModeInteractive];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handle3DSNotification:) name:TCSNotificationShowConfirmation3DS object:nil];
    
    [self.navigationItem setLeftBarButtonItem:[[UIBarButtonItem alloc] initWithTitle:LOC(@"Common.Cancel") style:UIBarButtonItemStylePlain target:self action:@selector(cancelAction)]];
    
    [self updateExternalCardsFromAccountGroupsList:[[TCSMTAccountGroupsDataController sharedInstance] groupsList]];
        
    self.tableView.separatorColor = [UIColor clearColor];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.navigationController.navigationBar setTintColor:[TCSTGTelegramMoneyTalkProxy tgAccentColor]];
    
    [self updateExternalCardsFromAccountGroupsList:[TCSMTAccountGroupsDataController sharedInstance].groupsList];
    
    _currentDeviceOrientation = [UIApplication sharedApplication].statusBarOrientation;
    
    [[NSNotificationCenter defaultCenter] addObserver:self  selector:@selector(orientationChanged:) name:UIDeviceOrientationDidChangeNotification  object:nil];
    
    NSString *phoneNumber = [self destinationPhoneNumber];
    
    if (phoneNumber.length == 0)
    {
        [self.destinationTypeCell.segmentedControl setSelectedSegmentIndex:1];
    }
}

#pragma mark - Updates

- (void)updateExternalCardsFromAccountGroupsList:(TCSAccountGroupsList *)accountGroupsList
{
    if (_externalCards.count == 0)
    {
        [self setSelectedCard:[accountGroupsList primaryCard]];
    }
    
    NSMutableArray *cards = [NSMutableArray array];
    
    for (TCSAccount *account in [accountGroupsList externalCards])
    {
        [cards addObject:account.card];
    }
    
    _externalCards = [NSArray arrayWithArray:cards];
    
    [self.tableView reloadData];
}

- (void)updateCardNumberCell
{
    if (self.selectedCard)
    {
        [self cardNumberCell].cardNameLabel.text = [NSString stringWithFormat:@"%@ %@", [self.selectedCard.lcsCardInfo rusBankName], [self.selectedCard numberExtraShort]];
        
        NSString *cardTypeImageString = nil;
        
        switch ([TCSUtils cardTypeByCardNumberString:[self selectedCard].value])
        {
            case TCSP2PCardTypeVisa:
            {
                cardTypeImageString = @"psIconVisa";
            }
                break;
            case TCSP2PCardTypeMasterCard:
            {
                cardTypeImageString = @"psIconMastercard";
            }
                break;
            case TCSP2PCardTypeMaestro:
            {
                cardTypeImageString = @"psIconMaestro";
            }
                break;
                
            default:
                NSAssert(false, @"Invalid card type - should never be reached");
                break;
        }
        
        [self cardNumberCell].paymentSystemLogoImageView.image = [UIImage imageNamed:cardTypeImageString];
    }
}

- (void)orientationChanged:(NSNotification *)__unused notification
{
    UIInterfaceOrientation newOrientation =  [UIApplication sharedApplication].statusBarOrientation;
    
    if (((newOrientation == UIInterfaceOrientationLandscapeLeft || newOrientation == UIInterfaceOrientationLandscapeRight)
        && (_currentDeviceOrientation == UIInterfaceOrientationPortrait || _currentDeviceOrientation == UIInterfaceOrientationPortraitUpsideDown))
        ||
        ((_currentDeviceOrientation == UIInterfaceOrientationLandscapeLeft || _currentDeviceOrientation == UIInterfaceOrientationLandscapeRight)
        && (newOrientation == UIInterfaceOrientationPortrait || newOrientation == UIInterfaceOrientationPortraitUpsideDown)))
    {
        [[self tableView] reloadData];
        
        if (_currentTextField)
        {
            [_currentTextField becomeFirstResponder];
        }
    }
    
    _currentDeviceOrientation = newOrientation;
}

#pragma mark - Setters

- (void)setSelectedCard:(TCSCard *)selectedCard
{
    if (![_selectedCard.identifier isEqualToString:selectedCard.identifier])
    {
        _selectedCard = selectedCard;
        
        [self.tableView reloadData];
    }
}

#pragma mark - Getters

- (TGUser *)receiver
{
    if (!_receiver)
    {
        _receiver = [TCSTGTelegramMoneyTalkProxy loadUser:(int)_conversationId];
    }
    
    return _receiver;
}

- (TCSMBiOSCardInputTableViewCell *)cardInputCell
{
    if (!_cardInputCell)
    {
        _cardInputCell = [TCSMBiOSCardInputTableViewCell cell];
        [_cardInputCell.cardIOButton setBackgroundColor:[UIColor clearColor]];
        [_cardInputCell.saveCardContainer setHidden:YES];
        _cardInputCell.backgroundColor = [UIColor whiteColor];
        [_cardInputCell setPlaceholderText:LOC(@"Transfer.CardNumber.Sender")];
        [_cardInputCell setUseDarkIcons:YES];
        [_cardInputCell.cardIOButton addTarget:self
                                        action:@selector(cardIOButtonPressed:)
                              forControlEvents:UIControlEventTouchUpInside];
        _cardInputCell.shouldHideTopSeparator = YES;
        _cardInputCell.delegate = self;
    }
    
    return _cardInputCell;
}

- (TCSMTCardTableViewCell *)cardNumberCell
{
    if (!_cardNumberCell)
    {
        _cardNumberCell = [TCSMTCardTableViewCell newCell];
        _cardNumberCell.selectionStyle = UITableViewCellSelectionStyleNone;
        _cardNumberCell.titleLabel.text = LOC(@"Transfer.FromCard");
    }
    
    return _cardNumberCell;
}

- (TCSMTBaseCellWithSeparators *)otherCardsCell
{
    if (!_otherCardsCell)
    {
        _otherCardsCell = [TCSMTBaseCellWithSeparators newCell];
        _otherCardsCell.titleLabel.text = LOC(@"Transfer.NewCard");
        [_otherCardsCell.titleLabel setTextColor:[TCSTGTelegramMoneyTalkProxy tgAccentColor]];
        _otherCardsCell.leadingMargingBottomSeparatorConstraint.constant = 7;
    }
    
    return _otherCardsCell;
}

- (TCSMTCellWithSegmentedControl *)destinationTypeCell
{
    if (!_destinationTypeCell)
    {
        _destinationTypeCell = [TCSMTCellWithSegmentedControl newCell];
        _destinationTypeCell.selectionStyle = UITableViewCellSelectionStyleNone;
        [_destinationTypeCell.segmentedControl setTitle:LOC(@"Transfer.segmentedControlPhone") forSegmentAtIndex:0];
        [_destinationTypeCell.segmentedControl setTitle:LOC(@"Transfer.segmentedControlCard") forSegmentAtIndex:1];
        
        [_destinationTypeCell.segmentedControl addTarget:self
                                                  action:@selector(segmentedControlDidChangeValue)
                                        forControlEvents:UIControlEventValueChanged];
        
        _destinationTypeCell.backgroundColor = [self.tableView backgroundColor];
    }
    
    return _destinationTypeCell;
}

- (TCSMTPhoneCell *)destinationPhoneCell
{
    if (!_destinationPhoneCell)
    {
        _destinationPhoneCell = [TCSMTPhoneCell newCell];
        _destinationPhoneCell.selectionStyle = UITableViewCellSelectionStyleNone;
        _destinationPhoneCell.textField.placeholder = LOC(@"Transfer.PhoneNumber.Placeholder");
        _destinationPhoneCell.textField.textAlignment = NSTextAlignmentCenter;
        _destinationPhoneCell.textField.delegate = self;
        _destinationPhoneCell.textField.keyInputDelegate = self;
        
        NSString *phoneNumber = [self destinationPhoneNumber];
        
        if (phoneNumber.length > 0)
        {
            _destinationPhoneCell.textField.text = [TCSTGTelegramMoneyTalkProxy formatPhone:phoneNumber forceInternational:true];
            _destinationPhoneCell.textField.enabled = NO;
        }
    }
    
    return _destinationPhoneCell;
}

- (TCSMBiOSCardInputTableViewCell *)destinationCardCell
{
    if (!_destinationCardCell)
    {
        _destinationCardCell = [TCSMBiOSCardInputTableViewCell cellForRecieverCard];
        [_destinationCardCell setUseDarkIcons:YES];
        [_destinationCardCell.saveCardContainer setHidden:YES];
        _destinationCardCell.backgroundColor = [UIColor whiteColor];
        
        NSString *phoneNumber = [self destinationPhoneNumber];
        NSString *cardNumber = [self getCardNumberForPhoneNumber:phoneNumber];
        
        _destinationCardCell.textFieldCardNumber.text = cardNumber;
        [_destinationCardCell setCardNumber:cardNumber];
        [_destinationCardCell textField:_destinationCardCell.textFieldCardNumber shouldChangeCharactersInRange:NSMakeRange(0, 0) replacementString:cardNumber];
        
        [_destinationCardCell setPlaceholderText:LOC(@"Transfer.CardNumber.Receiver")];
        
        [_destinationCardCell.cardIOButton addTarget:self
                                              action:@selector(cardIOButtonPressed:)
                                    forControlEvents:UIControlEventTouchUpInside];
        
        if (cardNumber.length > 0)
        {
            [_destinationCardCell setShowSecretContainer:YES];
            [_destinationCardCell.clearSecretContainerButton addTarget:self action:@selector(clearSecretLabelAction:) forControlEvents:UIControlEventTouchUpInside];
        }
        
        _destinationCardCell.delegate = self;
    }
    
    return _destinationCardCell;
}

- (TCSMTAmountCell *)moneyAmountCell
{
    if (!_moneyAmountCell)
    {
        _moneyAmountCell = [TCSMTAmountCell newCell];
        _moneyAmountCell.textField.placeholder = LOC(@"Transfer.TransferAmount");
        _moneyAmountCell.textField.keyboardType = UIKeyboardTypeNumberPad;
        [_moneyAmountCell.textField setDelegate:self];
        _moneyAmountCell.selectionStyle = UITableViewCellSelectionStyleNone;
        _moneyAmountCell.commissionLabel.text = nil;
        [_moneyAmountCell.activityIndicatorView stopAnimating];
        _moneyAmountCell.backgroundColor = [self.tableView backgroundColor];
    }
    
    return _moneyAmountCell;
}

- (TCSMTCellWithButton *)transferCell
{
    if (!_transferCell)
    {
        _transferCell = [TCSMTCellWithButton newCell];
        [_transferCell setSelectionStyle:UITableViewCellSelectionStyleNone];
        [_transferCell.performTransferButton addTarget:self action:@selector(performTransfer) forControlEvents:UIControlEventTouchUpInside];
        _transferCell.backgroundColor = [self.tableView backgroundColor];
        [_transferCell.performTransferButton setTitle:LOC(@"Transfer.performButton") forState:UIControlStateNormal];
    }
    
    return _transferCell;
}

- (NSString *)transferHintString
{
    NSString *transferHintString = nil;
    
    if (self.destinationTypeCell.segmentedControl.selectedSegmentIndex == 0)
    {
        transferHintString = LOC(@"Transfer.phoneHint");
    }
    else
    {
        transferHintString = LOC(@"Transfer.cardNumberHint");
    }
    
    return transferHintString;
}

#pragma mark - IBActions

- (IBAction)segmentedControlDidChangeValue
{
    [self.tableView reloadData];
    [self updateCommissionValue];
    
}

- (void)updateDestinationCell
{
    if (self.destinationTypeCell.segmentedControl.selectedSegmentIndex == 0)
    {
    }
    else
    {
    }
}

- (IBAction)cancelAction
{
    [self.view endEditing:YES];
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (void)showAttachedCards
{
    [self.view endEditing:YES];
    
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:LOC(@"Transfer.Cards")
                                delegate:self
                       cancelButtonTitle:LOC(@"Common.Cancel")
                  destructiveButtonTitle:nil
                       otherButtonTitles:nil];
    
    for (TCSCard *card in _externalCards)
    {
        [actionSheet addButtonWithTitle:[NSString stringWithFormat:@"%@ %@", [[card lcsCardInfo] rusBankName], [card numberExtraShort]]];
    }
    
    [actionSheet addButtonWithTitle:LOC(@"Transfer.FromNewCard")];
    
    [actionSheet showInView:self.view];
}

- (IBAction)clearSecretLabelAction:(id)__unused sender
{
    [[self destinationCardCell] setCardNumber:nil];
    [[self destinationCardCell] setShowSecretContainer:NO];
    
    [[self destinationCardCell].textFieldCardNumber setText:@""];
    [[self destinationCardCell] setCardNumber:@""];
    [[self destinationCardCell] textField:[self destinationCardCell].textFieldCardNumber shouldChangeCharactersInRange:NSMakeRange(0, 0) replacementString:@""];
}

#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)__unused actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex > 0)
    {
        if (buttonIndex > _externalCards.count)
        {
            [self setSelectedCard:nil];
            [self.cardInputCell.textFieldCardNumber performSelector:@selector(becomeFirstResponder) withObject:nil afterDelay:.3];
        }
        else
        {
            TCSCard *newSelectedCard = _externalCards[buttonIndex - 1];
            
            [self setSelectedCard:newSelectedCard];
        }
    }
}



#pragma mark - UITableViewDelegate

- (UIView *)tableView:(UITableView *)__unused tableView viewForHeaderInSection:(NSInteger)section
{
    if (section == TCSMTSectionTypeReceiverData)
    {
        UILabel *headerLabel = [[UILabel alloc] init];
        [headerLabel setFont:[UIFont fontWithName:[[self destinationPhoneCell].textField.font fontName] size:22]];//:
        [headerLabel setTextColor:[UIColor blackColor]];
        [headerLabel setTextAlignment:NSTextAlignmentCenter];
        [headerLabel setBackgroundColor:[UIColor clearColor]];
        
        NSString *title = self.selectedReceiver != nil ? self.selectedReceiver.displayName : [self receiver].displayName;
        headerLabel.text = title;
        
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 100, 36)];
        [view addSubview:headerLabel];
        [headerLabel sizeToFit];
        
        CGRect frame = headerLabel.frame;
        frame.origin.y = 36;
        frame.size.width = MIN(frame.size.width, self.tableView.frame.size.width - 20);
        frame.origin.x = self.tableView.frame.size.width/2 - frame.size.width/2;
        headerLabel.frame = frame;
        
        return view;
    }
    
    UIView *nilView = [[UIView alloc] init];
    nilView.backgroundColor = [UIColor clearColor];
    
    return nilView;
}

- (UIView *)tableView:(UITableView *)__unused tableView viewForFooterInSection:(NSInteger)__unused section
{
    if (section == TCSMTSectionTypeReceiverData)
    {
        UILabel *footerLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 12, self.tableView.frame.size.width - 30, 1000)];
        [footerLabel setFont:[UIFont systemFontOfSize:13.0f]];
        [footerLabel setTextColor:[UIColor lightGrayColor]];
        [footerLabel setNumberOfLines:0];

        [footerLabel setBackgroundColor:[UIColor clearColor]];
        
        NSString *title = [self transferHintString];
        
        footerLabel.text = title;
        
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 100, 36)];
        [view addSubview:footerLabel];
        [footerLabel sizeToFit];
        
        return view;
    }
    
    UIView *nilView = [[UIView alloc] init];
    nilView.backgroundColor = [UIColor clearColor];
    
    return nilView;
}

- (CGFloat)tableView:(UITableView *)__unused tableView heightForFooterInSection:(NSInteger)section
{
    if (section == TCSMTSectionTypeReceiverData)
    {
        UILabel *footerLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 12, self.tableView.frame.size.width - 30, 1000)];
        [footerLabel setFont:[UIFont systemFontOfSize:13.0f]];
        [footerLabel setNumberOfLines:0];

        NSString *title = [self transferHintString];
        
        footerLabel.text = title;

        [footerLabel sizeToFit];
        
        return footerLabel.frame.size.height + 12;
    }
    else if (section == TCSMTSectionTypeActions)
    {
        return 36.0f;
    }
    
    return 0.01f;
}

- (CGFloat)tableView:(UITableView *)__unused tableView heightForHeaderInSection:(NSInteger)__unused section
{
    if (section == TCSMTSectionTypeReceiverData)
    {
        return 36 + 16 + 27;
    }
    else if (section == TCSMTSectionTypeActions)
    {
        return 0.01f;
    }
    
    return 36.0f;
}

- (CGFloat)tableView:(UITableView *)__unused tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == TCSMTSectionTypeSumm)
    {
        return 56.0f + 36.0f;
    }
    else
    {
        return 44.0f;
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)__unused tableView
{
    return 4;
}

- (NSInteger)tableView:(UITableView *)__unused tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger numberOfRows;
    switch (section)
    {
        case TCSMTSectionTypeSenderData:
        {
            if (self.selectedCard)
            {
                return 1;
            }
            else
            {
                if (_externalCards.count > 0)
                {
                    return 2;
                }
                else
                {
                    return 1;
                }
            }
        }
            break;
            
        case TCSMTSectionTypeReceiverData:
        {
            numberOfRows = 2;
        }
            break;
            
        case TCSMTSectionTypeSumm:
        {
            numberOfRows = 1;
        }
            break;
            
        case TCSMTSectionTypeActions:
        {
            numberOfRows = 1;
        }
            break;
    }
    
    return numberOfRows;
}

- (void)tableView:(UITableView *) tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    switch (indexPath.section)
    {
        case TCSMTSectionTypeSenderData:
        {
            if (_externalCards.count > 0)
            {
                if (indexPath.row == 0)
                {
                    [self showAttachedCards];
                }
            }
        }
    }
}




#pragma mark - UITableViewDataSource

- (UITableViewCell *)tableView:(UITableView *)__unused tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section)
    {
        case TCSMTSectionTypeSenderData:
        {
            if (self.selectedCard)
            {
                [self updateCardNumberCell];
                
                return [self cardNumberCell];
            }
            else
            {
                if (_externalCards.count > 0)
                {
                    if (indexPath.row == 0)
                    {
                        return [self otherCardsCell];
                    }
                    else
                    {
                        [self cardInputCell].shouldHideTopSeparator = YES;
                        return [self cardInputCell];
                    }
                }
                else
                {
                    [self cardInputCell].shouldHideTopSeparator = NO;
                    return [self cardInputCell];
                }
            }
        }
            break;
            
        case TCSMTSectionTypeReceiverData:
        {
            switch (indexPath.row)
            {
                case 0:
                {
                    [self destinationTypeCell].separatorInset = UIEdgeInsetsMake(0.f, [self destinationTypeCell].bounds.size.width, 0.f, 0.f);
                    
                    return [self destinationTypeCell];
                }
                    break;
                    
                case 1:
                {
                    if ([self destinationTypeCell].segmentedControl.selectedSegmentIndex == 0)
                    {
                        return [self destinationPhoneCell];
                    }
                    else
                    {
                        return [self destinationCardCell];
                    }
                }
                    break;
            }
        }
            break;
            
        case TCSMTSectionTypeSumm:
        {
            return [self moneyAmountCell];
        }
            break;
            
        case TCSMTSectionTypeActions:
        {
            [self transferCell].separatorInset = UIEdgeInsetsMake(0.f, [self transferCell].bounds.size.width, 0.f, 0.f);
            
            return [self transferCell];
        }
            break;
    }
    
    return nil;
}

- (NSString *)numbersStringFromString:(NSString *)string
{
    if ([string length] >0)
    {
        static NSCharacterSet *nonDecimalDigitCharacterSet_ = nil;
        @synchronized(self)
        {
            if (nonDecimalDigitCharacterSet_ == nil)
            {
                nonDecimalDigitCharacterSet_ = [[NSCharacterSet decimalDigitCharacterSet] invertedSet];
            }
            
            return [[string componentsSeparatedByCharactersInSet:nonDecimalDigitCharacterSet_] componentsJoinedByString:@""];
        }
    }
    
    return @"";
}


#pragma mark - UITextFieldDelegate

- (void)startCommissionTimer
{
    [_timer invalidate];
    _timer = [NSTimer scheduledTimerWithTimeInterval:kCommissionLoadTimeInterval target:self selector:@selector(timerFired:) userInfo:nil repeats:NO];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    [self startCommissionTimer];
    
    if ([textField isEqual:_moneyAmountCell.textField])
    {
        NSString *newFormattedString = [NSNumberFormatter formatInputSumm:textField.text string:string range:range];
        
        textField.text = newFormattedString;
        
        return NO;
    }
    
    if ([textField isEqual:_destinationPhoneCell.textField])
    {
        if (![(TCSMBiOSTextField *)textField shouldChangeCharactersInRange:range replacementString:string])
        {
            NSString *availableString = [self numbersStringFromString:textField.text];
            
            BOOL result = [(TCSMBiOSTextField *)textField shouldChangeCharactersInRange:(NSRange){0, [textField.text length]} replacementString:availableString];
            
            return result;
        }
    }
    
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    if ([textField isEqual:[self moneyAmountCell].textField])
    {
        [self performSelector:@selector(scrollToBottom) withObject:nil afterDelay:.1];
    }
    
    _currentTextField = textField;
}

- (void)cardInputCellTextDidChange:(TCSMBiOSCardInputTableViewCell *)__unused cell
{
    [self startCommissionTimer];
}

- (void)scrollToBottom
{
    [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:TCSMTSectionTypeActions] atScrollPosition:UITableViewScrollPositionTop animated:YES];
}

#pragma mark - Timer

- (void)timerFired:(NSTimer *)__unused timer
{
    [self updateCommissionValue];
}


#pragma mark - CardIO

- (void)setupCardScaner:(CardIOPaymentViewController *)cardScaner
{
    [cardScaner setKeepStatusBarStyle:YES];
    [cardScaner setSuppressScanConfirmation:YES];
    [cardScaner setUseCardIOLogo:YES];
    [cardScaner setDisableManualEntryButtons:YES];
    [cardScaner setCollectExpiry:NO];
    [cardScaner setCollectCVV:NO];
}

- (void)cardIOButtonPressed:(id)sender
{
    if (sender == [self destinationCardCell].cardIOButton)
    {
        self.nowScanningCardCell = [self destinationCardCell];
    }
    else if (sender == [self cardInputCell].cardIOButton)
    {
        self.nowScanningCardCell = [self cardInputCell];
    }
    
    [self.view endEditing:YES];
    
    [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted)
    {
        dispatch_async(dispatch_get_main_queue(), ^
        {
            if (granted)
            {
                CardIOPaymentViewController *scanViewController = [[CardIOPaymentViewController alloc] initWithPaymentDelegate:self];
                scanViewController.disableBlurWhenBackgrounding = YES;
                scanViewController.navigationBarStyle = UIBarStyleBlack;
                [self setupCardScaner:scanViewController];
                [scanViewController setModalPresentationStyle:UIModalPresentationFormSheet];
                [self.navigationController presentViewController:scanViewController animated:YES completion:nil];
            }
            else
            {
            }
        });
    }];
}

- (void)userDidProvideCreditCardInfo:(CardIOCreditCardInfo *)info inPaymentViewController:(CardIOPaymentViewController *)paymentViewController
{
    __weak typeof(self) weakSelf = self;
    
    [paymentViewController dismissViewControllerAnimated:YES completion:^
    {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        
        if (strongSelf)
        {
            [[strongSelf nowScanningCardCell].textFieldCardNumber setText:@""];
            [[strongSelf nowScanningCardCell] setCardNumber:info.cardNumber];
            [[strongSelf nowScanningCardCell] textField:[strongSelf nowScanningCardCell].textFieldCardNumber shouldChangeCharactersInRange:NSMakeRange(0, 0) replacementString:info.cardNumber];
            
            [strongSelf setNowScanningCardCell:nil];
        }
    }];
}

- (void)userDidCancelPaymentViewController:(CardIOPaymentViewController *)paymentViewController
{
    [paymentViewController dismissViewControllerAnimated:YES completion:nil];
}



#pragma mark - Commision

- (void)updateCommissionValue
{
    if ([self moneyAmountCell].textField.text.length > 0)
    {
        [self loadCommission];
    }
    else
    {
        [[self moneyAmountCell].commissionLabel setText:nil];
    }

}

- (void)loadCommission
{
    if (![self allFieldsAreValid])
    {
        return;
    }
    
    NSString *providerId = nil;
    NSArray *providerFields = [NSArray array];
    
    switch ([self destinationType])
    {
        case TCSMTDestinationTypePhone:
        {
            providerId = kP2PC2C;
            
            NSString *phoneNumber = [self.destinationPhoneCell formattedPhoneString];
            
            if (phoneNumber != nil)
            {
                providerFields = @[@{kId    : kDstPointerType,
                                     kValue : kMobile},
                                   @{kId    : kDstPointer,
                                     kValue : phoneNumber}];
            }
        }
            break;
        case TCSMTDestinationTypeCard:
        {
            providerId = kC2CAnyToAny;
            
            providerFields = @[@{kId    : kToCardNumber,
                                 kValue : [[self destinationCardCell] cardNumber]}];
        }
            break;
    }
    
    __weak typeof(self) weakSelf = self;
    
    void (^successBlock)(TCSCommission *) = ^(TCSCommission *comission)
    {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        
        if (strongSelf)
        {
            NSNumber *commissionAmount = comission.commissionAmount;
            NSString *commissionText = nil;
            
            if ([commissionAmount doubleValue] != 0)
            {
                commissionText = [NSString stringWithFormat:LOC(@"Commission.Value"), [commissionAmount stringValue]];
            }
            else
            {
                commissionText = LOC(@"Commission.NoCommission");
            }
            
            [[strongSelf moneyAmountCell].commissionLabel setText:commissionText];
            [[strongSelf moneyAmountCell].activityIndicatorView stopAnimating];
        }
    };
    
    void (^failureBlock)(NSError *) = ^(__unused NSError *error)
    {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        
        if (strongSelf)
        {
            [[strongSelf moneyAmountCell].commissionLabel setText:LOC(@"Commission.LoadingError")];
            [[strongSelf moneyAmountCell].activityIndicatorView stopAnimating];
        }
    };
    
    NSString *amountAsString = [self amountString];
    
    [[self moneyAmountCell].activityIndicatorView startAnimating];
    [[self moneyAmountCell].commissionLabel setText:nil];
    
    if (self.selectedCard)
    {
        [self loadCommissionForCardID:self.selectedCard.identifier
                           providerId:providerId
                       providerFields:providerFields
                       amountAsString:amountAsString
                              success:successBlock
                              failure:failureBlock];
    }
    else
    {
        [self loadCommissionForCardNumber:[[self cardInputCell] cardNumber]
                               providerId:providerId
                           providerFields:providerFields
                           amountAsString:amountAsString
                                  success:successBlock
                                  failure:failureBlock];
    }
}

- (void)loadCommissionForCardID:(NSString *)cardId
                     providerId:(NSString *)providerId
                 providerFields:(NSArray *)providerFields
                 amountAsString:(NSString *)amountAsString
                        success:(void (^)(TCSCommission * commission))success
                        failure:(void (^)(NSError * error))failure
{
    [[TCSAPIClient sharedInstance] api_commissionLoadWithCardId:cardId
                                                    paymentType:kTransferCapitalized
                                                     providerId:providerId
                                                     templateId:nil
                                                 currencyString:kCurrencyRUB
                                                 amountAsString:amountAsString
                                                 providerFields:providerFields
                                                        success:success
                                                        failure:failure];
}

- (void)loadCommissionForCardNumber:(NSString *)cardNumber
                         providerId:(NSString *)providerId
                     providerFields:(NSArray *)providerFields
                     amountAsString:(NSString *)amountAsString
                            success:(void (^)(TCSCommission * commission))success
                            failure:(void (^)(NSError * error))failure
{
    [[TCSAPIClient sharedInstance] api_commissionLoadWithCardNumber:cardNumber
                                                        paymentType:kTransferCapitalized
                                                         providerId:providerId
                                                         templateId:nil
                                                     currencyString:kCurrencyRUB
                                                     amountAsString:amountAsString
                                                     providerFields:providerFields
                                                            success:success
                                                            failure:failure];
}




#pragma mark - Helpers

- (TCSMTDestinationType)destinationType
{
    return (TCSMTDestinationType)self.destinationTypeCell.segmentedControl.selectedSegmentIndex;
}

- (NSString *)destinationPhoneNumber
{
    NSString *phone = self.selectedReceiver.phoneNumber.length > 0 ? self.selectedReceiver.phoneNumber : self.receiver.phoneNumber;
    
    return phone;
}

- (NSString *)amountString
{
    NSString *unformattedAmountString = [NSNumberFormatter nonFormatAmountString:[[self moneyAmountCell] textField].text];
    
    return unformattedAmountString;
}

#pragma mark - Validation

- (BOOL)allFieldsAreValid
{
    return [self allFieldsAreValidShowAlert:NO];
}

- (BOOL)allFieldsAreValidShowAlert:(BOOL)showAlert
{
    BOOL isSourceValid = (self.selectedCard != nil || [self isSourceCardValid]);
    
    if (showAlert && !isSourceValid)
    {
        [[[UIAlertView alloc] initWithTitle:nil
                                   message:LOC(@"Transfer.errorSource")
                                  delegate:nil
                         cancelButtonTitle:LOC(@"Common.OK")
                          otherButtonTitles:nil, nil] show];
        
        return NO;
    }
    
    BOOL isDestinationValid;
    
    if ([self destinationType] == TCSMTDestinationTypePhone)
    {
        isDestinationValid = [self isPhoneValid];
    }
    else
    {
        isDestinationValid = [self isDestinationCardValid];
    }
    
    if (showAlert && !isDestinationValid)
    {
        [[[UIAlertView alloc] initWithTitle:nil
                                    message:LOC(@"Transfer.errorDestination")
                                   delegate:nil
                          cancelButtonTitle:LOC(@"Common.OK")
                          otherButtonTitles:nil, nil] show];
        
        return NO;
    }
    
    BOOL isSummValid = [self isSummValidShowAlert:showAlert];
    
    return isSourceValid && isDestinationValid && isSummValid;
}

- (BOOL)isSourceCardValid
{
    return [self.cardInputCell validateForm];
}

- (BOOL)isDestinationCardValid
{
    return [self.destinationCardCell validateForm];
}

- (BOOL)isPhoneValid
{
    return [self.destinationPhoneCell formattedPhoneString].length > 0;
}

- (BOOL)isSummValidShowAlert:(BOOL)showAlert
{
    TCSMTConfig *config = [[TCSMTConfigManager sharedInstance] config];
    
    double amount = [[self amountString] doubleValue];
    
    BOOL isSummValid = amount <= [config mtSummDetectionCritetriaForLimitMax] && amount >= [config mtSummDetectionCritetriaForLimitMin];
    
    if (showAlert && !isSummValid)
    {
        [[[UIAlertView alloc] initWithTitle:nil
                                    message:[NSString stringWithFormat:LOC(@"Transfer.errorSumm"), [NSNumberFormatter amountAsFormattedString:[config mtSummDetectionCritetriaForLimitMin]],[NSNumberFormatter amountAsFormattedString:[config mtSummDetectionCritetriaForLimitMax]]]
                                   delegate:nil
                          cancelButtonTitle:LOC(@"Common.OK")
                          otherButtonTitles:nil, nil] show];
    }
    
    return isSummValid;
}





#pragma mark - Transfer

- (void)performTransfer
{
    if (![self allFieldsAreValidShowAlert:YES])
    {
        return;
    }
    
    [[TCSTGTelegramMoneyTalkProxy sharedInstance] showProgressWindowAnimated:YES];
    
    if (self.destinationTypeCell.segmentedControl.selectedSegmentIndex == 0)
    {
        [self performTransferToPointer];
    }
    else
    {
        [self performTransferToCard];
    }
}

- (void)saveCard
{
    
}

- (void)performTransferToCard
{
    NSString *toCardNumber = [[self destinationCardCell] cardNumber];
    
    NSString *phoneNumber = [self destinationPhoneNumber];
    
    NSString *cardId = self.selectedCard ? [self.selectedCard identifier] : nil;

    NSString *amount = [self amountString];
    
    void (^completion)(NSString *)  = ^(NSString *paymentId)
    {
        [self logSuccessTransferWithPaymentId:paymentId];
        
        [self.navigationController dismissViewControllerAnimated:YES completion:^
         {
             if (self.delegate != nil && [self.delegate respondsToSelector:@selector(sendTransferMessageWithText:)])
             {
                 NSString *destinationNetworkAccountName = self.selectedReceiver != nil ? self.selectedReceiver.displayName : [self receiver].displayName;
                 NSString *sourceNetworkAccountName = [TGDatabaseInstance() loadUser:TGTelegraphInstance.clientUserId].displayName;
                 
                 NSString *text = [NSString stringWithFormat:LOC(@"Transfer.Completed"), sourceNetworkAccountName, destinationNetworkAccountName, amount];
                 
                 [self.delegate sendTransferMessageWithText:text];
             }
         }];
    };

    if (cardId.length > 0)
    {
        [[TCSAPIClient sharedInstance] api_transferAnyCardWithCardNumber:nil
                                                            expirityDate:nil
                                                            securityCode:nil
                                                                orCardId:cardId
                                                            toCardNumber:toCardNumber
                                                             moneyAmount:amount
                                                                currency:kCurrencyRUB
                                                            templateName:nil
                                                                 success:^(NSString *paymentId)
         {
             [[TCSTGTelegramMoneyTalkProxy sharedInstance] dismissProgressWindowAnimated:YES];
             [self saveCardNumber:toCardNumber withPhoneNumber:phoneNumber];

             if (![[[[[TCSMTAccountGroupsDataController sharedInstance] groupsList] primaryCard] identifier] isEqualToString:cardId])
             {
                 [self setLinkedCardPrimary:cardId];
             }
             
             completion(paymentId);
         }
                                                                 failure:^(__unused NSError *error)
         {
             [[TCSTGTelegramMoneyTalkProxy sharedInstance] dismissProgressWindowAnimated:YES];
             [TCSTGTelegramMoneyTalkProxy showAlertViewWithTitle:LOC(@"Error.ErrorTitle") message:error.userInfo[TCSAPIKey_errorMessage] cancelButtonTitle:nil okButtonTitle:LOC(@"OK") completionBlock:nil];
         }];
    }
    else
    {
        NSString *cardNumber = [self cardInputCell].cardNumber;
        NSString *cvv = [self cardInputCell].cardCVC;
        NSString *expiryDate = [self cardInputCell].cardExpirationDate;
        
        [[TCSAPIClient sharedInstance] api_transferAnyCardWithCardNumber:cardNumber
                                                            expirityDate:expiryDate
                                                            securityCode:cvv
                                                                orCardId:nil
                                                            toCardNumber:toCardNumber
                                                             moneyAmount:amount
                                                                currency:kCurrencyRUB
                                                            templateName:nil
                                                                 success:^(NSString *paymentId)
         {
             [self attachCard:cardNumber expirityDate:expiryDate cvv:cvv];
             [self saveCardNumber:toCardNumber withPhoneNumber:phoneNumber];
             
             [[TCSTGTelegramMoneyTalkProxy sharedInstance] dismissProgressWindowAnimated:YES];
             
             completion(paymentId);
         }
                                                                 failure:^(__unused NSError *error)
         {
             [[TCSTGTelegramMoneyTalkProxy sharedInstance] dismissProgressWindowAnimated:YES];
             [TCSTGTelegramMoneyTalkProxy showAlertViewWithTitle:LOC(@"Error.ErrorTitle") message:error.userInfo[TCSAPIKey_errorMessage] cancelButtonTitle:nil okButtonTitle:LOC(@"OK") completionBlock:nil];
         }];
    }
}

- (void)performTransferToPointer
{
    NSString *sourceNetworkAccountId = [TGDatabaseInstance() loadUser:TGTelegraphInstance.clientUserId].phoneNumber;
    //    NSString *sourceNetworkAccountId = @"+79632580022";
    
    NSString *cardId = self.selectedCard ? [self.selectedCard identifier] : nil;
    
    NSString *amount = [self amountString];
    NSString *destinationNetworkAccountId = [[self destinationPhoneCell] formattedPhoneString];
    //    NSString *destinationNetworkAccountId = @"+79632580023";
    
    NSString *cardNumber = [self cardInputCell].cardNumber;
    NSString *cvv = [self cardInputCell].cardCVC;
    NSString *expiryDate = [self cardInputCell].cardExpirationDate;
    
    void (^completion)(NSString *, NSString *, NSError *)  = ^(NSString *paymentId, __unused NSString *status, NSError *error)
    {
        [[TCSTGTelegramMoneyTalkProxy sharedInstance] dismissProgressWindowAnimated:YES];
        
        if (!error)
        {
            [self logSuccessTransferWithPaymentId:paymentId];
            
            if (cardId.length == 0)
            {
                [self attachCard:cardNumber expirityDate:expiryDate cvv:cvv];
            }
            else
            {
                if (![[[[[TCSMTAccountGroupsDataController sharedInstance] groupsList] primaryCard] identifier] isEqualToString:cardId])
                {
                    [self setLinkedCardPrimary:cardId];
                }
            }
            
            [self.navigationController dismissViewControllerAnimated:YES completion:^
             {
                 if (self.delegate != nil && [self.delegate respondsToSelector:@selector(sendTransferMessageWithText:)])
                 {
                     NSString *destinationNetworkAccountName = self.selectedReceiver != nil ? self.selectedReceiver.displayName : [self receiver].displayName;
                     NSString *sourceNetworkAccountName = [TGDatabaseInstance() loadUser:TGTelegraphInstance.clientUserId].displayName;
                     
                     NSString *text = [NSString stringWithFormat:LOC(@"Transfer.Completed"), sourceNetworkAccountName, destinationNetworkAccountName, amount];
                     
                     [self.delegate sendTransferMessageWithText:text];
                 }
             }];
        }
        else
        {
            [TCSTGTelegramMoneyTalkProxy showAlertViewWithTitle:LOC(@"Error.ErrorTitle") message:error.userInfo[TCSAPIKey_errorMessage] cancelButtonTitle:nil okButtonTitle:LOC(@"OK") completionBlock:nil];
        }
    };
    
    if (cardId.length > 0)
    {
        [[TCSAPIClient sharedInstance] api_transferAnyCardToAnyPointerWithCardId:cardId
                                                                    securityCode:nil
                                                          sourceNetworkAccountId:sourceNetworkAccountId
                                                                 sourceNetworkId:kMobile
                                                                      sourceName:nil
                                                     destinationNetworkAccountId:destinationNetworkAccountId
                                                            destinationNetworkId:kMobile
                                                                 destinationName:nil
                                                                     moneyAmount:amount
                                                                        currency:kCurrencyRUB
                                                                         message:nil
                                                                         imageId:nil
                                                                         invoice:nil
                                                                             ttl:nil
                                                                      completion:completion];
    }
    else
    {
        [[TCSAPIClient sharedInstance] api_transferAnyCardToAnyPointerWithCardNumber:cardNumber
                                                                          cardHolder:nil
                                                                        securityCode:cvv
                                                                        expirityDate:expiryDate
                                                              sourceNetworkAccountId:sourceNetworkAccountId
                                                                     sourceNetworkId:kMobile
                                                                          sourceName:nil
                                                         destinationNetworkAccountId:destinationNetworkAccountId
                                                                destinationNetworkId:kMobile
                                                                     destinationName:nil
                                                                         moneyAmount:amount
                                                                            currency:kCurrencyRUB
                                                                             message:nil
                                                                             imageId:nil
                                                                             invoice:nil
                                                                                 ttl:nil
                                                                          completion:completion];
    }
}

- (void)attachCard:(NSString *)cardNumber expirityDate:(NSString *)expirityDate cvv:(NSString *)cvv
{
    [[TCSAPIClient sharedInstance] api_attachCard:cardNumber
                                       expiryDate:expirityDate
                                       cardholder:@"Tinkoff MoneyTalk"
                                     securityCode:cvv
                                         cardName:[NSString stringWithFormat:@"* %@",[cardNumber substringFromIndex:cardNumber.length - 4]]
                                          success:^(__unused NSString *cardId)
    {
        [[TCSTGTelegramMoneyTalkProxy sharedInstance] dismissProgressWindowAnimated:YES];
        [[TCSMTAccountGroupsDataController sharedInstance] updateAccountsAndPerformBlockWithAccountsGroupsList:nil];
    }
                                          failure:^(NSError *error)
     {
         [[TCSTGTelegramMoneyTalkProxy sharedInstance] dismissProgressWindowAnimated:YES];
         [TCSTGTelegramMoneyTalkProxy showAlertViewWithTitle:LOC(@"Error.ErrorTitle") message:error.userInfo[TCSAPIKey_errorMessage] cancelButtonTitle:nil okButtonTitle:LOC(@"OK") completionBlock:nil];
     }];
}

- (void)setLinkedCardPrimary:(NSString *)cardId
{
    void (^success)() = ^
    {
        [[TCSMTAccountGroupsDataController sharedInstance] requestDataFromServer];
    };
    
    TCSAPIClient * const apiClient = [TCSAPIClient sharedInstance];
    [apiClient api_setLinkedCardPrimary:cardId
                                success:success
                                failure:nil];
    
}

- (void)logSuccessTransferWithPaymentId:(NSString *)paymentId
{
    if (paymentId.length > 0)
    {
        NSDictionary *event = [[GAIDictionaryBuilder createEventWithCategory:@"Transfer"
                                                                       action:@"transfer_success"
                                                                        label:paymentId
                                                                        value:nil] build];
        [[TCSAnalytics sharedInstance].tracker send:event];
    }
}

#pragma mark - Handle Notifications

- (void)handle3DSNotification:(NSNotification *)notification
{
    [[TCSTGTelegramMoneyTalkProxy sharedInstance] dismissProgressWindowAnimated:YES];
    
    TCSMTConfirmation3DSViewController *confirmation3DSVC = [[TCSMTConfirmation3DSViewController alloc] init];
    [confirmation3DSVC setupWithParameters:notification.userInfo];
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:confirmation3DSVC];
    [self.navigationController presentViewController:navigationController animated:YES completion:nil];
}


#pragma mark - KeychainWrapper

- (void)saveCardNumber:(NSString *)cardNumber withPhoneNumber:(NSString *)phoneNumber
{
    if (cardNumber.length > 0 && phoneNumber.length > 0)
    {
        NSMutableDictionary *secValueDictionary = [NSMutableDictionary dictionaryWithDictionary:[[MTKeychainController sharedInstance] getSecValueDictionary]];
        
        [secValueDictionary setObject:cardNumber forKey:phoneNumber];
        
        [[MTKeychainController sharedInstance] setSecValueDictionary:secValueDictionary];
    }
}

- (NSString *)getCardNumberForPhoneNumber:(NSString *)phoneNumber
{
    NSDictionary *secValueDictionary = [[MTKeychainController sharedInstance] getSecValueDictionary];
    
    NSString *cardNumber = nil;
    
    if (phoneNumber.length > 0)
    {
        cardNumber = secValueDictionary[phoneNumber];
    }
    
    return cardNumber;
}

@end
