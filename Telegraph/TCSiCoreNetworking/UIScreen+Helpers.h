//
//  UIScreen+Helpers.h
//  TCSiCore
//
//  Created by a.v.kiselev on 04/06/15.
//  Copyright (c) 2015 “Tinkoff Credit Systems” Bank (closed joint-stock company). All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIScreen (Helpers)



+ (CGRect)mainScreenBounds;
+ (CGFloat)mainScreenHeight;
+ (NSString *)screenResolutionType;
+ (BOOL)retina;

+ (BOOL)isScreenHeight480;
+ (BOOL)isScreenHeight568;
+ (BOOL)isScreenHeight667;
+ (BOOL)isScreenHeight736;

@end
