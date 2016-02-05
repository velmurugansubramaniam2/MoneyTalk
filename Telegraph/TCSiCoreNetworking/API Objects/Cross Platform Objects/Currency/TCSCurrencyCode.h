//
//  TCSCurrency.h
//  TCSP2P
//
//  Created by a.v.kiselev on 31.07.13.
//  Copyright (c) 2013 “Tinkoff Credit Systems” Bank (closed joint-stock company). All rights reserved.
//

#import "TCSBaseObject.h"

///////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Currency Constants

#define kCurrencyRUB								@"RUB"
#define kCurrencyRUBIdentifier						@643

#define kCurrencyRUR								@"RUR"
#define kCurrencyRURIdentifier                      @643

#define kCurrencyEUR								@"EUR"
#define kCurrencyEURIdentifier                      @978

#define kCurrencyUSD								@"USD"
#define kCurrencyUSDIdentifier                      @840

@interface TCSCurrencyCode : TCSBaseObject

@property (nonatomic, strong, readonly) NSNumber * code;
@property (nonatomic, strong, readonly) NSString * name;

- (NSString *)character;

@end
