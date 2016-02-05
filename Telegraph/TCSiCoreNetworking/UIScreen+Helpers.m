//
//  UIScreen+Helpers.m
//  TCSiCore
//
//  Created by a.v.kiselev on 04/06/15.
//  Copyright (c) 2015 “Tinkoff Credit Systems” Bank (closed joint-stock company). All rights reserved.
//

#import "UIScreen+Helpers.h"

@implementation UIScreen (Helpers)


+ (CGRect)mainScreenBounds
{
	return [[UIScreen mainScreen] bounds];
}

+ (CGFloat)mainScreenHeight
{
	return [self mainScreenBounds].size.height;
}

+ (NSString *)screenResolutionType
{
	CGFloat scale = [[UIScreen mainScreen]scale];

	if ([[UIScreen mainScreen]respondsToSelector:@selector(nativeScale)])
	{
		scale = [[UIScreen mainScreen]nativeScale];
	}

	if (scale < 2.0)
	{
		return @"mdpi";
	}

	if (scale < 2.5)
	{
		return @"xhdpi";
	}
	else
	{
		return @"xxhdpi";
	}
}

+ (BOOL)retina
{
	if ([[UIScreen mainScreen] respondsToSelector:@selector((scale))] == YES && [[UIScreen mainScreen] scale] >= 2.00)
	{
		return YES;
	}

	return NO;
}

+ (BOOL)isScreenHeight480
{
	BOOL isScreenHeight480 = [[UIScreen mainScreen] bounds].size.height == 480.0f;

	return isScreenHeight480;
}

+ (BOOL)isScreenHeight568
{
	BOOL isScreenHeight568 = [[UIScreen mainScreen] bounds].size.height == 568.0f;

	return isScreenHeight568;
}

+ (BOOL)isScreenHeight667
{
	BOOL isScreenHeight667 = [[UIScreen mainScreen] bounds].size.height == 667.0f;

	return isScreenHeight667;
}

+ (BOOL)isScreenHeight736
{
	BOOL isScreenHeight736 = [[UIScreen mainScreen] bounds].size.height == 736.0f;

	return isScreenHeight736;
}


@end
