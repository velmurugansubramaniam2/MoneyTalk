//
//  NSCalendar+Helpers.m
//  TCSiCore
//
//  Created by a.v.kiselev on 05/06/15.
//  Copyright (c) 2015 “Tinkoff Credit Systems” Bank (closed joint-stock company). All rights reserved.
//

#import "NSCalendar+Helpers.h"

@implementation NSCalendar (Helpers)

+ (NSCalendar *)gregorianCalendarRUMoscow
{
	static NSCalendar *calendar = nil;

	if (!calendar)
	{
		calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
		calendar.locale = [NSLocale localeWithLocaleIdentifier:@"ru-RU"];
		calendar.timeZone = [NSTimeZone timeZoneWithName:@"Europe/Moscow"];
	}

	return calendar;
}

@end
