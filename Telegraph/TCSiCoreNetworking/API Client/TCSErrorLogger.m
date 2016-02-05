//
//  TCSP2PLogger.m
//  TCSP2P
//
//  Created by Gleb Ustimenko on 12/2/13.
//  Copyright (c) 2013 “Tinkoff Credit Systems” Bank (closed joint-stock company). All rights reserved.
//

#import "TCSErrorLogger.h"
#import "UIDevice+Helpers.h"
#import "NSError+TCSAdditions.h"

@implementation TCSErrorLogger

+ (void)logErrorMessage:(NSString *)error onViewController:(id)viewController
{
    NSString *trackingId = nil;


    NSRange range = [error rangeOfCharacterFromSet:[NSCharacterSet characterSetWithCharactersInString:@"-"] options:NSBackwardsSearch];

    if (range.length > 0) {
        trackingId = [error substringFromIndex:range.location + 2];
    }


    NSString *description = [TCSErrorLogger errorDescription:error trackingId:trackingId screen:NSStringFromClass([viewController class])];

    [[TCSAPIClient sharedInstance] api_logErrorWithDescription:description];
}

+ (void)logError:(NSError *)error onViewController:(id)viewController
{
	NSString * errorMessage = [error errorMessage];
	NSString * trackingId = [error trackingId];

    NSString *description = [TCSErrorLogger errorDescription:errorMessage trackingId:trackingId screen:NSStringFromClass([viewController class])];
    
    [[TCSAPIClient sharedInstance] api_logErrorWithDescription:description];
}

+ (NSString *)errorDescription:(NSString *)error trackingId:(NSString *)trackingId screen:(NSString *)screen
{
    NSMutableArray *errorBodyArray = [NSMutableArray new];
	NSString * formatString = @"%@=\"%@\"";

    NSString *currentOS = [NSString stringWithFormat:formatString, kOS, [UIDevice deviceOS]];
    [errorBodyArray addObject:currentOS];
    
    NSString *currentModel = [NSString stringWithFormat:formatString, kModel, [UIDevice deviceModel]];
    [errorBodyArray addObject:currentModel];
    
    CGFloat currentAppVersion = [[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"] floatValue];
    
    NSString *currentVersion = [NSString stringWithFormat:formatString,kVersion, [@(currentAppVersion) stringValue]];
    [errorBodyArray addObject:currentVersion];
    
    if (screen != nil && [screen length] > 0)
    {
        NSString *screenName = [NSString stringWithFormat:formatString, kScreen, screen];
        [errorBodyArray addObject:screenName];
    }
    
    if (trackingId != nil && [trackingId length] > 0)
    {
        NSString *trackID = [NSString stringWithFormat:formatString, kTrackingId, trackingId];
        [errorBodyArray addObject:trackID];
    }
    
    if (error != nil && [error length] > 0)
    {
        NSString *errorString = [NSString stringWithFormat:formatString, kError, error];
        [errorBodyArray addObject:errorString];
    }
    
    NSString *errorBody = [errorBodyArray componentsJoinedByString:@","];
    
    return errorBody;
}


@end
