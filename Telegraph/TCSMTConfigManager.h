//
//  TCSMTConfigManager.h
//  TCSMT
//
//  Created by a.v.kiselev on 01.08.13.
//  Copyright (c) 2013 “Tinkoff Credit Systems” Bank (closed joint-stock company). All rights reserved.
//

//@import Foundation;
//@import UIKit;

#import <Foundation/Foundation.h>
#import "TCSiCoreNetworking.h"
#import "TCSMTConfig.h"

#define kConfigLastUpdate @"configLastUpdate"

typedef enum
{
    TCSP2PDateFormatShort = 0,
    TCSP2PDateFormatFull,
    TCSP2PDateFormatLong,
    TCSP2PDateFormatRecently,
    TCSP2PDateFormatTime,
    TCSP2PDateFormatCardExpiry,
    TCSP2PDateFormatLock,
    TCSP2PDateFormatHumanTimer
    
}TCSP2PDateFormat;

@interface TCSMTConfigManager : NSObject

@property (nonatomic, strong) TCSMTConfig *config;

+ (TCSMTConfig *)config;
+ (instancetype)sharedInstance;
- (void)updateConfig;
- (BOOL)checkVersion;


#pragma mark - Image Urls


+ (NSString *)stringFromTimeIntervalSince1970:(NSTimeInterval)timeInterval
									   format:(TCSP2PDateFormat)dateFormat;

+ (NSTimeInterval)timeIntervalFromStringDate:(NSString *)date
									  format:(TCSP2PDateFormat) dateFormat;

+ (NSString *)timeSensativeDateWithTimeInterval:(TCSMillisecondsTimestamp *)timeInterval;

@end


FOUNDATION_EXPORT NSString * const TCSMTNeedForceUpdateApplication;

FOUNDATION_EXPORT NSString * const TCSMTNeedForceUpdateApplicationReleaseNotes;
FOUNDATION_EXPORT NSString * const TCSMTNeedForceUpdateApplicationReleaseNotesTitle;
FOUNDATION_EXPORT NSString * const TCSMTNeedForceUpdateApplicationActionBlock;
