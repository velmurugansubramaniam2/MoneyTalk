//
//  TCSMTCardsViewsController.m
//  MT
//
//  Created by Andrey Ilskiy on 02/10/14.
//  Copyright (c) 2014 “Tinkoff Credit Systems” Bank (closed joint-stock company). All rights reserved.
//

#import "TCSMTCardsViewsController.h"
#import "TCSMTAccountGroupsDataController.h"
#import "TCSMTCardWithMainCheckmarkTableViewCell.h"
#import "TCSMTConfigManager.h"
#import "TCSAPIClient.h"
#import "TCSMacroses.h"
#import "TCSUtils.h"
#import "TCSTGTelegramMoneyTalkProxy.h"

#define kAnimationDuration 0.3f

static void signUpForNotifications(const TCSMTCardsViewsController * const this);
static void resignFromNotifications(const TCSMTCardsViewsController * const this);

static void updateAvailableCardCount(NSMutableAttributedString * const mutableAttributedString, NSString * const tagAttribute, const NSUInteger count);

@interface TCSMTCardsViewsController () <UIActionSheetDelegate>

@property (nonatomic, weak) IBOutlet UIView *tableHeaderView;
@property (nonatomic, weak) IBOutlet UIView *tableFooterView;
@property (nonatomic, weak) IBOutlet UILabel *cardNumberLimitLabel;
@property (weak, nonatomic) IBOutlet UILabel *mainCardDescriptionLabel;
@property (nonatomic, weak) IBOutlet UIBarButtonItem *addCardBarButtonItem;

@property (nonatomic, strong) IBInspectable UIImage *visaImage;
@property (nonatomic, strong) IBInspectable UIImage *masterCardImage;
@property (nonatomic, strong) IBInspectable UIImage *maestroImage;

@property (nonatomic, strong) NSArray *externalCards;

- (void)handleDataSourceUpdate:(NSNotification*)notification;
- (void)handleFailureOfDataSourceUpdate:(NSNotification*)notification;

@end

@implementation TCSMTCardsViewsController
{
    TCSMTAccountGroupsDataController *_sharedAccountGroupsDataController;
    NSString *_cardCountAttribute;
    NSAttributedString *_cardNumberLimitConstantPart;
    NSUInteger _availableCardSlotsCount;
    NSIndexPath *_mainCardIndexPath;
    BOOL _islinkUpdate;
}

@synthesize tableHeaderView = _tableHeaderView;
@synthesize tableFooterView = _tableFooterView;
@synthesize cardNumberLimitLabel = _cardNumberLimitLabel;
@synthesize addCardBarButtonItem = _addCardBarButtonItem;

@synthesize visaImage = _visaImage;
@synthesize masterCardImage = _masterCardImage;
@synthesize maestroImage = _maestroImage;

- (void)setExternalCards:(NSArray *)externalCards
{
    if ([_externalCards isEqualToArray:externalCards] == NO && externalCards != nil)
    {
        _externalCards = externalCards;
        
        if (_externalCards.count == 0)
        {
            [self.navigationController popViewControllerAnimated:YES];
        }
        else
        {
            [self.tableView reloadData];
        }
    }
}

- (NSString *)cardWordEndingWithCountOf:(NSUInteger)count
{
    NSString *cardWord = @"";
    
//    switch ([TCSUtils wordEndingWithCountOf:count])
//    {
//        case TCSWordEndingByCountTypeResidue1:
//            cardWord = LOC(@"wordEnding_card_residue1");
//            break;
//            
//        case TCSWordEndingByCountTypeResidueFrom2To4:
//            cardWord = LOC(@"wordEnding_card_residueFrom2To4");
//            break;
//            
//        case TCSWordEndingByCountTypeFrom5To20OrResidue0:
//            cardWord = LOC(@"wordEnding_card_from5To20OrResidue0");
//            break;
//            
//        default:
//            break;
//    }
    
    return cardWord;
}

- (void)updateCardWord:(NSMutableAttributedString *)word
{
    NSString *replacementString = [NSString stringWithFormat:@" %@", [self cardWordEndingWithCountOf:_availableCardSlotsCount]];
    
    [word replaceCharactersInRange:NSMakeRange(_cardNumberLimitConstantPart.length, word.length - _cardNumberLimitConstantPart.length) withString:replacementString];
}

- (void)changeViewVisibility:(UIView *)view showView:(BOOL)show animated:(BOOL)animated
{
    if (animated)
    {
        [UIView animateWithDuration:kAnimationDuration animations:^
         {
             view.alpha = show ? 1.0f : 0.0f;
         }];
        
    }
    else
    {
        view.alpha = show ? 1.0f : 0.0f;
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = LOC(@"Settings.Card");
    _cardNumberLimitConstantPart = [[NSAttributedString alloc] initWithString:LOC(@"title_cardNumberLimit")];
    _cardNumberLimitLabel.attributedText = _cardNumberLimitConstantPart;
    _mainCardDescriptionLabel.attributedText = [[NSAttributedString alloc] initWithString:LOC(@"title_mainCardDescription")];
    
    _cardCountAttribute = @"cardCount";

    UITableView *tableView = self.tableView;
    tableView.rowHeight = 44;
    UIView *tableAccessoryView = _tableHeaderView;
    if (tableAccessoryView)
    {
        tableView.tableHeaderView = tableAccessoryView;
    }

    tableAccessoryView = _tableFooterView;
    if (tableAccessoryView)
    {
        tableView.tableFooterView = tableAccessoryView;
    }

    _sharedAccountGroupsDataController = TCSMTAccountGroupsDataController.sharedInstance;
    if (_sharedAccountGroupsDataController)
    {
        signUpForNotifications(self);
    }

    NSArray *externalCards = _sharedAccountGroupsDataController.groupsList.externalCards;
    if (externalCards && externalCards.count)
    {
        [self setExternalCards:externalCards];
        [self updateCardNumberLimitLabelAnimated:NO];
        [self updateMainCardDescriptionLabelAnimated:NO];
        
    } else
    {
        [_sharedAccountGroupsDataController requestDataFromServer];
    }

    _availableCardSlotsCount = 0;

    UILabel *label = _cardNumberLimitLabel;
    
    if (label)
    {
        NSMutableAttributedString *mutableAttributedString = label.attributedText.mutableCopy;
        NSRange range = [mutableAttributedString.string rangeOfString:@"Ω" options:NSBackwardsSearch];
        
        NSAssert(range.length > 0, @"Missing placeholder");
        
        [mutableAttributedString addAttribute:_cardCountAttribute value:_cardCountAttribute range:range];
        
        _availableCardSlotsCount = (NSUInteger)[TCSMTConfigManager sharedInstance].config.mtAttachedCardLimit.integerValue - (externalCards ? externalCards.count : 0);
        [mutableAttributedString replaceCharactersInRange:range withString:[NSString stringWithFormat:@"%lu", (unsigned long)_availableCardSlotsCount]];
        
        [self updateCardWord:mutableAttributedString];
        
        label.attributedText = mutableAttributedString.copy;
    }
    
    if (_availableCardSlotsCount == 0)
    {
        UIBarButtonItem *barButtonItem = _addCardBarButtonItem;
        if (barButtonItem)
        {
            barButtonItem.enabled = NO;
        }
    }
}

- (void)dealloc
{
    if (_sharedAccountGroupsDataController)
	{
        resignFromNotifications(self);
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

#pragma mark -
#pragma mark - table view delegate

#pragma mark -
#pragma mark - table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return _externalCards.count > 0 ? 1 : 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _externalCards.count > 0 ? (NSInteger)_externalCards.count : 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    TCSMTCardWithMainCheckmarkTableViewCell *cell = _externalCards.count > 0 ? [tableView dequeueReusableCellWithIdentifier:@"cardCell"] : nil;
    
    if (!cell)
    {
        cell = [TCSMTCardWithMainCheckmarkTableViewCell newCell];
    }
    
    if (cell)
    {
        TCSCard *card = ((TCSAccount*)_externalCards[(NSUInteger)indexPath.row]).cards[0];
        NSString *value = card.value;
        cell.cardNameLabel.text = [NSString stringWithFormat:@"%@ %@", card.lcsCardInfo.rusBankName, [card numberExtraShort]];

        NSString *cardTypeImageString = nil;
        
        switch ([TCSUtils cardTypeByCardNumberString:value])
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
        
        cell.paymentSystemLogoImageView.image = [UIImage imageNamed:cardTypeImageString];
        
        if (_externalCards.count < 2)
        {
            cell.isMainLabel.text = nil;
        }
        else
        {
            cell.isMainLabel.text = !card.primary ? nil : LOC(@"Settings.main");
        }
        
        if (cell.mainCard)
        {
            _mainCardIndexPath = indexPath;
        }
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
//        cell.isTheOnlyOneCard = (_externalCards.count == 1) ? YES : NO;
    }

    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section
{
    switch (_externalCards.count)
    {
        case 0:
            return nil;
            break;
        case 1:
            return LOC(@"Setting.oneCardHint");
            break;
            
        default:
            return LOC(@"Settings.mainCardHint");
            break;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    NSString *text = [self tableView:tableView titleForFooterInSection:section];
    
    if (text.length > 0)
    {
        UILabel *footerLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 12, self.tableView.frame.size.width - 30, 1000)];;
        footerLabel.text = text;
        [footerLabel setFont:[UIFont systemFontOfSize:13 weight:UIFontWeightLight]];
        [footerLabel setTextColor:[UIColor lightGrayColor]];
        footerLabel.numberOfLines = 0;
        [footerLabel sizeToFit];
        
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 100, 36)];
        [view addSubview:footerLabel];
        
        return view;
    }
    
    return nil;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([[TCSAuthorizationStateManager sharedInstance]currentAuthorizationState] == TCSAuthorizationStateSessionIsRelevant)
    {
        switch (editingStyle)
        {
            case UITableViewCellEditingStyleDelete:
            {
                UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:LOC(@"title_deleteCardAlert")
                                                                         delegate:self
                                                                cancelButtonTitle:LOC(@"Common.Cancel")
                                                           destructiveButtonTitle:LOC(@"Common.Delete")
                                                                otherButtonTitles:nil, nil];
                
                actionSheet.tag = indexPath.row;
                [actionSheet  showInView:self.view];
            }
                break;

            case UITableViewCellEditingStyleInsert:
            {
            }
                break;
                
            case UITableViewCellEditingStyleNone:
            {
            }
                break;
            default:
                NSAssert(NO, @"Should not be reached");
                break;
        }
    }
}

- (void)deleteCard:(TCSCard *)card
{
    __weak __typeof(self) weakSelf = self;
    
    [[TCSTGTelegramMoneyTalkProxy sharedInstance] showProgressWindowAnimated:YES];
    
    void (^sucecss)() = ^
    {
        __strong __typeof(weakSelf) strongSelf = weakSelf;
        
        if (strongSelf)
        {
            [strongSelf->_sharedAccountGroupsDataController getData:^
             {
                 [strongSelf setExternalCards:strongSelf->_sharedAccountGroupsDataController.groupsList.externalCards];
                 
                 [strongSelf updateCardNumberLimitLabelAnimated:YES];
                 [strongSelf updateMainCardDescriptionLabelAnimated:YES];
                 
                 [[TCSTGTelegramMoneyTalkProxy sharedInstance] dismissProgressWindowAnimated:YES];
             }
                                                          gotFailed:^
             {
                 [[TCSTGTelegramMoneyTalkProxy sharedInstance] dismissProgressWindowAnimated:YES];
             }];
        }
    };
    
    void (^failure)(NSError *) = ^(NSError *error)
    {
        [[TCSTGTelegramMoneyTalkProxy sharedInstance] dismissProgressWindowAnimated:YES];
    };
    
    TCSAPIClient * const apiClient = [TCSAPIClient sharedInstance];
    [apiClient api_cardDetachCardWithCardId:card.identifier success:sucecss failure:failure];
}

#pragma mark -
#pragma mark - notifiactions

- (void)handleDataSourceUpdate:(NSNotification *)notification
{
    NSArray *externalCards = _sharedAccountGroupsDataController.groupsList.externalCards;
    
    __weak __typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^
	{
        __strong __typeof(weakSelf) strongSelf = weakSelf;
        if (strongSelf)
        {
            [strongSelf setExternalCards:externalCards];
            
            [strongSelf updateCardNumberLimitLabelAnimated:YES];
            [strongSelf updateMainCardDescriptionLabelAnimated:YES];
        }
    });
}

- (void)updateCardNumberLimitLabelAnimated:(BOOL)animated
{
    UILabel *label = _cardNumberLimitLabel;
    if (label)
    {
        NSMutableAttributedString *mutableAttributedString = label.attributedText.mutableCopy;
        const NSUInteger value = [[[[TCSMTConfigManager sharedInstance] config] mtAttachedCardLimit] integerValue] - _externalCards.count;
        
        _availableCardSlotsCount = value;
        UIBarButtonItem *barButtonItem = _addCardBarButtonItem;
        if (barButtonItem)
        {
            barButtonItem.enabled = _availableCardSlotsCount > 0;
        }
        
        if (_availableCardSlotsCount > 0)
        {
            [self changeViewVisibility:label showView:YES animated:animated];
            
            updateAvailableCardCount(mutableAttributedString, _cardCountAttribute, _availableCardSlotsCount);
            [self updateCardWord:mutableAttributedString];
            
        }
        else
        {
            [self changeViewVisibility:label showView:NO animated:animated];
        }
        
        label.attributedText = mutableAttributedString.copy;
    }
}

- (void)updateMainCardDescriptionLabelAnimated:(BOOL)animated
{
    UILabel *cardDescriptionLabel = _mainCardDescriptionLabel;
    
    if (_externalCards.count <= 1)
    {
        [self changeViewVisibility:cardDescriptionLabel showView:NO animated:animated];
    }
    else
    {
        [self changeViewVisibility:cardDescriptionLabel showView:YES animated:animated];
    }
}

- (void)handleFailureOfDataSourceUpdate:(NSNotification*)notification
{
//    [[NSNotificationCenter defaultCenter] postNotificationName:TCSNotificationHideLoader object:nil];
//    TCSMTPopUpError * const errorPopUp = [TCSMTPopUpError errorPopupWithMessage:[notification.userInfo[kNotificationAccountsUpdateFailed] errorMessage]];
//    [errorPopUp show:nil];
}




#pragma mark -
#pragma mark - Network Interaction

- (void)setLinkedCardPrimary:(TCSCard *)card
{
	__weak __typeof(self) weakSelf = self;
	void (^success)() = ^
	{
		__strong __typeof(weakSelf) strongSelf = weakSelf;

		if (strongSelf)
		{
			[strongSelf->_sharedAccountGroupsDataController requestDataFromServer];
			strongSelf->_islinkUpdate = YES;
		}
	};

	void (^failure)(NSError*) = ^(NSError* error)
	{
//		[[NSNotificationCenter defaultCenter] postNotificationName:TCSNotificationHideLoader object:nil];
//		[TCSMTPopUpError errorPopupWithError:error];
	};

	TCSAPIClient * const apiClient = [TCSAPIClient sharedInstance];
//	[[NSNotificationCenter defaultCenter] postNotificationName:TCSNotificationShowLoader object:nil];
	[apiClient api_setLinkedCardPrimary:card.identifier
								success:success
								failure:failure];

}



#pragma mark -
#pragma mark - navigation

- (IBAction)unwindAction:(UIStoryboardSegue *)segue
{
    if ([segue.identifier isEqualToString:@"Done"])
    {
        [_sharedAccountGroupsDataController requestDataFromServer];
    }
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0)
    {
        TCSAccount * const account = _externalCards[actionSheet.tag];
        
        [self deleteCard:account.card];
    }
    
    [self.tableView setEditing:NO animated:YES];
}

@end

void signUpForNotifications(const TCSMTCardsViewsController * const this)
{
    NSNotificationCenter * const defaultCenter = NSNotificationCenter.defaultCenter;
    [defaultCenter addObserver:this selector:@selector(handleDataSourceUpdate:) name:kNotificationAccountsUpdated object:nil];
    [defaultCenter addObserver:this selector:@selector(handleFailureOfDataSourceUpdate:) name:kNotificationAccountsUpdateFailed object:nil];
}
void resignFromNotifications(const TCSMTCardsViewsController * const this)
{
    NSNotificationCenter * const defaultCenter = NSNotificationCenter.defaultCenter;
    [defaultCenter removeObserver:this name:kNotificationAccountsUpdated object:nil];
    [defaultCenter removeObserver:this name:kNotificationAccountsUpdateFailed object:nil];
}

void updateAvailableCardCount(NSMutableAttributedString * const mutableAttributedString, NSString * const tagAttribute, const NSUInteger count)
{
    [mutableAttributedString enumerateAttribute:tagAttribute inRange:(NSRange){0, mutableAttributedString.length} options:NSAttributedStringEnumerationReverse usingBlock:^(id value, NSRange range, BOOL *stop)
    {
        if (value == tagAttribute)
        {
            [mutableAttributedString replaceCharactersInRange:range withString:[NSString stringWithFormat:@"%lu", (unsigned long)count]];

            *stop = YES;
        }
    }];
}