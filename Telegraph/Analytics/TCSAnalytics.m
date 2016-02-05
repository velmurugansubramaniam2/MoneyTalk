//
//  TCSAnalytics.m
//  TCSP2PiPhone
//
//  Created by Artem Slizhik on 18.06.13.
//  Copyright (c) 2013 “Tinkoff Credit Systems” Bank (closed joint-stock company). All rights reserved.
//

#import "TCSAnalytics.h"
#import "AppsFlyerTracker.h"
#import <CoreLocation/CoreLocation.h>
#import "GAI.h"
#import "GAIFields.h"


NSInteger const kLogLength = 30;

static NSString *const kCrashLogFilename  = @"crashLog.txt";
static NSString *const kLocationLongitude = @"TCS.analytics.location.longitude";
static NSString *const kLocationLatitude  = @"TCS.analytics.location.latitude";
static NSString *const kExistingUser	  = @"TCS.analytics.existingUser";

NSString *const TCSiCoreAnalyticsConfigurationAppsFlyerDevKey  = @"TCSiCoreAnalyticsConfigurationAppsFlyerDevKey";
NSString *const TCSiCoreAnalyticsConfigurationAppID            = @"TCSiCoreAnalyticsConfigurationAppID";
NSString *const TCSiCoreAnalyticsConfigurationGoogleAnalyticsKey = @"TCSiCoreAnalyticsConfigurationGoogleAnalyticsKey";

@interface TCSAnalytics ()

@property (nonatomic, strong) NSString *appID;
@property (nonatomic, strong) NSString *appsFlyerDevKey;
@property (nonatomic, strong) NSString *googleAnalyticsKey;


@property (nonatomic, strong) NSMutableArray *lastLoggedEvents;

- (void)saveEventToLog:(NSString *)event;

@end


@implementation TCSAnalytics
{
	dispatch_queue_t _crashLogWritingQueue;
}

@synthesize appID           = _appID;
@synthesize appsFlyerDevKey = _appsFlyerDevKey;

@synthesize lastLoggedEvents = _lastLoggedEvents;


#pragma mark - Public methods -
#pragma mark Configuration and initalization

+ (void)startSessionsWithConfiguration:(NSDictionary *)configuration launchOptions:(id)launchOptions
{
	TCSAnalytics *analytics = [TCSAnalytics sharedInstance];

    analytics.appsFlyerDevKey  = configuration[TCSiCoreAnalyticsConfigurationAppsFlyerDevKey];
    analytics.appID = configuration[TCSiCoreAnalyticsConfigurationAppID];
    analytics.googleAnalyticsKey = configuration[TCSiCoreAnalyticsConfigurationGoogleAnalyticsKey];
		
	[analytics startSessionWithOptions:launchOptions];
}


#pragma mark Events logging

+ (void)logEvent:(NSString *)event inSystem:(TCSAnalyticSystem)system withParams:(NSDictionary *)params
{
	if (!event)
    {
        return;
    }
    
	TCSAnalytics *analytics = [self sharedInstance];
	[analytics saveEventToLog:event];
	
    if ((system == TCSAnalyticSystemAppsFlyer) && analytics.appsFlyerDevKey)
    {
        [[AppsFlyerTracker sharedTracker] trackEvent:event withValue:nil];
    }
    
    if (system == TCSAnalyticsSystemGoogleAnalytics && analytics.googleAnalyticsKey && params[@"screenName"] != nil)
    {
        id <GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
        [tracker set:kGAIScreenName value:params[@"screenName"]];
        [tracker send:[[GAIDictionaryBuilder createScreenView] build]];
    }
}

+ (void)logEvent:(NSString *)event inAppsFlyerWithRevenue:(NSNumber *)revenue
{
	[[self sharedInstance] saveEventToLog:event];
	
	if ([self appsFlyerDevKey])
    {
        [[AppsFlyerTracker sharedTracker] trackEvent:event withValue:[revenue description]];
    }
}


#pragma mark - Private methods -

- (instancetype)init
{
	self = [super init];
	if (!self)
    {
        return nil;
    }
	
	_crashLogWritingQueue = dispatch_queue_create("ru.tcsbank.penalties.crashLogWriting", DISPATCH_QUEUE_SERIAL);
	
	return self;
}

+ (NSString *)appsFlyerDevKey
{
	return [[self sharedInstance] appsFlyerDevKey];
}

- (NSMutableArray *)lastLoggedEvents
{
	NSAssert([NSThread isMainThread], @"crash log is expected to be requested only from main queue");
	if (_lastLoggedEvents)
    {
        return _lastLoggedEvents;
    }
	
	NSURL *fileURL = [self crashLogFileURL];
	
	_lastLoggedEvents = [NSMutableArray arrayWithContentsOfURL:fileURL];
	if (!_lastLoggedEvents)
    {
		_lastLoggedEvents = [NSMutableArray arrayWithCapacity:kLogLength];
	}
	
	return _lastLoggedEvents;
}

- (NSURL *)crashLogFileURL
{
	NSURL *path = [[NSFileManager defaultManager] URLForDirectory:NSDocumentDirectory
														 inDomain:NSUserDomainMask
												appropriateForURL:nil
														   create:NO
															error:nil];
	return [path URLByAppendingPathComponent:kCrashLogFilename];
}

- (void)startSessionWithOptions:(id)launchOptions
{
    if (self.appID && self.appsFlyerDevKey)
	{
		[AppsFlyerTracker sharedTracker].appsFlyerDevKey = self.appsFlyerDevKey;
		[AppsFlyerTracker sharedTracker].appleAppID      = self.appID;
		[AppsFlyerTracker sharedTracker].currencyCode	 = @"RUB";
		[[AppsFlyerTracker sharedTracker] trackAppLaunch];
	}
    
    if (self.googleAnalyticsKey)
    {
        self.tracker = [[GAI sharedInstance] trackerWithName:@"MoneyTalkTracker" trackingId:self.googleAnalyticsKey];
    }
}

- (void)saveEventToLog:(NSString *)event
{
	NSMutableArray *lastLoggedEvents = self.lastLoggedEvents;
	
	[lastLoggedEvents addObject:event];
	if ([lastLoggedEvents count] > kLogLength)
    {
        [lastLoggedEvents removeObjectAtIndex:0];
    }
	
	NSArray *crashLog = [lastLoggedEvents copy];
	dispatch_async(_crashLogWritingQueue, ^
    {
		[crashLog writeToURL:[self crashLogFileURL] atomically:NO];
	});
}

@end
