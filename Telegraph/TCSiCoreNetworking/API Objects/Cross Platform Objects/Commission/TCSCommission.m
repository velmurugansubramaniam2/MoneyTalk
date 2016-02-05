//
//  TCSCommission.m
//  TCSP2P
//
//  Created by Max Zhdanov on 27.08.13.
//  Copyright (c) 2013 “Tinkoff Credit Systems” Bank (closed joint-stock company). All rights reserved.
//

#import "TCSCommission.h"
#import "TCSAPIStrings.h"
#import "TCSAPIDefinitions.h"

@implementation TCSCommission

@synthesize providerId         = _providerId;
@synthesize description        = _description;
@synthesize commissionCurrency = _commissionCurrency;
@synthesize totalCurrency      = _totalCurrency;
@synthesize commissionAmount   = _commissionAmount;
@synthesize totalAmount        = _totalAmount;
@synthesize minAmount          = _minAmount;
@synthesize maxAmount          = _maxAmount;
@synthesize limitAmount        = _limitAmount;

- (instancetype)initWithDictionary:(NSDictionary *)dictionary
{
	self = [super initWithDictionary:dictionary];
	
		// Primitive partial dictionary validation (needed for MCP project logic)
	if (!dictionary[kDescription])   { self = nil; }
	if (!dictionary[kMinAmount])     { self = nil; }
	if (!dictionary[kMaxAmount])     { self = nil; }
	if (!dictionary[TCSAPIKey_value][TCSAPIKey_value]) { self = nil; }
	
	return self;
}

- (void)clearAllProperties
{
    _providerId         = nil;
    _description        = nil;
    _commissionCurrency = nil;
    _totalCurrency      = nil;
    _commissionAmount   = nil;
    _totalAmount        = nil;
    _minAmount          = nil;
    _maxAmount          = nil;
    _limitAmount        = nil;
}

- (NSString *)providerId
{
    if (_providerId == nil)
    {
        _providerId = [_dictionary objectForKey:kProviderId];
    }
    
    return _providerId;
}

- (NSString *)description
{
    if (_description == nil)
    {
        _description = [_dictionary objectForKey:kDescription];
    }
    
    return _description;
}

- (TCSCurrency *)commissionCurrency
{
    if (_commissionCurrency == nil)
    {
        _commissionCurrency = [[TCSCurrency alloc] initWithDictionary:[_dictionary objectForKey:TCSAPIKey_value]];
    }
    
    return _commissionCurrency;
}

- (TCSCurrency *)totalCurrency
{
    if (_totalCurrency == nil)
    {
        _totalCurrency = [[TCSCurrency alloc] initWithDictionary:[[_dictionary objectForKey:kTotal] objectForKey:kCurrency]];
    }
    
    return _totalCurrency;
}

- (NSNumber *)commissionAmount
{
    if (_commissionAmount == nil)
    {
        _commissionAmount = [[_dictionary objectForKey:TCSAPIKey_value] objectForKey:TCSAPIKey_value];
    }
    
    return _commissionAmount;
}

- (NSNumber *)totalAmount
{
    if (_totalAmount == nil)
    {
        _totalAmount = [[_dictionary objectForKey:kTotal] objectForKey:TCSAPIKey_value];
    }
    
    return _totalAmount;
}

- (NSNumber *)minAmount
{
    if (_minAmount == nil)
    {
        _minAmount = [_dictionary objectForKey:kMinAmount];
    }
    
    return _minAmount;
}

- (NSNumber *)maxAmount
{
    if (_maxAmount == nil)
    {
        _maxAmount = [_dictionary objectForKey:kMaxAmount];
    }
    
    return _maxAmount;
}

- (NSNumber *)limitAmount
{
    if (_limitAmount == nil)
    {
        _limitAmount = [_dictionary objectForKey:kLimit];
    }
    
    return _limitAmount;
}

@end
