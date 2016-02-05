//
//  TCSP2PCard.m
//  TCSP2P
//
//  Created by a.v.kiselev on 31.07.13.
//  Copyright (c) 2013 “Tinkoff Credit Systems” Bank (closed joint-stock company). All rights reserved.
//

#import "TCSCard.h"
#import "TCSAPIStrings.h"
#import "TCSAPIDefinitions.h"

@implementation TCSCard

@synthesize name = _name;
@synthesize primary = _primary;
@synthesize cvcConfirmRequired = _cvcConfirmRequired;
@synthesize value = _value;
@synthesize statusCode = _statusCode;
@synthesize identifier = _identifier;
@synthesize numberShort = _numberShort;
@synthesize numberExtraShort = _numberExtraShort;
@synthesize expiration = _expiration;
@synthesize lcsCardInfo = _lcsCardInfo;

- (void)clearAllProperties
{
	_name = nil;
	_primary = NO;
    _cvcConfirmRequired = NO;
	_value = nil;
	_statusCode = nil;
    _numberShort = nil;
    _expiration = nil;
    _lcsCardInfo = nil;
}

- (NSString *)identifier
{
    if (!_identifier)
    {
        _identifier = [_dictionary objectForKey:TCSAPIKey_id];
    }
    
    return _identifier;
}

- (NSString *)value
{
    if (!_value)
    {
        _value = [_dictionary objectForKey:TCSAPIKey_value];
    }
    
    return _value;
}

- (NSString *)name
{
	if (!_name)
	{
		_name = [_dictionary objectForKey:TCSAPIKey_name];
	}

	return _name;
}

- (BOOL)primary
{
	if (!_primary)
	{
		_primary = [[_dictionary objectForKey:TCSAPIKey_primary] boolValue];
	}

	return _primary;
}

- (BOOL)cvcConfirmRequired
{
    if (!_cvcConfirmRequired)
    {
        _cvcConfirmRequired = [[_dictionary objectForKey:kCvcConfirmRequired] boolValue];
    }
    
    return _cvcConfirmRequired;
}

- (NSString *)statusCode
{
    return [_dictionary objectForKey:TCSAPIKey_statusCode];
}

- (NSString *)numberShort
{
    if (!_numberShort)
    {
        NSString *result = [TCSCard shortCardNumber:[self value] inFormat:@"**** %@"];
        _numberShort = result;
    }
	
	return _numberShort;
}

- (NSString *)numberExtraShort
{
    if (!_numberExtraShort)
    {
        NSString *result = [TCSCard shortCardNumber:[self value] inFormat:@"* %@"];
        _numberExtraShort = result;
    }
    
    return _numberExtraShort;
}

+ (NSString *)shortCardNumber:(NSString *)cardNumber inFormat:(NSString *)cardNumberFormat
{
    NSString *shortCardNumber = nil;
    
    if ([cardNumber length] > 4)
    {
        shortCardNumber = [cardNumber substringFromIndex:[cardNumber length] - 4];
    }
    
    return [NSString stringWithFormat:cardNumberFormat, shortCardNumber];
}

- (TCSMillisecondsTimestamp *)expiration
{
    if (!_expiration)
    {
        _expiration = [[TCSMillisecondsTimestamp alloc] initWithDictionary:_dictionary[TCSAPIKey_expiration]];
    }
    
    return _expiration;
}

- (TCSLCSCardInfo *)lcsCardInfo
{
    if (!_lcsCardInfo)
    {
        _lcsCardInfo = [[TCSLCSCardInfo alloc] initWithDictionary:_dictionary[TCSAPIKey_lcsCardInfo]];
    }
    
    return _lcsCardInfo;
}

@end
