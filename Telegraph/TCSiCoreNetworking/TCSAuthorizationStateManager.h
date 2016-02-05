//
//  TCSMTApplicationStateManager.h
//  MT
//
//  Created by a.v.kiselev on 23/10/14.
//  Copyright (c) 2014 “Tinkoff Credit Systems” Bank (closed joint-stock company). All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TCSSingleton.h"
#import "TCSSessionController.h"

@class TCSSessionController;

extern NSString *const TCSNotificationAccountResetActionPerformed;
extern NSString *const TCSNotificationChangeUserActionPerformed;
extern NSString *const TCSNotificationAccountCloseActionPerformed;
extern NSString *const TCSNotificationAuthorisationSetPinCode;
extern NSString *const TCSNotificationPinVerifiedOrChangedSuccessfully;
extern NSString *const TCSNotificationUpdateSessionFromPing;

extern NSString *const TCSAuthorizationStateNew;
extern NSString *const TCSAuthorizationStatePrevious;
extern NSString *const TCSAuthorizationSuccessBlock;



typedef NS_ENUM(NSInteger, TCSAuthorizationState)
{
	TCSAuthorizationStateUserBlocked = -2,			// totally blocked (call center is waiting for user call)
	TCSAuthorizationStatePinAttemptsExceeded = -1,	// pin attempts exceeded (blocking for some period)
	TCSAuthorizationStateNotDetermined = 0,
	TCSAuthorizationStateNoSession,					// signup
	TCSAuthorizationStateSetPinCode,					// setting pin (usually after signup)
	TCSAuthorizationStateSessionExpiredTouchIDAuth,	// auth by pin, touch id auth and getting pin from keychain
	TCSAuthorizationStateSessionExpiredPinAuth,		// auth by pin, pin enters manually
	TCSAuthorizationStateSessionIsRelevant			// totally authorized, session is relevant
};

typedef void(^StateChangedBlock)(TCSAuthorizationState stateNew, TCSAuthorizationState stateOld);

@interface TCSAuthorizationStateManager : TCSSingleton

@property (nonatomic, readonly) TCSSessionController * sessionController;
@property (nonatomic) TCSAuthorizationState currentAuthorizationState;
@property (nonatomic, copy) StateChangedBlock stateChangedBlock;

- (void)determineCurrentState;

@end
