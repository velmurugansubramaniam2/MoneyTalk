//
//  TCSMTConfig.m
//  MT
//
//  Created by a.v.kiselev on 31/10/14.
//  Copyright (c) 2014 “Tinkoff Credit Systems” Bank (closed joint-stock company). All rights reserved.
//

#import "TCSMTConfig.h"

#define kTransferConditionsUrl  @"transferConditionsUrl"
#define kOfertaUrl  @"ofertaUrl"
#define kConfidentialPoliticUrl @"confidentialPoliticUrl"

@interface TCSMTConfig ()

@end

@implementation TCSMTConfig

@synthesize mtCompatibility = _mtCompatibility;
@synthesize mtTouchIdDevices = _mtTouchIdDevices;

- (void)clearAllProperties
{
	_mtCompatibility = nil;
}

- (TCSCompatibility *)mtCompatibility
{
	if (!_mtCompatibility)
	{
		_mtCompatibility = [[TCSCompatibility alloc]initWithDictionary:_dictionary[kMtCompatibility][kIOS]];
	}

	return _mtCompatibility;
}



- (NSString *)dateFormatShort
{
	id format = [_dictionary objectForKey:kMtDateFormat];

	if ([format isKindOfClass:[NSDictionary class]])
		format = [format objectForKey:kShort];

	return format;
}

- (NSString *)dateFormatLong
{
	id format = [_dictionary objectForKey:kMtDateFormat];

	if ([format isKindOfClass:[NSDictionary class]])
		format = [format objectForKey:kLong];

	return format;
}

- (NSString *)dateFormatRecently
{
	id format = [_dictionary objectForKey:kMtDateFormat];

	if ([format isKindOfClass:[NSDictionary class]])
		format = [format objectForKey:kRecently];

	return format;
}

- (NSString *)dateFormatFull
{
	id format = [_dictionary objectForKey:kMtDateFormat];

	if ([format isKindOfClass:[NSDictionary class]])
		format = [format objectForKey:kFull];

	return format;
}

- (NSString *)dateFormatTime
{
	id format = [_dictionary objectForKey:kMtDateFormat];

	if ([format isKindOfClass:[NSDictionary class]])
		format = [format objectForKey:kTime];

	return format;
}

- (NSString *)dateFormatToday
{
	id format = [_dictionary objectForKey:kMtDateFormat];

	if ([format isKindOfClass:[NSDictionary class]])
		format = [format objectForKey:kToday];

	return format;
}

- (NSString *)dateFormatCardExpiry
{
	id format = [_dictionary objectForKey:kMtDateFormat];

	if ([format isKindOfClass:[NSDictionary class]])
		format = [format objectForKey:kCardExpiry];

	return format;
}

- (NSString *)dateFormatLock
{
	id format = [_dictionary objectForKey:kMtDateFormat];

	if ([format isKindOfClass:[NSDictionary class]])
		format = [format objectForKey:kLock];

	return format;
}

- (NSString *)dateFormatDayMonth
{
	id format = [_dictionary objectForKey:kMtDateFormat];

	if ([format isKindOfClass:[NSDictionary class]])
		format = [format objectForKey:kDayMonth];

	return format;
}

- (NSString *)dateFormatDayMonthYear
{
	id format = [_dictionary objectForKey:kMtDateFormat];

	if ([format isKindOfClass:[NSDictionary class]])
		format = [format objectForKey:kDayMonthYear];

	return format;
}


- (id)mtEula
{
	id value = [_dictionary objectForKey:kMtEula];

	return value;
}

- (NSString *)transferConditionsUrl
{
    NSString *transferConditionsUrl = nil;
    
    if ([[self mtEula] isKindOfClass:[NSDictionary class]])
    {
        transferConditionsUrl = [[self mtEula] objectForKey:kTransferConditionsUrl];
    }
    
    return transferConditionsUrl;
}

- (NSString *)ofertaUrl
{
    NSString *ofertaUrl = nil;
    
    if ([[self mtEula] isKindOfClass:[NSDictionary class]])
    {
        ofertaUrl = [[self mtEula] objectForKey:kOfertaUrl];
    }
    
    return ofertaUrl;
}

- (NSString *)confidentialPoliticUrl
{
    NSString *confidentialPoliticUrl = nil;
    
    if ([[self mtEula] isKindOfClass:[NSDictionary class]])
    {
        confidentialPoliticUrl = [[self mtEula] objectForKey:kConfidentialPoliticUrl];
    }
    
    return confidentialPoliticUrl;
}

- (NSString *)mtCleanCacheTime
{
	NSDictionary *cleanCacheTimeDic = _dictionary[kMtCleanCacheTime];

	if (cleanCacheTimeDic)
	{
		return cleanCacheTimeDic[kIos];
	}

	return nil;
}

-(NSString *)mtAttachedCardLimit
{
	return _dictionary[kMtAttachedCardLimit];
}

- (NSURL*)helpURL
{
    NSString *urlString = [_dictionary objectForKey:kMtHelpUrl];
    NSURL *url = nil;
    if(urlString && [urlString isKindOfClass:[NSString class]])
    {
        url = [NSURL URLWithString:urlString];
    }
    return url;
}

- (NSUInteger)mtSummDetectionCritetriaForLimitMax
{
    return [self mtSummDetectionCritetriaForLimit:kMax];
}

- (NSUInteger)mtSummDetectionCritetriaForLimitMin
{
    return [self mtSummDetectionCritetriaForLimit:KMin];
}

- (NSUInteger)mtSummDetectionCritetriaForLimit:(NSString *)key
{
    NSString * const keyPath = [NSString stringWithFormat:@"%@.%@",kMtSummDetectionCriteria,key];
    NSString * const number = [_dictionary valueForKeyPath:keyPath];

    return number ? (NSUInteger)number.integerValue : NSUIntegerMax;
}

- (NSArray *)mtTouchIdDevices
{
    if (!_mtTouchIdDevices)
    {
        NSDictionary *p2pTouchIdDevicesDic = _dictionary[@"mtTouchIdDevices"];
        _mtTouchIdDevices = p2pTouchIdDevicesDic[@"iOS"];
    }
    
    return _mtTouchIdDevices;
}

@end
