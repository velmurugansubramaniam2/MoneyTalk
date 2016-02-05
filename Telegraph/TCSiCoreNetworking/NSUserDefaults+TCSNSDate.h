//
//  NSUserDefaults+TCSNSDate.h
//  MT
//
//  Created by Andrey Ilskiy on 24/02/15.
//  Copyright (c) 2015 “Tinkoff Credit Systems” Bank (closed joint-stock company). All rights reserved.
//

#import <Foundation/Foundation.h>

@class NSDate;

@interface NSUserDefaults (TCSNSDate)

- (NSDate *)dateForKey:(NSString *)defaultName;
- (void)setDate:(NSDate *)value forKey:(NSString *)defaultName;

+ (NSDate *)standardUserDefaultsDateForKey:(NSString *)defaultName;

+ (void)standardUserDefaultsSynchronizeDate:(NSDate *)value forKey:(NSString *)defaultName;

@end
