//
//  TCSMTApplicationStateManager.m
//  MT
//
//  Created by a.v.kiselev on 23/10/14.
//  Copyright (c) 2014 “Tinkoff Credit Systems” Bank (closed joint-stock company). All rights reserved.
//

#import "TCSAuthorizationStateManager.h"
#import "TCSResponseProcessingManager.h"

//#import <TCSiCorePush/TCSiCorePush.h>


@implementation TCSAuthorizationStateManager

@synthesize currentAuthorizationState = _currentAuthorizationState;
@synthesize sessionController = _sessionController;

NSString *const TCSNotificationAccountResetActionPerformed = @"TCSNotificationAccountResetActionPerformed";
NSString *const TCSNotificationChangeUserActionPerformed = @"TCSNotificationChangeUserActionPerformed";
NSString *const TCSNotificationAccountCloseActionPerformed = @"TCSNotificationAccountCloseActionPerformed";
NSString *const TCSNotificationAuthorisationSetPinCode = @"TCSNotificationAuthorisationSetPinCode";
NSString *const TCSNotificationPinVerifiedOrChangedSuccessfully = @"TCSNotificationPinVerifiedOrChangedSuccessfully";
NSString *const TCSNotificationUpdateSessionFromPing = @"TCSNotificationUpdateSessionFromPing";

NSString *const TCSAuthorizationStateNew = @"TCSAuthorizationStateNew";
NSString *const TCSAuthorizationStatePrevious = @"TCSAuthorizationStatePrevious";
NSString *const TCSAuthorizationSuccessBlock = @"TCSAuthorizationSuccessBlock";


#pragma mark -
#pragma mark - Object Creation


- (id)init
{
	self = [super init];

	if (self)
	{
		[self registerForNotifications];
	}

	return self;
}




#pragma mark -
#pragma mark - Notifications

- (void)registerForNotifications
{
    NSNotificationCenter *defaultCenter = [NSNotificationCenter defaultCenter];
	[defaultCenter addObserver:self
					  selector:@selector(handleNewSessionNotificationRecieved:)
						  name:TCSNotificationSessionReceived
						object:nil];

	[defaultCenter addObserver:self
					  selector:@selector(handleResetedNotification)
						  name:TCSNotificationAccountResetActionPerformed
						object:nil];

	[defaultCenter addObserver:self
					  selector:@selector(handleSessionInvalidNotification)
						  name:TCSNotificationInsufficientPrivileges
						object:nil];

	[defaultCenter addObserver:self
					  selector:@selector(handleSessionInvalidNotification)
						  name:TCSNotificationSessionExpired
						object:nil];

	[defaultCenter addObserver:self
					  selector:@selector(handleUserChangedNotification)
						  name:TCSNotificationChangeUserActionPerformed
						object:nil];

	[defaultCenter addObserver:self
					  selector:@selector(handleWalletClosedNotification)
						  name:TCSNotificationAccountCloseActionPerformed
						object:nil];
	
	[defaultCenter  addObserver:self
					   selector:@selector(handleSignUpSucceeded)
						   name:TCSNotificationAuthorisationSetPinCode
						 object:nil];

	[defaultCenter  addObserver:self
					   selector:@selector(handlePinVerifiedOrChangedSuccessfully:)
						   name:TCSNotificationPinVerifiedOrChangedSuccessfully
						 object:nil];

	[defaultCenter  addObserver:self
					   selector:@selector(handleDeviceLinkNeeded)
						   name:TCSNotificationDeviceLinkNeeded
						 object:nil];

	[defaultCenter addObserver:self
					  selector:@selector(handleUpdateSessionFromPingNotification)
						  name:TCSNotificationUpdateSessionFromPing
						object:nil];
}

- (void)handleNewSessionNotificationRecieved:(NSNotification *)notification
{
	NSDictionary *userInfo = [notification userInfo];
	TCSSession *session = [userInfo objectForKey:TCSSessionKey];
	NSString *pinHash = [userInfo objectForKey:TCSPinHashKey];

	[self.sessionController setSession:session withEncryptionKey:pinHash];

	if (self.currentAuthorizationState == TCSAuthorizationStateSessionExpiredPinAuth)
	{
		[self setCurrentAuthorizationState:TCSAuthorizationStateSessionIsRelevant];
	}
}

- (void)handleUserChangedNotification
{
	[self setCurrentAuthorizationState:TCSAuthorizationStateNoSession];
    
}

- (void)handleResetedNotification
{
	[self setCurrentAuthorizationState:TCSAuthorizationStateNoSession];
}

- (void)handleWalletClosedNotification
{
	[self setCurrentAuthorizationState:TCSAuthorizationStateNoSession];
}

- (void)handleSessionInvalidNotification
{
	[self setCurrentAuthorizationState:TCSAuthorizationStateSessionExpiredPinAuth];
}

- (void)handleSignUpSucceeded
{
	[self setCurrentAuthorizationState:TCSAuthorizationStateSetPinCode];
}

- (void)handlePinVerifiedOrChangedSuccessfully:(NSNotification *)notification
{
	NSDictionary * userInfo = [notification userInfo];
	NSString * pinHash = userInfo[TCSPinHashKey];
	[self.sessionController updateOldSessionIdWithNewEncryptionKey:pinHash];

	if ([self currentAuthorizationState] == TCSAuthorizationStateSetPinCode)
	{
		[self setCurrentAuthorizationState:TCSAuthorizationStateSessionIsRelevant];
	}
}

- (void)handleDeviceLinkNeeded
{
	[self setCurrentAuthorizationState:TCSAuthorizationStateNoSession];
}

- (void)handleUpdateSessionFromPingNotification
{
	if (self.currentAuthorizationState == TCSAuthorizationStateSessionIsRelevant)
	{
		[self.sessionController updateSessionTimerFromPing];
	}
}




#pragma mark - 
#pragma mark - Setup Session Data Controller

- (TCSSessionController *)sessionController
{
	if (!_sessionController)
	{
		_sessionController = [[TCSSessionController alloc]init];
	}

	return _sessionController;
}




#pragma mark -
#pragma mark - State Changed

- (void)setCurrentAuthorizationState:(TCSAuthorizationState)newAuthorizationState
{
	switch (newAuthorizationState)
	{
		case TCSAuthorizationStateNoSession:
		{
			[self.sessionController clearOldAndRelevantSessionData];
		}
			break;

		case TCSAuthorizationStateSessionExpiredPinAuth:
		{
			[self.sessionController clearSessionData];
		}
			break;

		default:
			break;
	}

	if (newAuthorizationState != _currentAuthorizationState)
	{
		TCSAuthorizationState previousAuthorizationState = _currentAuthorizationState;
		_currentAuthorizationState = newAuthorizationState;
        
        if (self.stateChangedBlock)
        {
            self.stateChangedBlock(previousAuthorizationState, newAuthorizationState);
        }
	}
}




#pragma mark -
#pragma mark - Update

- (void)determineCurrentState
{
	TCSAuthorizationState state = TCSAuthorizationStateNoSession;
    
    __unused BOOL isExistAndRelevant = self.sessionController.isCurrenSessionIdExistsAndRelevant;
	if (self.sessionController.isCurrenSessionIdExistsAndRelevant)
	{
		state = TCSAuthorizationStateSessionIsRelevant;
	}
    
    __unused BOOL isOldSessionExists = self.sessionController.isOldSessionIdExists;
	if (self.sessionController.isOldSessionIdExists)
	{
		state = TCSAuthorizationStateSessionExpiredPinAuth;
	}

	[self setCurrentAuthorizationState:state];
}

@end
