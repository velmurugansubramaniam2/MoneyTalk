//
//  TCSMoneyAmount.m
//  TCSP2P
//
//  Created by a.v.kiselev on 31.07.13.
//  Copyright (c) 2013 “Tinkoff Credit Systems” Bank (closed joint-stock company). All rights reserved.
//

#import "TCSMoneyAmount.h"
#import "TCSAPIStrings.h"
#import "TCSAPIDefinitions.h"

@implementation TCSMoneyAmount

@synthesize currency = _currency;
@synthesize value = _value;

- (void)clearAllProperties
{
	_value = nil;
	_currency = nil;
}

- (TCSCurrencyCode *)currency
{
	if (!_currency)
	{
		_currency = [[TCSCurrencyCode alloc]initWithDictionary:[_dictionary objectForKey:kCurrency]];
	}

	return _currency;
}

- (NSNumber *)value
{
	if (!_value)
	{
		// to 2 digits
		NSString *asString = [NSString stringWithFormat:@"%.2f", [[_dictionary objectForKey:TCSAPIKey_value] floatValue]];
		_value = @([asString floatValue]);
	}

	return _value;
}

@end
