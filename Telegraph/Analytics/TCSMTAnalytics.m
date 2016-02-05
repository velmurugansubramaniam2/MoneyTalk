//
//  TCSMTAnalytics.m
//  MT
//
//  Created by spb-PBaranov on 08/05/15.
//  Copyright (c) 2015 “Tinkoff Credit Systems” Bank (closed joint-stock company). All rights reserved.
//

#import "TCSMTAnalytics.h"
#import "TCSAnalytics.h"

static TCSMTAnalytics *s_instance = nil;

@implementation TCSMTAnalytics

+ (instancetype)sharedInstance
{
    if(!s_instance)
    {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            s_instance = [[TCSMTAnalytics alloc] init];
        });
    }
    return s_instance;
}

- (void)setupWithLaunchOptions:(NSDictionary*)launchOptions
{
    NSMutableDictionary *analyticsConfiguration = [[NSMutableDictionary alloc] init];
    
    analyticsConfiguration[TCSiCoreAnalyticsConfigurationAppsFlyerDevKey] = @"fDDDbBVtE9DyqenGaQ7zFH";
    analyticsConfiguration[TCSiCoreAnalyticsConfigurationAppID] = @"1074994117";
    analyticsConfiguration[TCSiCoreAnalyticsConfigurationGoogleAnalyticsKey] = @"UA-71717843-2";

    [TCSAnalytics startSessionsWithConfiguration:analyticsConfiguration launchOptions:launchOptions];
}


- (void)logEvent:(NSString *)event withParams:(NSDictionary *)params
{
    [TCSAnalytics logEvent:event inSystem:TCSAnalyticSystemAppsFlyer withParams:nil];
    [TCSAnalytics logEvent:event inSystem:TCSAnalyticsSystemGoogleAnalytics withParams:params];
}

@end
