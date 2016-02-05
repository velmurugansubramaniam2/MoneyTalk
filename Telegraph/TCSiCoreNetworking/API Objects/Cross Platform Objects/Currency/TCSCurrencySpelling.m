//
//  TCSCurrencySpelling.m
//  TCSP2P
//
//  Created by Gleb Ustimenko on 8/21/13.
//  Copyright (c) 2013 “Tinkoff Credit Systems” Bank (closed joint-stock company). All rights reserved.
//

#import "TCSCurrencySpelling.h"
#import "TCSAPIDefinitions.h"

@implementation TCSCurrencySpelling

@synthesize plural = _plural;
@synthesize fullName = _fullName;
@synthesize shortMillion = _shortMillion;
@synthesize shortThousand = _shortThousand;
@synthesize shortName = _shortName;

- (void)clearAllProperties
{
    _plural = nil;
    _fullName = nil;
    _shortMillion = nil;
    _shortThousand = nil;
    _shortName = nil;
}

- (NSString *)plural
{
    if (!_plural)
    {
        _plural = [_dictionary objectForKey:kPlural];
    }
    
    return _plural;
}



- (NSString *)fullName
{
    if (!_fullName)
    {
        _fullName = [_dictionary objectForKey:kFullName];
    }
    
    return _fullName;
}

- (NSString *)shortMillion
{
    if (!_shortMillion)
    {
        _shortMillion = [_dictionary objectForKey:kShortMillion];
    }
    
    return _shortMillion;
}

- (NSString *)shortThousand
{
    if (!_shortThousand)
    {
        _shortThousand = [_dictionary objectForKey:kShortThousand];
    }
    
    return _shortThousand;
}

- (NSString *)shortName
{
    if (!_shortName)
    {
        _shortName = [_dictionary objectForKey:kShortName];
    }
    
    return _shortName;
}

@end
