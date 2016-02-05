//
//  TCSCurrenciesList.m
//  TCSP2P
//
//  Created by Alexey on 22.08.13.
//  Copyright (c) 2013 “Tinkoff Credit Systems” Bank (closed joint-stock company). All rights reserved.
//

#import "TCSCurrenciesList.h"
#import "TCSAPIStrings.h"


@implementation TCSCurrenciesList

@synthesize currenciesArray = _currenciesArray;
@synthesize lastUpdate = _lastUpdate;

-(void)clearAllProperties
{
    _currenciesArray = nil;
}

-  (NSArray *)currenciesArray
{
    if (!_currenciesArray)
    {
        NSArray *dictionariesArray = [_dictionary objectForKey:TCSAPIKey_payload];
        NSMutableArray * currenciesArray = [NSMutableArray array];
        
        for (NSDictionary *currenyDictionary in dictionariesArray)
        {
            [currenciesArray addObject:[[TCSCurrency alloc] initWithDictionary:currenyDictionary]];
        }
        
        _currenciesArray = [NSArray arrayWithArray:currenciesArray];
    }
    
    return _currenciesArray;
}

@end
