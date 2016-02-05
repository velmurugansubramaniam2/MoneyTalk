//
//  TCSAPIClientConfiguration.m
//  TCSiCore
//
//  Created by a.v.kiselev on 16/10/14.
//  Copyright (c) 2014 “Tinkoff Credit Systems” Bank (closed joint-stock company). All rights reserved.
//

#import <TCSAPIClientConfiguration.h>
#import "TCSAPIDefinitions.h"
#import "UIDevice+Helpers.h"

NSString *const TCSAPIClientMethodGET  = @"GET";
NSString *const TCSAPIClientMethodPOST = @"POST";

NSString *const TCSKeyResponse = @"response";
NSString *const TCSKeyRequest  = @"request";
NSString *const TCSKeyHandler  = @"handler";
NSString *const TCSKeyError    = @"error";

NSString *const TCSNotificationResponseNeedsProcessing = @"TCSNotificationResponseNeedsProcessing";

@implementation TCSAPIClientConfiguration
@synthesize domainPath = _domainPath, domainName = _domainName;
@synthesize resultCodesNeedProcessing = _resultCodesNeedProcessing;
@synthesize resultCodesSuccess = _resultCodesSuccess;
@synthesize sessionId = _sessionId;

//- (NSDictionary *)additionalCommonParameters
//{
//    NSString *appVersionString = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
//    _additionalCommonParameters = @{kOrigin      : kMtalk,
//                                    kAppVersion  : appVersionString,
//                                    kDeviceId	 : [UIDevice deviceId],
//                                    kPlatform    : @"ios"};
//    return _additionalCommonParameters;
//}


@end