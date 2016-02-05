//
//  NSDate+Calendar.m
//  TCSMBiOS
//
//  Created by Вячеслав Владимирович Будников on 23.10.14.
//  Copyright (c) 2014 “Tinkoff Credit Systems” Bank (closed joint-stock company). All rights reserved.
//

#import "NSDate+Calendar.h"
#import "NSCalendar+Helpers.h"

@implementation NSDate (Calendar)

#pragma mark - Checkers

- (BOOL)isToday
{
	return [self isSameDay:[NSDate date]];
}

- (BOOL)isYesterday
{
	NSCalendar *calendar = [NSCalendar gregorianCalendarRUMoscow];
	NSDateComponents *components = [calendar components:(NSCalendarUnit)( NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit ) fromDate:self];

	[components setDay:([components day] - 1)];
	NSDate *yesterday = [calendar dateFromComponents:components];
	return [self isSameDay:yesterday];
}

- (BOOL)isSameDay:(NSDate *)anotherDate
{
	NSCalendar *calendar = [NSCalendar gregorianCalendarRUMoscow];
	NSDateComponents *components1 = [calendar components:(NSCalendarUnit)(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit) fromDate:self];
	NSDateComponents *components2 = [calendar components:(NSCalendarUnit)(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit) fromDate:anotherDate];
	return ([components1 year] == [components2 year] && [components1 month] == [components2 month] && [components1 day] == [components2 day]);
}

- (BOOL)isSameYear:(NSDate *)anotherDate
{
	NSCalendar *calendar = [NSCalendar gregorianCalendarRUMoscow];
	NSDateComponents *components1 = [calendar components:(NSCalendarUnit)(NSYearCalendarUnit) fromDate:self];
	NSDateComponents *components2 = [calendar components:(NSCalendarUnit)(NSYearCalendarUnit) fromDate:anotherDate];
	return ([components1 year] == [components2 year]);
}




#pragma mark - NSTimeInterval Shortcuts

- (NSTimeInterval)timeIntervalInMilliseconds
{
	NSTimeInterval timeStamp = [self timeIntervalSince1970];
	timeStamp = timeStamp * (NSTimeInterval)1000;
	timeStamp = ceil(timeStamp);

	return timeStamp;
}




#pragma mark - NSDate Shortcuts

- (NSDate *)beginningOfDay
{
	NSCalendar *currentCalendar = [NSCalendar gregorianCalendarRUMoscow];
	NSDateComponents *components = [currentCalendar components:(NSCalendarUnit)( NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit ) fromDate:self];
	
	[components setHour:0];
	[components setMinute:0];
	[components setSecond:0];
	
	return [currentCalendar dateFromComponents:components];
}

- (NSDate *)endOfDay
{
	NSCalendar *currentCalendar = [NSCalendar gregorianCalendarRUMoscow];
	NSDateComponents *components = [currentCalendar components:(NSCalendarUnit)( NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit ) fromDate:self];

	[components setHour:23];
	[components setMinute:59];
	[components setSecond:59];
	
    NSDate *date = [currentCalendar dateFromComponents:components];
	
    return date;
}

- (NSDate *)firstOfMonth
{
	NSCalendar *calendar = [NSCalendar gregorianCalendarRUMoscow];
	NSDateComponents *comp = [calendar components:(NSCalendarUnit)( NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit ) fromDate:self];
	
	[comp setDay:1];
	NSDate *date = [calendar dateFromComponents:comp];
	
	return [date beginningOfDay];
}

- (NSDate *)nextSecond
{
	NSCalendar *currentCalendar = [NSCalendar gregorianCalendarRUMoscow];
	NSDateComponents *components = [currentCalendar components:(NSCalendarUnit)( NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit ) fromDate:self];
	
	components.second += 1;
	
	return [currentCalendar dateFromComponents:components];
}

- (NSDate *)nextMonth
{
	NSCalendar *calendar = [NSCalendar gregorianCalendarRUMoscow];
	NSDateComponents *components = [calendar components:(NSCalendarUnit)( NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit ) fromDate:self];
	[components setDay:1];
	[components setMonth:[components month] + 1];
	
	return [calendar dateFromComponents:components];
}

- (NSDate *)previousMonth
{
	NSCalendar *calendar = [NSCalendar gregorianCalendarRUMoscow];
	NSDateComponents *components = [calendar components:(NSCalendarUnit)( NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit ) fromDate:self];
	
	[components setDay:1];
	[components setMonth:([components month] - 1)];
	
	return [calendar dateFromComponents:components];
}

- (NSDate *)lastOfMonthDate
{
	NSCalendar *calendar = [NSCalendar gregorianCalendarRUMoscow];
	NSDateComponents *components = [calendar components:(NSCalendarUnit)( NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit ) fromDate:self];
	
	NSRange daysRange = [calendar rangeOfUnit:NSDayCalendarUnit inUnit:NSMonthCalendarUnit forDate:self];
	[components setDay:(NSInteger)daysRange.length];
	
	NSDate *date = [calendar dateFromComponents:components];
	
	return [date endOfDay];
}

- (NSDate *)timelessDate
{
	NSCalendar *calendar = [NSCalendar gregorianCalendarRUMoscow];
	NSDateComponents *components = [calendar components:(NSCalendarUnit)(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit) fromDate:self];
	
	return [calendar dateFromComponents:components];
}




#pragma mark - NSDate with math

- (NSDate *)dateMinusYears:(NSInteger)years
{
	NSDateComponents *components = [[NSDateComponents alloc] init];
	[components setYear:-years];

	NSDate *date = [[NSCalendar gregorianCalendarRUMoscow] dateByAddingComponents:components toDate:self options:0];

	return date;
}

- (NSDate *)dateNextWithMonthDay:(NSUInteger)day
{
	NSDate *nextPayment;

	NSCalendar * calendar = [NSCalendar gregorianCalendarRUMoscow];
	[calendar setFirstWeekday:0];
	NSDate * date = self;
	NSDateComponents * dc = [calendar components:(NSDayCalendarUnit|NSMonthCalendarUnit|NSYearCalendarUnit) fromDate:date];

	if (day==31)
	{
		dc.day = 0;
		dc.month = dc.month+1;
		nextPayment = [calendar dateFromComponents:dc];
		if ([nextPayment earlierDate:date] == nextPayment)
		{
			dc = [calendar components:(NSDayCalendarUnit|NSMonthCalendarUnit|NSYearCalendarUnit) fromDate:nextPayment];
			dc.month = dc.month + 2;
			dc.day = 0;
			nextPayment = [calendar dateFromComponents:dc];
		}
	}
	else
	{
		dc.day = day;
		nextPayment = [calendar dateFromComponents:dc];
		if ([nextPayment earlierDate:date] == nextPayment)
		{
			dc = [[NSDateComponents alloc]init];
			dc.month = 1;
			nextPayment = [calendar dateByAddingComponents:dc toDate:nextPayment options:0];
		}
	}

	return nextPayment;
}

- (NSDate *)dateNextWithWeekDay:(NSUInteger)day
{
	NSDate *nextPayment;

	NSCalendar * calendar = [NSCalendar gregorianCalendarRUMoscow];
	[calendar setFirstWeekday:0];
	NSDate * date = self;

	NSDateComponents *dc = [calendar components:(NSWeekdayCalendarUnit|NSWeekCalendarUnit|NSMonthCalendarUnit|NSYearCalendarUnit) fromDate:date];
	[dc setWeekday:(NSInteger)(day + 1)];
	nextPayment = [calendar dateFromComponents:dc];

	if ([nextPayment earlierDate:date] == nextPayment)
	{
		nextPayment=[nextPayment dateByAddingTimeInterval:7*24*60*60];
	}

	return nextPayment;
}




#pragma mark - Units count

- (NSUInteger)daysInCurrentYear
{
	NSDate *someDate = self;

	NSDate *beginningOfYear;
	NSTimeInterval lengthOfYear;
	NSCalendar *gregorian = [NSCalendar gregorianCalendarRUMoscow];
	[gregorian rangeOfUnit:NSYearCalendarUnit
				 startDate:&beginningOfYear
				  interval:&lengthOfYear
				   forDate:someDate];
	NSDate *nextYear = [beginningOfYear dateByAddingTimeInterval:lengthOfYear];
	NSUInteger startDay = [gregorian ordinalityOfUnit:NSDayCalendarUnit
											   inUnit:NSEraCalendarUnit
											  forDate:beginningOfYear];
	NSUInteger endDay = [gregorian ordinalityOfUnit:NSDayCalendarUnit
											 inUnit:NSEraCalendarUnit
											forDate:nextYear];

	return endDay - startDay;
}

- (NSUInteger)daysInCurrentMonth
{
	NSDate *today = self;
	NSCalendar *c = [NSCalendar gregorianCalendarRUMoscow];
	NSRange days = [c rangeOfUnit:NSDayCalendarUnit
						   inUnit:NSMonthCalendarUnit
						  forDate:today];
	return days.length;
}




#pragma mark - Current units

- (NSUInteger)currentYear
{
	NSCalendar *calendar = [NSCalendar gregorianCalendarRUMoscow];
	NSDateComponents *dateComponents = [calendar components:NSYearCalendarUnit fromDate:self];

	return dateComponents.year;
}

- (NSUInteger)currentMonth
{
	NSCalendar *calendar = [NSCalendar gregorianCalendarRUMoscow];
	NSDateComponents *dateComponents = [calendar components:NSMonthCalendarUnit fromDate:self];

	return dateComponents.month;
}




#pragma mark - Date Components

- (NSDateComponents *)dateComponentsOfDiffrenceFromDate:(NSDate *)toDate
{
	NSDate *startDate = self;
	NSDate *endDate = toDate;

	NSCalendar *calendar = [NSCalendar gregorianCalendarRUMoscow];
	unsigned flags = NSMinuteCalendarUnit | NSHourCalendarUnit | NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit;
	NSDateComponents *difference = [calendar components:flags fromDate:startDate toDate:endDate options:0];

	return difference;
}

- (NSDateComponents *)dateComponents:(NSCalendarUnit)calendarUnits
{
	NSCalendar *calendar = [NSCalendar gregorianCalendarRUMoscow];

	return [calendar components:calendarUnits fromDate:self];
}

- (NSDateComponents *)dateComponentsCommon
{
	unsigned flags = NSMinuteCalendarUnit| NSHourCalendarUnit | NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit;

	return [self dateComponents:flags];
}

+ (NSInteger)daysDiffrenceFromDate:(NSTimeInterval)date1 second:(NSTimeInterval)date2
{
    return 	(NSInteger)(fabs(date1 - date2)/(60*60*24));
}

+ (NSInteger)secondDiffrenceFromDate:(NSTimeInterval)date1 second:(NSTimeInterval)date2
{
    // Manage Date Formation same for both dates
    NSInteger difference = (NSInteger)fabs(date2 - date1);
    
    return difference;
}

+ (NSDateComponents *)dateDiffrenceFromDate:(NSTimeInterval)date1 second:(NSTimeInterval)date2
{
    // Manage Date Formation same for both dates
    NSDate *startDate = [NSDate dateWithTimeIntervalSince1970:date1];
    NSDate *endDate = [NSDate dateWithTimeIntervalSince1970:date2];
    
    
    NSCalendar *calendar = [NSCalendar gregorianCalendarRUMoscow];
    unsigned flags = NSMinuteCalendarUnit | NSHourCalendarUnit | NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit;
    NSDateComponents *difference = [calendar components:flags fromDate:startDate toDate:endDate options:0];
    
    return difference;
}

@end
