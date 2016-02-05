//
//  TCSP2PBaseCurrency.h
//  TCSP2P
//
//  Created by Gleb Ustimenko on 8/21/13.
//  Copyright (c) 2013 “Tinkoff Credit Systems” Bank (closed joint-stock company). All rights reserved.
//

#import "TCSBaseObject.h"
#import "TCSCurrencyCode.h"
#import "TCSCurrencySpelling.h"

@interface TCSCurrency : TCSBaseObject

@property (nonatomic, strong, readonly) TCSCurrencySpelling *spelling;
@property (nonatomic, strong, readonly) NSString *format;
@property (nonatomic, strong, readonly) NSString *precision;
@property (nonatomic, strong, readonly) NSString *symbol;
@property (nonatomic, strong, readonly) TCSCurrencyCode *currencyCode;

+ (NSDictionary *)roubleInfo;

@end
