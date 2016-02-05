//
//  NSUserDefaults+TCSNSDate.m
//  MT
//
//  Created by Andrey Ilskiy on 24/02/15.
//  Copyright (c) 2015 “Tinkoff Credit Systems” Bank (closed joint-stock company). All rights reserved.
//

#import "NSUserDefaults+TCSNSDate.h"

@implementation NSUserDefaults (TCSNSDate)

- (NSDate *)dateForKey:(NSString *)defaultName
{
    const NSTimeInterval timeInterval = (NSTimeInterval)[self doubleForKey:defaultName];
    return [NSDate dateWithTimeIntervalSince1970:timeInterval];
}

- (void)setDate:(NSDate *)value forKey:(NSString *)defaultName
{
    [self setDouble:(double)value.timeIntervalSince1970 forKey:defaultName];
}

+ (NSDate *)standardUserDefaultsDateForKey:(NSString *)defaultName
{
    return [[NSUserDefaults standardUserDefaults] dateForKey:defaultName];
}

+ (void)standardUserDefaultsSynchronizeDate:(NSDate *)value forKey:(NSString *)defaultName
{
    NSUserDefaults * const standardUserDefaults = [NSUserDefaults standardUserDefaults];
    [standardUserDefaults setDate:value forKey:defaultName];
    [standardUserDefaults synchronize];
}

@end
