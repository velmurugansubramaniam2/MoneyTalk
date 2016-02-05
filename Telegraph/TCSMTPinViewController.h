//
//  TCSMTPinViewController.h
//  TCSMT
//
//  Created by Max Zhdanov on 06.09.13.
//  Copyright (c) 2013 “Tinkoff Credit Systems” Bank (closed joint-stock company). All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
	TCSMTPinControllerStateSetCode = 0,
	TCSMTPinControllerStateConfirmation,
	TCSMTPinControllerStateCodeComparison,
	TCSMTPinControllerStateAuthorization,
    TCSMTPinControllerStateCheckUser,
	TCSMTPinControllerStateWrongCode,
    TCSMTPinControllerStateCodesMismatch,
	TCSMTPinControllerStateSuccess,
	TCSMTPinControllerStateAttemptsExceeded

} TCSMTPinControllerState;

typedef NS_ENUM(NSInteger, TCSMTPinControllerAction) {
    TCSMTPinControllerActionConfirm,
    TCSMTPinControllerActionLogIn
};

@interface TCSMTPinViewController : UIViewController <UICollectionViewDelegate, UICollectionViewDataSource>

@property (nonatomic, assign) TCSMTPinControllerState state;
@property (nonatomic, assign) TCSMTPinControllerAction action;
@property (nonatomic) BOOL needToSetPinAfterEntering;
@property (nonatomic) BOOL shouldHideAfterPinAccepted;
@property (nonatomic, copy) void (^successBlock)();
@property (nonatomic, copy) void (^failBlock)();
@property (nonatomic, strong) NSString *enteredPinHashForSaving;
@property (nonatomic, strong) UIView * offerView;
@property (nonatomic, assign) BOOL isConfirmationPinCode;

@property (nonatomic, assign) BOOL isOfferViewVisible;


@end
