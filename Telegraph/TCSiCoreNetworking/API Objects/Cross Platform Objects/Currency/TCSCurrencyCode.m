//
//  TCSCurrency.m
//  TCSP2P
//
//  Created by a.v.kiselev on 31.07.13.
//  Copyright (c) 2013 “Tinkoff Credit Systems” Bank (closed joint-stock company). All rights reserved.
//

#import "TCSCurrencyCode.h"
#import "TCSAPIStrings.h"
#import "TCSAPIDefinitions.h"

@implementation TCSCurrencyCode

@synthesize code = _code;
@synthesize name = _name;

- (void)clearAllProperties
{
	_code = nil;
	_name = nil;
}

- (NSNumber *)code
{
	if (!_code)
	{
		_code = [_dictionary objectForKey:kCode];
	}

	return _code;
}

- (NSString *)name
{
	if (!_name)
	{
		_name = [_dictionary objectForKey:TCSAPIKey_name];
	}

	return _name;
}

- (BOOL)isEqual:(id)object
{
    if (![object isKindOfClass:self.class])
    {
        return NO;
    }
    
    TCSCurrencyCode * anotherObject = (TCSCurrencyCode *)object;
    return ([self.name isEqualToString:anotherObject.name] && [self.code isEqualToNumber:anotherObject.code]);
}

- (NSString *)character
{
    NSString *result = [self name];
    
    if ([[self code]  isEqual: kCurrencyRUBIdentifier])
    {
        result = @"₽";
    }
    else if ([[self code] isEqual:kCurrencyUSDIdentifier])
    {
        result = @"$";
    }
    else if ([[self code] isEqual:kCurrencyEURIdentifier])
    {
        result = @"€";
    }
    
    return result;
}

@end
