//
//  TCSPhoneNumber.m
//  TCSP2P
//
//  Created by a.v.kiselev on 15.10.13.
//  Copyright (c) 2013 “Tinkoff Credit Systems” Bank (closed joint-stock company). All rights reserved.
//

#import "TCSPhoneNumber.h"
#import "TCSAPIDefinitions.h"

@implementation TCSPhoneNumber

@synthesize countryCode = _countryCode;
@synthesize innerCode = _innerCode;
@synthesize number = _number;

- (void)clearAllProperties
{
	_countryCode = nil;
	_innerCode = nil;
	_number = nil;
}

- (NSNumber *)countryCode
{
	if (!_countryCode)
	{
		_countryCode = [_dictionary objectForKey:kCountryCode];
	}

	return _countryCode;
}

- (NSNumber *)innerCode
{
	if (!_innerCode)
	{
		_innerCode = [_dictionary objectForKey:kInnerCode];
	}

	return _innerCode;
}

- (NSString *)number
{
	if (!_number)
	{
		_number = [_dictionary objectForKey:kNumber];
	}

	return _number;
}

- (NSString *)forrmatedNumber
{
    NSMutableArray *chunks = [NSMutableArray new];
    
    if (!self.number)
    {
        return @"";
    }
    
    if (self.countryCode)
    {
        [chunks addObject:@"+"];
        [chunks addObject:self.countryCode];
    }
    
    if (self.innerCode)
    {
        [chunks addObject:self.innerCode];
    }
    
    [chunks addObject:self.number];
    
    return [chunks componentsJoinedByString:@""];
}


@end
