//
//  TCSAnalytics.h
//  TCSP2PiPhone
//
//  Created by a.v.kiselev on 08/07/14.
//  Copyright (c) 2013 “Tinkoff Credit Systems” Bank (closed joint-stock company). All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "TCSSingleton.h"
#import "GAITracker.h"
#import "GAIDictionaryBuilder.h"

typedef NS_OPTIONS(NSUInteger, TCSAnalyticSystem)
{
	TCSAnalyticSystemAppsFlyer,
    TCSAnalyticsSystemGoogleAnalytics
};

extern NSString *const TCSiCoreAnalyticsConfigurationAppsFlyerDevKey;
extern NSString *const TCSiCoreAnalyticsConfigurationAppID;
extern NSString *const TCSiCoreAnalyticsConfigurationGoogleAnalyticsKey;

@interface TCSAnalytics : TCSSingleton
@property (nonatomic, strong) id <GAITracker> tracker;

	// Configuration and initialization
+ (void)startSessionsWithConfiguration:(NSDictionary *)configuration launchOptions:(id)launchOptions;

	// Events logging
+ (void)logEvent:(NSString *)event inSystem:(TCSAnalyticSystem)system withParams:(NSDictionary *)params;

@end