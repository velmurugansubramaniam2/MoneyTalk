//
//  UIDevice+Helpers.h
//  TCSiCore
//
//  Created by a.v.kiselev on 04/06/15.
//  Copyright (c) 2015 “Tinkoff Credit Systems” Bank (closed joint-stock company). All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIDevice (Helpers)

+ (CGFloat)systemVersion_;
+ (NSString *)deviceModel;
+ (NSString *)deviceOS;
+ (NSString *)deviceModelName;
+ (NSString *)deviceId;
+ (NSString *)platform;
+ (NSString *)rootCheck;

+ (BOOL)iOS7OrLater;
+ (BOOL)iOS8OrLater;


@end
