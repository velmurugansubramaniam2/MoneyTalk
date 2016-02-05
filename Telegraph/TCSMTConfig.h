//
//  TCSMTConfig.h
//  MT
//
//  Created by a.v.kiselev on 31/10/14.
//  Copyright (c) 2014 “Tinkoff Credit Systems” Bank (closed joint-stock company). All rights reserved.
//

#import "TCSiCoreNetworking.h"

#define kMtCompatibility						@"mtTelegramCompatibility"
#define kMtValidation							@"mtValidation"
#define kMtDateFormat							@"mtDateFormat"
#define kMtEula									@"mtEula"
#define kMtCleanCacheTime						@"mtCleanCacheTime"
#define kMtAttachedCardLimit					@"mtAttachedCardLimit"
#define kMax                                    @"max"
#define KMin                                    @"min"
#define kMtSummDetectionCriteria                @"mtSummDetectionCriteria"
#define kMtHelpUrl                              @"mtHelpUrl"
#define kMtPriorityCountries                    @"mtPriorityCountries"

@class TCSMTAddCardConfig;

@interface TCSMTConfig : TCSBaseObject

@property (nonatomic, readonly) TCSCompatibility *mtCompatibility;
@property (nonatomic, strong, readonly) NSArray *mtTouchIdDevices;


- (NSString *)dateFormatShort;
- (NSString *)dateFormatLong;
- (NSString *)dateFormatRecently;
- (NSString *)dateFormatFull;
- (NSString *)dateFormatTime;
- (NSString *)dateFormatToday;
- (NSString *)dateFormatCardExpiry;
- (NSString *)dateFormatLock;
- (NSString *)dateFormatDayMonth;
- (NSString *)dateFormatDayMonthYear;
- (NSString *)transferConditionsUrl;
- (NSString *)ofertaUrl;
- (NSString *)confidentialPoliticUrl;
- (NSString *)mtCleanCacheTime;
- (NSString *)mtAttachedCardLimit;
- (NSURL *)helpURL;

- (NSUInteger)mtSummDetectionCritetriaForLimitMax;
- (NSUInteger)mtSummDetectionCritetriaForLimitMin;

@end
