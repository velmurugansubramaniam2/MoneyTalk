//
//  NSDateFormatter+Helpers.m
//  TCSiCore
//
//  Created by a.v.kiselev on 05/06/15.
//  Copyright (c) 2015 “Tinkoff Credit Systems” Bank (closed joint-stock company). All rights reserved.
//

#import "NSDateFormatter+Helpers.h"

@implementation NSDateFormatter (Helpers)

+ (NSDateFormatter *)dateFormatterRUEuropeMoscow
{
	static NSDateFormatter *dateFormatter = nil;

	if (!dateFormatter)
	{
		dateFormatter = [[NSDateFormatter alloc] init];
		dateFormatter.locale = [NSLocale localeWithLocaleIdentifier:@"ru-RU"];
		dateFormatter.timeZone = [NSTimeZone timeZoneWithName:@"Europe/Moscow"];
		dateFormatter.dateStyle = NSDateFormatterFullStyle;
	}

	return dateFormatter;
}

@end
