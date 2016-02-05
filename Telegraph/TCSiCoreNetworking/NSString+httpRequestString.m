//
//  NSString+httpRequestString.m
//  TCSiCore
//
//  Created by a.v.kiselev on 05/06/15.
//  Copyright (c) 2015 “Tinkoff Credit Systems” Bank (closed joint-stock company). All rights reserved.
//

#import "NSString+httpRequestString.h"

@implementation NSString (httpRequestString)

- (NSString *)stringWithServiceNameFromURLString
{
	//	asdfkjshf/servicename?fsgsgadfsdf
	NSString * url = self;
	NSArray * components = [url componentsSeparatedByString:@"?"];

	if (components)
	{
		url = components[0];
	}

	components = [url componentsSeparatedByString:@"/"];
	if (components)
	{
		url = [components lastObject];
	}

	return url;
}

- (NSString *)stringFromURLStringWithValueForParameter:(NSString *)parameter
{
	NSString * parameterValue = nil;
	NSString * urlString = self;

	NSRange locationOfParameter = [urlString rangeOfString:[NSString stringWithFormat:@"%@=",parameter]];

	if (locationOfParameter.location != NSNotFound)
	{
		NSString * rightPartFromParameter = [urlString substringFromIndex:locationOfParameter.location+locationOfParameter.length];
		NSArray * componentsOfString = [rightPartFromParameter componentsSeparatedByString:@"&"];

		if (componentsOfString && componentsOfString.count > 0)
		{
			parameterValue = componentsOfString[0];
		}
	}

	return parameterValue;
}

@end
