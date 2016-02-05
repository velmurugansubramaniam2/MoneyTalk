//
//  TCSP2PBaseCurrency.m
//  TCSP2P
//
//  Created by Gleb Ustimenko on 8/21/13.
//  Copyright (c) 2013 “Tinkoff Credit Systems” Bank (closed joint-stock company). All rights reserved.
//

#import "TCSCurrency.h"
#import "TCSAPIDefinitions.h"

@implementation TCSCurrency

@synthesize spelling = _spelling;
@synthesize format = _format;
@synthesize precision = _precision;
@synthesize symbol = _symbol;
@synthesize currencyCode = _currencyCode;

- (void)clearAllProperties
{
    _spelling = nil;
    _format = nil;
    _precision = nil;
    _symbol = nil;
    _currencyCode = nil;
}

- (TCSCurrencySpelling *)spelling
{
    if (!_spelling)
	{
		_spelling = [[TCSCurrencySpelling alloc] initWithDictionary:[_dictionary objectForKey:kSpelling]];
	}
    
	return _spelling;
}

- (NSString *)format
{
    if (!_format)
    {
        _format = [_dictionary objectForKey:kFormat];
    }
    
    return _format;
}

- (NSString *)precision
{
    if (!_precision)
    {
        _precision = [_dictionary objectForKey:kPrecision];
    }
    
    return _precision;
}

- (NSString *)symbol
{
    if (!_symbol)
    {
        _symbol = [_dictionary objectForKey:kSymbol];
    }
    
    return _symbol;
}

- (TCSCurrencyCode *)currencyCode
{
    if (!_currencyCode)
	{
		_currencyCode = [[TCSCurrencyCode alloc]initWithDictionary:[_dictionary objectForKey:kCurrency]];
	}
    
	return _currencyCode;
}

+ (NSDictionary *)roubleInfo;
{
	static NSDictionary *roubleInfo = nil;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{ roubleInfo = @{ kCode : @643, kName : @"RUB" }; });
	
	return roubleInfo;
}

@end
