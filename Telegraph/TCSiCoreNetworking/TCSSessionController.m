//
//  TCSMTSessionDataController.m
//  MT
//
//  Created by a.v.kiselev on 23/10/14.
//  Copyright (c) 2014 “Tinkoff Credit Systems” Bank (closed joint-stock company). All rights reserved.
//

#import "TCSSessionController.h"
#import "FBEncryptorAES.h"

NSString *const TCSOldSessionIdKey = @"TCSOldSessionIdKey";
NSString *const TCSNotificationSessionExpired = @"TCSNotificationSessionExpired";
NSString *const TCSNotificationSessionReceived = @"TCSNotificationSessionReceived";
NSString *const TCSSessionKey = @"TCSSessionKey";
NSString *const TCSPinHashKey = @"TCSPinHashKey";

@interface TCSSessionController()


@property (nonatomic, readonly) NSTimer * sessionExpirationTimer;
@property (nonatomic, readwrite) NSTimeInterval sessionFirstTimeGotTimeout;	//таймаут, полученный при первом успешном получении сессии

@end




@implementation TCSSessionController

@synthesize sessionExpirationTimer = _sessionExpirationTimer;
@synthesize sessionId = _sessionId;
@synthesize temporarySessionId = _temporarySessionId;
@synthesize sessionFirstTimeGotTimeout = _sessionFirstTimeGotTimeout;




#pragma mark -
#pragma mark - Object Creation

- (instancetype)init
{
	if (self = [super init])
	{

	}

	return self;
}




#pragma mark -
#pragma mark - Getters

- (NSString *)oldSessionIdWithDecryptionKey:(NSString *)decryptionKey
{
	NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];

	NSString *oldSessionId = [FBEncryptorAES decryptBase64String:[prefs stringForKey:TCSOldSessionIdKey] keyString:decryptionKey];

	return oldSessionId;
}




#pragma mark -
#pragma mark - Setters

- (void)setSession:(TCSSession *)session withEncryptionKey:(NSString *)encryptionKey
{
	[self setSessionId:session.sessionId andTimeOutInterval:session.sessionTimoutInSeconds withEncryptionKey:(NSString *)encryptionKey];
}

- (void)setSessionId:(NSString *)sessionId andTimeOutInterval:(NSTimeInterval)sessionTimoutInSeconds  withEncryptionKey:(NSString *)encryptionKey
{
	_sessionId = sessionId;

	NSTimeInterval sessionTimeout = sessionTimoutInSeconds;

	if (self.sessionFirstTimeGotTimeout == 0)
	{
		self.sessionFirstTimeGotTimeout = sessionTimoutInSeconds;
	}

	if (sessionTimeout == 0)
	{
//		ALog(@"Session timeout is 0!");
	}


	NSDate * endSessionDate = [[NSDate date]dateByAddingTimeInterval:sessionTimeout];
	[self setEndSessionTimeInterval:[endSessionDate timeIntervalSince1970]];

	[self setOldSessionId:sessionId withEncryptionKey:encryptionKey];
}

- (void)setEndSessionTimeInterval:(NSTimeInterval)endSessionTimeInterval
{
	[self invalidateSessionExpirationTimer];

	if ([[NSDate date]timeIntervalSince1970] < endSessionTimeInterval)
	{
		NSDate * fireDate = [NSDate dateWithTimeIntervalSince1970:endSessionTimeInterval];
		_sessionExpirationTimer = [[NSTimer alloc]initWithFireDate:fireDate interval:0 target:self selector:@selector(sessionExpired) userInfo:nil repeats:NO];
		[[NSRunLoop currentRunLoop]addTimer:_sessionExpirationTimer forMode:NSRunLoopCommonModes];
	}
	else
	{
		[self sessionExpired];
	}
}

- (void)setOldSessionId:(NSString *)oldSessionId withEncryptionKey:(NSString *)encryptionKey
{
	NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
	NSString *encrypted = nil;

	if (oldSessionId)
	{
		encrypted = [FBEncryptorAES encryptBase64String:oldSessionId keyString:encryptionKey separateLines:NO];
	}

	[prefs setObject:encrypted forKey:TCSOldSessionIdKey];
	[prefs synchronize];
}




#pragma mark -
#pragma mark - Helpers

- (void)updateOldSessionIdWithNewEncryptionKey:(NSString *)encryptionKey
{
	[self setOldSessionId:self.sessionId withEncryptionKey:encryptionKey];
}

- (BOOL)isOldSessionIdExists
{
	NSString * oldSessionEncrypted = [[NSUserDefaults standardUserDefaults] stringForKey:TCSOldSessionIdKey];
	NSString * oldSessionDecryptedWithNil = [FBEncryptorAES decryptBase64String:oldSessionEncrypted keyString:nil];

	// There is a moment between sign_up saving pin code, when oldSessionId is got from sign_up and saved without pin code with nil encryption.
	// So we have to check that pin was saved and there is no oldSessionId encrypted with nil key.

	if (oldSessionEncrypted.length > 0 && oldSessionDecryptedWithNil.length == 0)
	{
		return YES;
	}

	return NO;
}

- (BOOL)isCurrenSessionIdExistsAndRelevant
{
	return self.sessionExpirationTimer.isValid;
}

- (void)invalidateSessionExpirationTimer
{
	if (_sessionExpirationTimer)
	{
		[_sessionExpirationTimer invalidate];
		_sessionExpirationTimer = nil;
	}
}

- (void)sessionExpired
{
	[self clearSessionData];
	[self postSessionExpiredNotification];
}

- (void)clearSessionData
{
	_sessionId = nil;
	[self invalidateSessionExpirationTimer];
}

- (void)clearOldAndRelevantSessionData
{
	[self clearSessionData];
	[self setOldSessionId:nil withEncryptionKey:nil];
}

- (void)updateSessionTimerFromPing
{
	NSTimeInterval endSessionTimeInterval = [[NSDate date]timeIntervalSince1970] + self.sessionFirstTimeGotTimeout;
	[self setEndSessionTimeInterval:(NSTimeInterval)endSessionTimeInterval];
}




#pragma mark -
#pragma mark - Notifications

- (void)postSessionExpiredNotification
{
	[[NSNotificationCenter defaultCenter]postNotificationName:TCSNotificationSessionExpired object:nil];
}



@end
