//
//  TCSMTPinViewController.m
//  TCSMT
//
//  Created by Max Zhdanov on 06.09.13.
//  Copyright (c) 2013 “Tinkoff Credit Systems” Bank (closed joint-stock company). All rights reserved.
//

#import "TCSMTPinViewController.h"
#import "TCSMTPinNumbersView.h"
#import <AudioToolbox/AudioToolbox.h>
#import "TCSAuthorizationStateManager.h"
#import <LocalAuthentication/LocalAuthentication.h>
#import "UIDevice+Helpers.h"
#import "TCSMacroses.h"
#import "NSString+MD5.h"
#import "TCSAPIClient+TCSAPIClient_CommonAPIRequests.h"
#import "TCSMTNumberCell.h"
#import "MTKeychainController.h"
#import "TCSMTLocalConstants.h"
#import "TCSMTConfigManager.h"
#import "TCSAPIKeys.h"

#import "TCSTGTelegramMoneyTalkProxy.h"

#define kSendFeedbackButtonSpacing 7
#define kLinkTextViewVerticalMargin 8
#define kTextViewHeight 36
#define kOfertaViewsHeight 18

#define kLinkTextViewFontSize 13.0f
#define kMaximumNumberOfLines 2

@interface TCSMTPinViewController () <UICollectionViewDelegateFlowLayout, UINavigationControllerDelegate>

@property (nonatomic, weak) IBOutlet UICollectionView *keyboardCollectionView;
@property (nonatomic, weak) IBOutlet UIView *containerView;
@property (nonatomic, weak) IBOutlet UIView *ofertaContainerView;
@property (nonatomic, weak) IBOutlet UILabel *ofertaLabel;
@property (nonatomic, weak) IBOutlet UIButton *ofertaButton;

//@property (nonatomic, strong) UIButton *feedbackButton;
@property (nonatomic, strong) UILabel *blockDescriptionLabel;
@property (nonatomic, strong) UILabel *blockCountDownLabel;

@property (nonatomic, strong) TCSMTPinNumbersView *numbersViewMain;
@property (nonatomic, strong) TCSMTPinNumbersView *numbersViewSecond;

@property (nonatomic, weak) IBOutlet NSLayoutConstraint *ofertaContainerViewHeight;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *ofertaLabelHeight;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *ofertaButtonHeight;
@property (nonatomic, strong) IBOutletCollection (NSLayoutConstraint) NSArray *ofertaContainerViewVerticalMargins;

@property (nonatomic, weak) IBOutlet NSLayoutConstraint *minimumHeightConstraint;

@end

@implementation TCSMTPinViewController
{
    BOOL _fingerScanIsAlreadyShown;
    
    NSMutableString *_enteredPin;
    NSString *_comparePin;
    NSString *_oldSession;
    NSTimer	*_timerOfBlock;
    NSTimeInterval _secondsLeft;
    NSLayoutConstraint *_constraintYMain;
    NSLayoutConstraint *_constraintYSecond;
}


#pragma mark -
#pragma mark - UIViewController Lifecycle


- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setupNavigationBar];
    [self setupOfertaViews];
    
    _enteredPin = [NSMutableString string];
    
    [self layoutNumbersViewMain];
    [self layoutNumbersViewSecond];
    
    self.state = _state;
    
    [self.keyboardCollectionView registerNib:[UINib nibWithNibName:NSStringFromClass([TCSMTNumberCell class]) bundle:[NSBundle mainBundle]] forCellWithReuseIdentifier:NSStringFromClass([TCSMTNumberCell class])];
    
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
    [self.navigationController.navigationBar setShadowImage:[UIImage new]];
    [self.navigationController.navigationBar setTintColor:[TCSTGTelegramMoneyTalkProxy tgAccentColor]];
    
    //Жуткий костыль
    CGFloat realHeight = MAX(self.view.frame.size.width, self.view.frame.size.height);
    
    if (realHeight < 500)
    {
#define kMinimumHeightIPhone4s 198
        self.minimumHeightConstraint.constant = kMinimumHeightIPhone4s;
        [self.view layoutSubviews];
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if (self.state == TCSMTPinControllerStateAuthorization)
    {
        [self tryFingerAuth];
    }
}


- (UIStatusBarStyle)preferredStatusBarStyle
{
    if (self.navigationController && self.navigationController.navigationBar.hidden)
    {
        return UIStatusBarStyleDefault;
    }
    else
    {
        return UIStatusBarStyleLightContent;
    }
}

- (void)setupNavigationBar
{
    [self.navigationItem setLeftBarButtonItem:[[UIBarButtonItem alloc] initWithTitle:LOC(@"Common.Cancel") style:UIBarButtonItemStylePlain target:self action:@selector(cancelAction)]];
}

#pragma mark -
#pragma mark - Getters

- (TCSMTPinNumbersView *)numbersViewMain
{
    if (!_numbersViewMain)
    {
        _numbersViewMain = [TCSMTPinNumbersView newView];
    }
    
    return _numbersViewMain;
}

- (TCSMTPinNumbersView *)numbersViewSecond
{
    if (!_numbersViewSecond)
    {
        _numbersViewSecond = [TCSMTPinNumbersView newView];
    }
    
    return _numbersViewSecond;
}

#pragma mark -
#pragma mark - Setup

- (void)layoutNumbersViewMain
{
    NSLayoutConstraint *constraintX = [NSLayoutConstraint constraintWithItem:self.numbersViewMain
                                                                   attribute:NSLayoutAttributeCenterX
                                                                   relatedBy:NSLayoutRelationEqual
                                                                      toItem:self.containerView
                                                                   attribute:NSLayoutAttributeCenterX
                                                                  multiplier:1
                                                                    constant:0];
    
    NSLayoutConstraint *constraintY = [NSLayoutConstraint constraintWithItem:self.numbersViewMain
                                                                   attribute:NSLayoutAttributeCenterY
                                                                   relatedBy:NSLayoutRelationEqual
                                                                      toItem:self.containerView
                                                                   attribute:NSLayoutAttributeCenterY
                                                                  multiplier:1
                                                                    constant:0];
    constraintY.priority = 200;
    
    NSLayoutConstraint *height = [NSLayoutConstraint constraintWithItem:self.numbersViewMain
                                                              attribute:NSLayoutAttributeHeight
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:nil
                                                              attribute:NSLayoutAttributeNotAnAttribute
                                                             multiplier:1
                                                               constant:self.containerView.frame.size.height/2];
    
    NSLayoutConstraint *width = [NSLayoutConstraint constraintWithItem:self.numbersViewMain
                                                             attribute:NSLayoutAttributeWidth
                                                             relatedBy:NSLayoutRelationEqual
                                                                toItem:nil
                                                             attribute:NSLayoutAttributeNotAnAttribute
                                                            multiplier:1
                                                              constant:self.containerView.frame.size.width];
    
    NSLayoutConstraint *topSpace = [NSLayoutConstraint constraintWithItem:self.numbersViewMain
                                                                attribute:NSLayoutAttributeTop
                                                                relatedBy:NSLayoutRelationGreaterThanOrEqual
                                                                   toItem:self.containerView
                                                                attribute:NSLayoutAttributeTop
                                                               multiplier:1
                                                                 constant:0];
    
    self.numbersViewMain.translatesAutoresizingMaskIntoConstraints = NO;
    [self.containerView addSubview:self.numbersViewMain];
    [self.containerView addConstraints:@[constraintX, constraintY, height, width, topSpace]];
    
    _constraintYMain = constraintY;
}

- (void)layoutNumbersViewSecond
{
    NSLayoutConstraint *constraintX = [NSLayoutConstraint constraintWithItem:self.numbersViewSecond
                                                                   attribute:NSLayoutAttributeCenterX
                                                                   relatedBy:NSLayoutRelationEqual
                                                                      toItem:self.containerView
                                                                   attribute:NSLayoutAttributeCenterX
                                                                  multiplier:1
                                                                    constant:0];
    
    NSLayoutConstraint *constraintY = [NSLayoutConstraint constraintWithItem:self.numbersViewSecond
                                                                   attribute:NSLayoutAttributeCenterY
                                                                   relatedBy:NSLayoutRelationEqual
                                                                      toItem:self.containerView
                                                                   attribute:NSLayoutAttributeCenterY
                                                                  multiplier:1
                                                                    constant:0];
    
    NSLayoutConstraint *height = [NSLayoutConstraint constraintWithItem:self.numbersViewSecond
                                                              attribute:NSLayoutAttributeHeight
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:nil
                                                              attribute:NSLayoutAttributeNotAnAttribute
                                                             multiplier:1
                                                               constant:self.containerView.frame.size.height/2];
    
    NSLayoutConstraint *width = [NSLayoutConstraint constraintWithItem:self.numbersViewSecond
                                                             attribute:NSLayoutAttributeWidth
                                                             relatedBy:NSLayoutRelationEqual
                                                                toItem:nil
                                                             attribute:NSLayoutAttributeNotAnAttribute
                                                            multiplier:1
                                                              constant:self.containerView.frame.size.width];
    
    _constraintYSecond = constraintY;
    
    self.numbersViewSecond.translatesAutoresizingMaskIntoConstraints = NO;
    [self.containerView addSubview:self.numbersViewSecond];
    [self.containerView addConstraints:@[constraintX, constraintY, height, width]];
    
    self.numbersViewSecond.titleLabel.text = LOC(@"Pin.SecondPin");
    
    [self.containerView setNeedsLayout];

}

- (void)setupOfertaViews
{
    NSString *ofertaString = LOC(@"Oferta.Auth.Text");
    
    [self.ofertaLabel setText:ofertaString];
    [self.ofertaLabel setTextColor:[UIColor lightGrayColor]];
    [self.ofertaLabel setFont:[UIFont systemFontOfSize:14.0f]];
    
    
    NSDictionary *attributes = @{NSForegroundColorAttributeName : [UIColor lightGrayColor],
                                 NSFontAttributeName            : [UIFont systemFontOfSize:14.0f],
                                 NSUnderlineStyleAttributeName  : @(NSUnderlineStyleSingle)};
    
    NSString *ofertaLinkString = LOC(@"Oferta.Conditions.Link");
    NSAttributedString *ofertaLinkAttributedString = [[NSAttributedString alloc] initWithString:ofertaLinkString
                                                                                     attributes:attributes];
    
    [self.ofertaButton setAttributedTitle:ofertaLinkAttributedString forState:UIControlStateNormal];
    [self.ofertaButton addTarget:self action:@selector(openOfertaActionSheet) forControlEvents:UIControlEventTouchUpInside];
}


#pragma mark - UICollectionViewFlowLayoutDelegate

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CGRect frame = collectionView.frame;
    CGFloat itemWidth = (frame.size.height - 30)/4;
    CGFloat itemHeight = itemWidth;
    
    return CGSizeMake(70.0f, itemHeight);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    return 31.0f;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return 10.0f;
}


#pragma mark -
#pragma mark - CollectionView Data Source


- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return 12;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    TCSMTNumberCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([TCSMTNumberCell class]) forIndexPath:indexPath];
    switch (indexPath.row)
    {
        case 9:
        {
//            [cell.numberButton setImage:[UIImage imageNamed:@"fingerprint"] forState:UIControlStateNormal];
//            [cell.numberButton addTarget:self action:@selector(tryFingerAuth) forControlEvents:UIControlEventTouchUpInside];
            [cell.numberButton setUserInteractionEnabled:NO];
        }
            break;
        case 10:
        {
            [cell.numberButton setTitle:@"0" forState:UIControlStateNormal];
        }
            break;
        case 11:
        {
            [cell.numberButton setImage:[UIImage imageNamed:@"delete"] forState:UIControlStateNormal];
            [cell.numberButton setTitle:nil forState:UIControlStateNormal];
        }
            break;
            
        default:
        {
            [cell.numberButton setTitle:[NSString stringWithFormat:@"%ld", indexPath.row + 1] forState:UIControlStateNormal];
        }
            break;
    }
    
    [cell.numberButton addTarget:self action:@selector(onNumberKeyTouch:) forControlEvents:UIControlEventTouchDown];
    [cell.numberButton setTag:(indexPath.row + 1) * 10];
    
    return cell;
}

#pragma mark - 
#pragma mark - IBActions

- (void)onNumberKeyTouch:(UIButton *)sender
{
    NSInteger tag = sender.tag /10;

    switch (tag)
    {
        case 10:
        {
            /* no action */
        }
            break;
        case 11:
        {
            [self handleInputedKey:0];
        }
            break;
        case 12:
        {
            [self handleClear];
        }
            break;

        default:
        {
            [self handleInputedKey:tag];
        }
            break;
    }
}

- (void)handleClear
{
    BOOL isEmpty = _enteredPin.length == 0;
    if (isEmpty == NO)
    {
        [_enteredPin deleteCharactersInRange:(NSRange){_enteredPin.length - 1, 1}];
    }
    switch (_state)
    {
        case TCSMTPinControllerStateConfirmation:
        {
            if (isEmpty)
            {
                [self clearPin];
                [self setState:TCSMTPinControllerStateSetCode];
            } else
            {
                [self.numbersViewSecond setNumbersEntered:_enteredPin.length];
            }
        }
            break;

        default:
        {
            if (isEmpty == NO)
            {
                [self.numbersViewMain setNumbersEntered:_enteredPin.length];
            }
        }
            break;
    }
}

- (void)handleInputedKey:(NSInteger)key
{
    NSUInteger length = _enteredPin.length;

    if (length < 4)
    {
        [_enteredPin appendFormat:@"%ld", (long)key];
        length += 1;
    }

    switch (_state)
    {
        case TCSMTPinControllerStateSetCode:
        {
            [self.numbersViewMain setNumbersEntered:length];

            if (length == 4)
            {
                _comparePin = _enteredPin.copy;
                [_enteredPin deleteCharactersInRange:(NSRange){0, length}];
                [self setState:TCSMTPinControllerStateConfirmation];
            }
        }
            break;

        case TCSMTPinControllerStateConfirmation:
        {
            [self.numbersViewSecond setNumbersEntered:length];
            if (length == 4)
            {
                [self setState:TCSMTPinControllerStateCodeComparison];
            }
        }
            break;

        case TCSMTPinControllerStateAuthorization:
        case TCSMTPinControllerStateCheckUser:
        {
            [self.numbersViewMain setNumbersEntered:length];

            if (length == 4)
            {
                _keyboardCollectionView.userInteractionEnabled = NO;

                if (_needToSetPinAfterEntering)
                {
                    _enteredPinHashForSaving = [_enteredPin md5];
                    [self setState:TCSMTPinControllerStateSuccess];
                    return;
                }
                else
                {
                    [self processAndSendRequest];
                }

            }

        }
            break;

        default:
            break;
    }
}



- (void)processAndSendRequest
{
    NSString *pinHash = [_enteredPin md5];
    NSString *pin = _enteredPin;
    NSString *oldSessionId = [[TCSAuthorizationStateManager sharedInstance].sessionController oldSessionIdWithDecryptionKey:pinHash];
    __weak __typeof(self) weakSelf = self;

    void (^success)(TCSSession *, NSString *) = ^(TCSSession *session, __unused NSString *key)
    {
        __strong __typeof(weakSelf) strongSelf = weakSelf;
        if (strongSelf)
        {
            [strongSelf setPasswordToKeychain:strongSelf->_enteredPin];

            NSDictionary * userInfo = @{
                                        TCSSessionKey : session,
                                        TCSPinHashKey : pinHash
                                        };

            [[NSNotificationCenter defaultCenter]postNotificationName:TCSNotificationSessionReceived
                                                               object:nil
                                                             userInfo:userInfo];
            [strongSelf setState:TCSMTPinControllerStateSuccess];
        }
    };

    void (^attemptsExceeded)(TCSMillisecondsTimestamp *) = ^(TCSMillisecondsTimestamp *blockedUntil)
    {
        __strong __typeof(weakSelf) strongSelf = weakSelf;
        if (strongSelf)
        {
            [strongSelf setupAttemptsExceededStateWithMillisecondsTimestamp:blockedUntil];
        }
    };

    void (^failure)() = ^(NSError *error)
    {
        [TCSTGTelegramMoneyTalkProxy showAlertViewWithTitle:LOC(@"Error.ErrorTitle") message:error.userInfo[TCSAPIKey_errorMessage] cancelButtonTitle:nil okButtonTitle:LOC(@"OK") completionBlock:nil];
        
        [self setState:TCSMTPinControllerStateWrongCode];

        __strong __typeof(weakSelf) strongSelf = weakSelf;
        if (strongSelf && strongSelf->_failBlock)
        {
            strongSelf->_failBlock();
        }
        strongSelf->_keyboardCollectionView.userInteractionEnabled = YES;
    };

    [[TCSAPIClient sharedInstance] api_mobileAuthWithDeviceId:[UIDevice deviceId]
                                                            pin:pin
                                                   oldSessionId:oldSessionId
                                                        success:success
                                        pinEnterAtteptsExceeded:attemptsExceeded
                                                        failure:failure];
}




#pragma mark -

- (UILabel *)blockDescriptionLabel
{
    if (!_blockDescriptionLabel)
    {
        _blockDescriptionLabel = [UILabel new];
        _blockDescriptionLabel.backgroundColor = [UIColor clearColor];
        _blockDescriptionLabel.numberOfLines = 0;
        _blockDescriptionLabel.textAlignment = NSTextAlignmentCenter;

        NSDictionary *attributes = @{NSFontAttributeName: [UIFont systemFontOfSize:13.0f], NSForegroundColorAttributeName: [UIColor blackColor]};
        NSAttributedString *blockedErrorString = [[NSAttributedString alloc] initWithString:LOC(@"Pin.Error.PinAttemptsExceeded") attributes:attributes];

        _blockDescriptionLabel.attributedText = blockedErrorString ;
        
        NSLayoutConstraint *top = [NSLayoutConstraint constraintWithItem:_blockDescriptionLabel
                                                               attribute:NSLayoutAttributeTop
                                                               relatedBy:NSLayoutRelationEqual
                                                                  toItem:self.numbersViewMain
                                                               attribute:NSLayoutAttributeTop
                                                              multiplier:1
                                                                constant:0];
        
        NSLayoutConstraint *centerX = [NSLayoutConstraint constraintWithItem:_blockDescriptionLabel
                                                                   attribute:NSLayoutAttributeCenterX
                                                                   relatedBy:NSLayoutRelationEqual
                                                                      toItem:self.view
                                                                   attribute:NSLayoutAttributeCenterX
                                                                  multiplier:1
                                                                    constant:0];
        
        NSLayoutConstraint *width = [NSLayoutConstraint constraintWithItem:_blockDescriptionLabel
                                                                 attribute:NSLayoutAttributeWidth
                                                                 relatedBy:NSLayoutRelationLessThanOrEqual
                                                                    toItem:self.view
                                                                 attribute:NSLayoutAttributeWidth
                                                                multiplier:1
                                                                  constant:0];
        
        _blockDescriptionLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [self.view addSubview:_blockDescriptionLabel];
        [self.view addConstraints:@[top, centerX, width]];

        [self.view setNeedsLayout];
    }

    return _blockDescriptionLabel;
}

- (UILabel *)blockCountDownLabel
{
    if (!_blockCountDownLabel)
    {
        _blockCountDownLabel = [UILabel new];
        _blockCountDownLabel.textColor = [UIColor blackColor];
        _blockCountDownLabel.backgroundColor = [UIColor clearColor];
        _blockCountDownLabel.font = [UIFont systemFontOfSize:13.0f];

        NSString * blockedUntillString = [NSString stringWithFormat:@"%@\n%@",LOC(@"Pin.UserBlockedUntil"), @"  "];
        _blockCountDownLabel.numberOfLines = 0;
        _blockCountDownLabel.text = blockedUntillString;
        _blockCountDownLabel.textAlignment = NSTextAlignmentCenter;

        NSLayoutConstraint *top = [NSLayoutConstraint constraintWithItem:_blockCountDownLabel
                                                               attribute:NSLayoutAttributeTop
                                                               relatedBy:NSLayoutRelationEqual
                                                                  toItem:self.blockDescriptionLabel
                                                               attribute:NSLayoutAttributeBottom
                                                              multiplier:1
                                                                constant:8];
        
        NSLayoutConstraint *centerX = [NSLayoutConstraint constraintWithItem:_blockCountDownLabel
                                                                   attribute:NSLayoutAttributeCenterX
                                                                   relatedBy:NSLayoutRelationEqual
                                                                      toItem:self.view
                                                                   attribute:NSLayoutAttributeCenterX
                                                                  multiplier:1
                                                                    constant:0];
        
        NSLayoutConstraint *width = [NSLayoutConstraint constraintWithItem:_blockCountDownLabel
                                                                 attribute:NSLayoutAttributeWidth
                                                                 relatedBy:NSLayoutRelationLessThanOrEqual
                                                                    toItem:self.view
                                                                 attribute:NSLayoutAttributeWidth
                                                                multiplier:1
                                                                  constant:0];

        _blockCountDownLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [self.view addSubview:_blockCountDownLabel];
        [self.view addConstraints:@[top, centerX, width]];

        [self.view setNeedsLayout];
    }
    
    return _blockCountDownLabel;
}

//- (UIButton *)feedbackButton
//{
//    if (!_feedbackButton)
//    {
//        _feedbackButton = [UIButton new];
//        _feedbackButton.titleLabel.font = [UIFont systemFontOfSize:13.0f];
//        [_feedbackButton setTitle:LOC(@"title_sendFeedback") forState:UIControlStateNormal];
//        [_feedbackButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
//        
//        NSLayoutConstraint *top = [NSLayoutConstraint constraintWithItem:_feedbackButton
//                                                               attribute:NSLayoutAttributeTop
//                                                               relatedBy:NSLayoutRelationEqual
//                                                                  toItem:self.blockCountDownLabel
//                                                               attribute:NSLayoutAttributeBottom
//                                                              multiplier:1
//                                                                constant:kSendFeedbackButtonSpacing];
//        
//        NSLayoutConstraint *centerX = [NSLayoutConstraint constraintWithItem:_feedbackButton
//                                                                   attribute:NSLayoutAttributeCenterX
//                                                                   relatedBy:NSLayoutRelationEqual
//                                                                      toItem:self.view
//                                                                   attribute:NSLayoutAttributeCenterX
//                                                                  multiplier:1
//                                                                    constant:0];
//        
//        NSLayoutConstraint *width = [NSLayoutConstraint constraintWithItem:_feedbackButton
//                                                                 attribute:NSLayoutAttributeWidth
//                                                                 relatedBy:NSLayoutRelationLessThanOrEqual
//                                                                    toItem:self.view
//                                                                 attribute:NSLayoutAttributeWidth
//                                                                multiplier:1
//                                                                  constant:0];
//        
//        _feedbackButton.translatesAutoresizingMaskIntoConstraints = NO;
//        
//        [self.view addSubview:_feedbackButton];
//        [self.view addConstraints:@[top, centerX, width]];
//        
//        [self.view setNeedsLayout];
//    }
//
//    return _feedbackButton;
//}

- (void)setState:(TCSMTPinControllerState)state
{
    double delayInSeconds3 = 0;//.2f;
    dispatch_time_t popTime3 = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds3 * NSEC_PER_SEC));


    __block void (^completion)() = nil;
    void (^intemediateBlock)() = ^()
    {
        if (completion)
        {
            dispatch_after(popTime3, dispatch_get_main_queue(), completion);
        }
    };

    __weak __typeof(self) weakSelf = self;
    void (^mainBlock)() = ^()
    {
        __strong __typeof(weakSelf) strongSelf = weakSelf;
        [strongSelf setInvalid];
        intemediateBlock();
    };

    UIViewAnimationOptions options = UIViewAnimationOptionAllowAnimatedContent | UIViewAnimationOptionCurveEaseIn | UIViewAnimationOptionLayoutSubviews | UIViewAnimationOptionBeginFromCurrentState;
	switch (state)
	{
		case TCSMTPinControllerStateSuccess:
		{
            _keyboardCollectionView.userInteractionEnabled = NO;
            
            
			[self setIsOfferViewVisible:NO];
			NSString *pinHash = [_enteredPin md5];
            
            if (pinHash)
            {
                [[NSNotificationCenter defaultCenter] postNotificationName:TCSNotificationPinVerifiedOrChangedSuccessfully
                                                                    object:nil
                                                                  userInfo:@{TCSPinHashKey : pinHash}];
                if (self.successBlock)
                {
                    self.successBlock();
                }
            }

//			[self pinAccepted];
		}
			break;

		case TCSMTPinControllerStateAuthorization:
        case TCSMTPinControllerStateCheckUser:
        {
            _keyboardCollectionView.userInteractionEnabled = YES;
            
            [self showOrHideViews:@[self.numbersViewSecond, self.blockDescriptionLabel, self.blockCountDownLabel] show:NO];
            [self showOrHideViews:@[self.numbersViewMain, self.numbersViewSecond] show:YES];
            
            TCSAuthorizationState currentAuthorizationState = [[TCSAuthorizationStateManager sharedInstance] currentAuthorizationState];
            switch (currentAuthorizationState)
            {
                case TCSAuthorizationStateSessionIsRelevant:
                {
//                    [self.ofertaContainerView setHidden:YES];
                    [self layoutView:self.ofertaContainerView hidden:YES];
                }
                    break;
                    
                case TCSAuthorizationStateSessionExpiredPinAuth:
                {
                    [self.ofertaContainerView setHidden:NO];
                    [self layoutView:self.ofertaContainerView hidden:NO];
                }
                    break;
                    
                default:
                    break;
            }

			self.numbersViewMain.titleLabel.alpha = 1;
			self.numbersViewSecond.titleLabel.alpha = 1;
			self.numbersViewMain.titleLabel.text = LOC(@"Pin.FirstPin");
            
            if (state == TCSMTPinControllerStateCheckUser)
            {
                self.numbersViewMain.titleLabel.text = LOC(@"Pin.СurrentPin.Enter");
            }
            
			[self clearPin];
		}
			break;

		case TCSMTPinControllerStateWrongCode:
		{
            [self.ofertaContainerView setHidden:NO];
			[self setIsOfferViewVisible:NO];
            _keyboardCollectionView.userInteractionEnabled = NO;
            
			TCSMTPinControllerState previousState = _state;
            completion = ^()
            {
                __strong __typeof(weakSelf) strongSelfCompletion = weakSelf;
                if (previousState == TCSMTPinControllerStateCodeComparison)
                {
                    [strongSelfCompletion setState:TCSMTPinControllerStateSetCode];
                }
                else
                {
                    [strongSelfCompletion setState:TCSMTPinControllerStateAuthorization];
                }
            };

            mainBlock();
		}
			break;
            
        case TCSMTPinControllerStateCodesMismatch:
        {
//            [self.ofertaContainerView setHidden:YES];
            _keyboardCollectionView.userInteractionEnabled = NO;

            self.numbersViewSecond.titleLabel.alpha = 1;
            _constraintYSecond.constant = self.numbersViewSecond.frame.size.height * 0.5f;

            __strong __typeof(weakSelf) strongSelfCompletion = weakSelf;
            completion = ^()
            {
                [strongSelfCompletion setState:TCSMTPinControllerStateSetCode];
            };

            mainBlock();
        }
            break;

		case TCSMTPinControllerStateSetCode:
		{
//            [self.ofertaContainerView setHidden:YES];
            [self layoutView:_ofertaContainerView hidden:YES];
            
            [self setIsOfferViewVisible:NO];
            TCSMTPinControllerState previousState = _state;
            
            
            
            UILabel *label = self.numbersViewMain.titleLabel;
            label.text = LOC(@"Pin.FirstPin.Set");
            void (^animations)() = ^()
            {
                __strong __typeof(weakSelf) strongSelfAnimation = weakSelf;
                if (strongSelfAnimation)
                {
                    label.alpha = 1;
                    [strongSelfAnimation->_numbersViewMain layoutIfNeeded];
                    strongSelfAnimation->_keyboardCollectionView.userInteractionEnabled = YES;
                }
            };
            
            const NSTimeInterval duration = 0.5f;
            
            CGFloat viewUpdateDelay = 0.0;
            CGFloat animationDelay = 0.0;
            
            viewUpdateDelay = (previousState == TCSMTPinControllerStateConfirmation) ? 0.0f : 0.6f;
            animationDelay = (previousState == TCSMTPinControllerStateConfirmation) ? 0.0f : 0.25f;
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(viewUpdateDelay * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                __strong __typeof(weakSelf) strongSelfCompletion = weakSelf;
                if (strongSelfCompletion)
                {
                    [strongSelfCompletion clearPin];
                    strongSelfCompletion->_constraintYMain.constant = 0;
                    [UIView animateWithDuration:duration delay:animationDelay options:options animations:animations completion:nil];
                }
            });
            
            self.numbersViewMain.alpha = 1;
            self.numbersViewSecond.alpha = 0;
		}
			break;

		case TCSMTPinControllerStateConfirmation:
		{
//            [self.ofertaContainerView setHidden:YES];
//            [self layoutView:_ofertaContainerView hidden:YES];
            _keyboardCollectionView.userInteractionEnabled = NO;
            
            _constraintYMain.constant = -1 * (self.numbersViewMain.frame.size.height);
            _constraintYSecond.constant = self.numbersViewSecond.frame.size.height * 0.5f;
            
            const CGFloat duration = 0.5f * 0.5f;
			[UIView animateWithDuration:duration
								  delay:0
								options:options
							 animations:^
			 {
                 __strong __typeof(weakSelf) strongSelf = weakSelf;
                 if (strongSelf)
                 {
                     [strongSelf->_numbersViewMain layoutIfNeeded];
                 }
             }
                             completion: ^(BOOL finished)
             {
                 [UIView animateWithDuration:duration delay:0 options:options animations:^
                 {
                     __strong __typeof(weakSelf) strongSelf = weakSelf;
                     if (strongSelf)
                     {
                         strongSelf->_numbersViewSecond.alpha = 1;
                     }
                 }
                                  completion: ^(BOOL finishedSecondary)
                  {
                      __strong __typeof(weakSelf) strongSelf = weakSelf;
                      if (strongSelf)
                      {
                          strongSelf->_keyboardCollectionView.userInteractionEnabled = YES;
                      }
                  }];
             }];
		}
			break;

		case TCSMTPinControllerStateCodeComparison:
		{
            _keyboardCollectionView.userInteractionEnabled = NO;
            
//            [self.ofertaContainerView setHidden:YES];
//            [self layoutView:self.ofertaContainerView hidden:YES];
            
			[self setIsOfferViewVisible:NO];
            CGFloat duration = 0.5f * 0.5f;
			[UIView animateWithDuration:duration
								  delay:0
								options:options
							 animations:^
			 {
                 __strong __typeof(weakSelf) strongSelf = weakSelf;
                 if (strongSelf)
                 {
                     strongSelf->_numbersViewMain.titleLabel.alpha = 0;
                     strongSelf->_numbersViewSecond.titleLabel.alpha = 0;

                 }
			 } completion:^(BOOL finished)
			 {
                 __strong __typeof(weakSelf) strongSelfCompletion = weakSelf;
                 if (strongSelfCompletion)
                 {
                     strongSelfCompletion->_constraintYMain.constant = 0;
                     strongSelfCompletion->_constraintYSecond.constant = 0;
                 }
                 [UIView animateWithDuration:duration delay:0 options:options animations:^{
                     __strong __typeof(weakSelf) strongSelf = weakSelf;
                     if (strongSelf)
                     {
                         [strongSelf->_numbersViewMain layoutIfNeeded];
                         [strongSelf->_numbersViewSecond layoutIfNeeded];
                     }
                 } completion:^(BOOL finishedSecondary)
                 {
                     if (finishedSecondary)
                     {
                         __strong __typeof(weakSelf) strongSelf = weakSelf;
                         if (strongSelf)
                         {
                             strongSelf->_numbersViewSecond.alpha = 0.0f;
                             [strongSelf pinConfirmationResult:[strongSelf->_enteredPin isEqualToString:strongSelf->_comparePin]];
                         }
                     }
                 }];
			 }];
		}
			break;

		case TCSMTPinControllerStateAttemptsExceeded:
		{
            self.keyboardCollectionView.userInteractionEnabled = NO;
//            [self layoutView:self.ofertaContainerView hidden:YES];
            [self setIsOfferViewVisible:NO];
			[self setInvalid];

            [self showOrHideViews:@[self.numbersViewMain, self.numbersViewSecond] show:NO];
            [self showOrHideViews:@[self.blockCountDownLabel, self.blockDescriptionLabel] show:YES];
		}
			break;

		default:
			break;
	}

	_state = state;
}

- (void)showOrHideViews:(NSArray *)views show:(BOOL)show
{
    for (UIView *view in views)
    {
        [view setHidden:!show];
    }
}

- (void)setupAttemptsExceededStateWithMillisecondsTimestamp:(TCSMillisecondsTimestamp *)blockedUntill
{
    [[TCSAPIClient sharedInstance] api_now:^(NSTimeInterval serverTime, NSError *error)
     {
         [self setupAttemptsExceededStateWithMillisecondsTimestamp:blockedUntill andServerTime:serverTime];
     }];
}

- (void)setupAttemptsExceededStateWithMillisecondsTimestamp:(TCSMillisecondsTimestamp *)blockedUntill andServerTime:(NSTimeInterval)serverTime
{
    if (serverTime == 0)
    {
        serverTime = [[NSDate date]timeIntervalSince1970];
    }
    
    if (blockedUntill.seconds != 0 && serverTime != 0)
    {
        _secondsLeft = blockedUntill.seconds - serverTime;
        _timerOfBlock = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(updatePinControllerAttemptsExceededState) userInfo:nil repeats:YES];
        [self updatePinControllerAttemptsExceededState];
        [self setState:TCSMTPinControllerStateAttemptsExceeded];
    }
}

- (void)exitAttemptsExceededState
{
	[_timerOfBlock invalidate];
	_timerOfBlock = nil;
	[self setState:TCSMTPinControllerStateAuthorization];
}

- (void)updatePinControllerAttemptsExceededState
{
	if (_secondsLeft > 0)
	{
        _secondsLeft--;
        NSString *timeLeftString = [TCSMTConfigManager stringFromTimeIntervalSince1970:_secondsLeft format:TCSP2PDateFormatHumanTimer];
		NSString *blockedUntillString = [NSString stringWithFormat:@"%@\n%@", LOC(@"Pin.UserBlockedUntil"), timeLeftString];
		self.blockCountDownLabel.text = blockedUntillString;
    } else
    {
        [self exitAttemptsExceededState];
    }
}


- (void)pinConfirmationResult:(BOOL)isEqual
{
    if (isEqual)
    {
		NSString *pinString = _enteredPin;
		NSString *enteredPinHashForSaving = _enteredPinHashForSaving;

        __weak typeof(self) weakSelf = self;
        
		[[TCSAPIClient sharedInstance] api_mobileSavePinWithDeviceId:[UIDevice deviceId]
																   pin:pinString
														currentPinHash:_enteredPinHashForSaving
															   success:^(__unused NSString *key)
		 {
             __strong typeof(weakSelf) strongSelf = weakSelf;
             
             if (strongSelf)
             {
                 [strongSelf setPasswordToKeychain:strongSelf->_enteredPin];
                 [strongSelf setState:TCSMTPinControllerStateSuccess];
             }
         }
                                                             failure:^(NSError *error)
         {
             if (enteredPinHashForSaving)
             {
                 [self setInvalid];
                 
                 if (self.navigationController.viewControllers.count)
                 {
                     UIViewController *rootViewController = self.navigationController.viewControllers[0];
                     
                     if ([rootViewController isKindOfClass:[TCSMTPinViewController class]])
                     {
                         [(TCSMTPinViewController*)rootViewController setState:TCSMTPinControllerStateAuthorization];
                     }
                 }
             }
             else
             {
                 [self setState:TCSMTPinControllerStateWrongCode];
             }
             
             [TCSTGTelegramMoneyTalkProxy showAlertViewWithTitle:LOC(@"Error.ErrorTitle") message:error.userInfo[TCSAPIKey_errorMessage] cancelButtonTitle:nil okButtonTitle:LOC(@"OK") completionBlock:^(bool okButtonPressed)
             {
                 if (okButtonPressed)
                 {
                     [self clearPin];
                 }
             }];
         }];
	}
    else
    {
		[self setState:TCSMTPinControllerStateCodesMismatch];
    }
}


- (void)clearPin
{

    [_enteredPin deleteCharactersInRange:(NSRange){0, _enteredPin.length}];
    _comparePin = nil;

    _keyboardCollectionView.userInteractionEnabled = YES;


	[self.numbersViewMain setNumbersEntered:0];
	[self.numbersViewSecond setNumbersEntered:0];
}

- (void)setInvalid
{
    [self.numbersViewMain setInvalid:YES];
    AudioServicesPlayAlertSound(kSystemSoundID_Vibrate);
}

- (void)pinAccepted
{
    NSTimeInterval delayInSeconds = 0;//.3;
	dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    __weak __typeof(self) weakSelf = self;
	dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        __strong __typeof(weakSelf) strongSelf = weakSelf;
        if (strongSelf)
        {
            if (strongSelf->_needToSetPinAfterEntering == NO)
            {
                [strongSelf->_numbersViewMain setInvalid:NO];
            }

            if (strongSelf->_successBlock)
            {
                strongSelf->_successBlock(strongSelf->_enteredPinHashForSaving);
            }
        }
	});
}




#pragma mark - Layout

- (void)layoutView:(UIView *)view hidden:(BOOL)isHidden
{
    if ([view isEqual:_ofertaContainerView])
    {
        if (isHidden)
        {
            [_ofertaContainerViewHeight setConstant:0.0f];
            [_ofertaLabelHeight setConstant:0.0f];
            [_ofertaButtonHeight setConstant:0.0f];
            
            for (NSLayoutConstraint *margin in _ofertaContainerViewVerticalMargins)
            {
                [margin setConstant:0.0f];
            }
        }
        else
        {
            [_ofertaContainerViewHeight setConstant:kTextViewHeight];
            [_ofertaButtonHeight setConstant:kOfertaViewsHeight];
            [_ofertaLabelHeight setConstant:kOfertaViewsHeight];

            for (NSLayoutConstraint *margin in _ofertaContainerViewVerticalMargins)
            {
                [margin setConstant:kLinkTextViewVerticalMargin];
            }
        }
    }
}

#pragma mark - Oferta

- (void)openOfertaActionSheet
{
    TGActionSheetAction *ofertaAction = [TCSTGTelegramMoneyTalkProxy tgActionSheetActionWithTitle:LOC(@"Oferta.Oferta") action:@"oferta"];
    TGActionSheetAction *transfersConditionsAction = [TCSTGTelegramMoneyTalkProxy tgActionSheetActionWithTitle:LOC(@"Oferta.TransferConditions") action:@"transferConditions"];
    TGActionSheetAction *cancelAction = [TCSTGTelegramMoneyTalkProxy tgActionSheetActionWithTitle:LOC(@"Common.Cancel") action:@"cancel" type:TGActionSheetActionTypeCancel];
    
    NSArray *actions = @[ofertaAction, transfersConditionsAction, cancelAction];
    
    TGActionSheet *actionSheet = [TCSTGTelegramMoneyTalkProxy tgActionSheetWithTitle:nil actions:actions actionBlock:^(__unused TCSMTPinViewController *controller, NSString *action)
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

#pragma mark - TouchID

- (void)setPasswordToKeychain:(NSString *)password
{
    if (password.length > 0)
    {
        NSMutableDictionary *secValueDictionary = [NSMutableDictionary dictionaryWithDictionary:[[MTKeychainController sharedInstance] getSecValueDictionary]];
        
        [secValueDictionary setObject:password forKey:@"password"];
        
        [[MTKeychainController sharedInstance] setSecValueDictionary:secValueDictionary];
    }
}

- (NSString *)getPasswordFromKeychain
{
    NSDictionary *secValueDictionary = [[MTKeychainController sharedInstance] getSecValueDictionary];
    
    NSString *password = secValueDictionary[@"password"];
    
    return password;
}

- (void)fingerAuthWithTitle:(NSString *)title
{
    LAContext *myContext = [[LAContext alloc] init];
    NSError *authError = nil;
    NSString *myLocalizedReasonString = title;
    
    __weak typeof(self) weakSelf = self;
    
    if ([myContext canEvaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics error:&authError])
    {
        [myContext evaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics
                  localizedReason:myLocalizedReasonString
                            reply:^(BOOL success, NSError *error)
         {
             __strong typeof(weakSelf) strongSelf = weakSelf;
             
             if (strongSelf)
             {
                 strongSelf->_fingerScanIsAlreadyShown = NO;
                 if (success)
                 {
                     // User authenticated successfully, take appropriate action
                     
                     dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.4 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^
                     {
                         NSString *password = [strongSelf getPasswordFromKeychain];
                         [strongSelf touchIdSuccessCheckWithPassword:password];
                     });
                 }
                 else
                 {
                     // User did not authenticate successfully, look at error and take appropriate action
                     
                     //тут по ошибке можно понять, на какую кнопку нажал пользователь.
                     if (error.code == kLAErrorUserFallback)
                     {
                         //Error Domain=com.apple.LocalAuthentication Code=-3 "Tapped UserFallback button." UserInfo=0x175a3530 {NSLocalizedDescription=Tapped UserFallback button.}
                     }
                     else if (error.code == kLAErrorUserCancel)
                     {
                         //Error Domain=com.apple.LocalAuthentication Code=-2 "Authentication canceled by user." UserInfo=0x1760fb10 {NSLocalizedDescription=Authentication canceled by user.}
                     }
                     else
                     {
                         //other error
                     }
                 }
             }
             
         }];
    }
    else
    {
        // Could not evaluate policy; look at authError and present an appropriate message to user
        _fingerScanIsAlreadyShown = NO;
    }
}

- (void)touchIdSuccessCheckWithPassword:(NSString *)password
{
    [self.numbersViewMain setNumbersEntered:4];
    [self.numbersViewSecond setNumbersEntered:4];
    _enteredPin = [password mutableCopy];
    [self processAndSendRequest];
    
}

- (void)tryFingerAuth
{
    if (!_fingerScanIsAlreadyShown)// && !_isConfirmationPinCode)
    {
        NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
        BOOL isFingerAuthOn = [[prefs objectForKey:kIsFingerAuthOn] boolValue];
        
        if (!isFingerAuthOn)
        {
            return;
        }
        
        _fingerScanIsAlreadyShown = YES;
        [self fingerAuthWithTitle:[self fingerAuthAlertMessage]];
    }
}

- (NSString *)fingerAuthAlertMessage
{
    //на момент теста не могло быть пустым
    return LOC(@"TouchID.Alert");
}

- (void)cancelAction
{
    switch (self.state)
    {
        case TCSMTPinControllerStateSetCode:
        case TCSMTPinControllerStateCodeComparison:
        case TCSMTPinControllerStateConfirmation:
        case TCSMTPinControllerStateCodesMismatch:
        {
            TCSAuthorizationState state = [TCSAuthorizationStateManager sharedInstance].currentAuthorizationState;
            if (state != TCSAuthorizationStateSessionIsRelevant)
            {
                [[TCSAuthorizationStateManager sharedInstance] setCurrentAuthorizationState:TCSAuthorizationStateNoSession];
            }
        }
            break;
            
        default:
            break;
    }
    
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

@end
