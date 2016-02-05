//
//  NSDate+Calendar.h
//  TCSMBiOS
//
//  Created by Вячеслав Владимирович Будников on 23.10.14.
//  Copyright (c) 2014 “Tinkoff Credit Systems” Bank (closed joint-stock company). All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDate (Calendar)

#pragma mark - Checkers

- (BOOL)isToday;
- (BOOL)isYesterday;
- (BOOL)isSameDay:(NSDate *)anotherDate;
- (BOOL)isSameYear:(NSDate *)anotherDate;

#pragma mark - NSTimeInterval Shortcuts

- (NSTimeInterval)timeIntervalInMilliseconds;

#pragma mark - NSDate Shortcuts

- (NSDate *)firstOfMonth;
- (NSDate *)nextSecond;
- (NSDate *)nextMonth;
- (NSDate *)previousMonth;
- (NSDate *)timelessDate;
- (NSDate *)beginningOfDay;
- (NSDate *)endOfDay;
- (NSDate *)lastOfMonthDate;

#pragma mark - NSDate with math

- (NSDate *)dateMinusYears:(NSInteger)years;
- (NSDate *)dateNextWithMonthDay:(NSUInteger)day;
- (NSDate *)dateNextWithWeekDay:(NSUInteger)day;

#pragma mark - Units count

- (NSUInteger)daysInCurrentYear;
- (NSUInteger)daysInCurrentMonth;

#pragma mark - Current units

- (NSUInteger)currentYear;
- (NSUInteger)currentMonth;

#pragma mark - Date Components

- (NSDateComponents *)dateComponentsOfDiffrenceFromDate:(NSDate *)toDate;
- (NSDateComponents *)dateComponents:(NSCalendarUnit)calendarUnits;
- (NSDateComponents *)dateComponentsCommon;

+ (NSInteger)daysDiffrenceFromDate:(NSTimeInterval)date1 second:(NSTimeInterval)date2;
+ (NSInteger)secondDiffrenceFromDate:(NSTimeInterval)date1 second:(NSTimeInterval)date2;
+ (NSDateComponents *)dateDiffrenceFromDate:(NSTimeInterval)date1 second:(NSTimeInterval)date2;

@end
