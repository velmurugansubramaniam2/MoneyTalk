//
//  NSCharacterSet+Helpers.m
//  TCSiCore
//
//  Created by a.v.kiselev on 05/06/15.
//  Copyright (c) 2015 “Tinkoff Credit Systems” Bank (closed joint-stock company). All rights reserved.
//

#import "NSCharacterSet+Helpers.h"

@implementation NSCharacterSet (Helpers)

- (void)printToConsole
{
	unichar unicharBuffer[20];
	NSUInteger index = 0;

	for (unichar uc = 0; uc < (0xFFFF); uc ++)
	{
		if ([self characterIsMember:uc])
		{
			unicharBuffer[index] = uc;

			index ++;

			if (index == 20)
			{
				NSString * characters = [NSString stringWithCharacters:unicharBuffer length:index];
				NSLog(@"%@", characters);

				index = 0;
			}
		}
	}

	if (index != 0)
	{
		NSString * characters = [NSString stringWithCharacters:unicharBuffer length:index];
		NSLog(@"%@", characters);
	}
}

+ (NSCharacterSet *)characterSetAllExceptDecimalDigits
{
	static NSCharacterSet * characterSetExceptDigits;

	if (!characterSetExceptDigits)
	{
		characterSetExceptDigits = [[NSCharacterSet decimalDigitCharacterSet] invertedSet];
	}

	return characterSetExceptDigits;
}

@end
