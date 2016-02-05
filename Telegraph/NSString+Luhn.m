//
//  NSString.m
//  TCSP2PiPhone
//
//  Created by a.v.kiselev on 17.04.13.
//  Copyright (c) 2013 “Tinkoff Credit Systems” Bank (closed joint-stock company). All rights reserved.
//

#import "NSString+Luhn.h"

@implementation NSString(Luhn)

- (NSMutableArray *) toCharArray
{
	NSMutableArray *characters = [[NSMutableArray alloc] initWithCapacity:[self length]];
	for (NSUInteger i=0; i < [self length]; i++) {
		NSString *ichar  = [NSString stringWithFormat:@"%c", [self characterAtIndex:i]];
		[characters addObject:ichar];
	}
    
	return characters;
}

+ (BOOL) luhnCheck:(NSString *)stringToTest
{
    if (![stringToTest length])
    {
        return NO;
    }
    
	NSMutableArray *stringAsChars = [stringToTest toCharArray];
    
	BOOL isOdd = YES;
	int oddSum = 0;
	int evenSum = 0;
    
	for (NSInteger i = (NSInteger)[stringToTest length] - 1; i >= 0; i--) {
        
		int digit = [(NSString *)[stringAsChars objectAtIndex:(NSUInteger)i] intValue];
        
		if (isOdd)
			oddSum += digit;
		else
			evenSum += digit/5 + (2*digit) % 10;
        
		isOdd = !isOdd;
	}
    
	return ((oddSum + evenSum) % 10 == 0);
}
@end
