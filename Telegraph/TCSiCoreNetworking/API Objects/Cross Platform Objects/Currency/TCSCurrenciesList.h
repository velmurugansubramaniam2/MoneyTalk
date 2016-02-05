//
//  TCSCurrenciesList.h
//  TCSP2P
//
//  Created by Alexey on 22.08.13.
//  Copyright (c) 2013 “Tinkoff Credit Systems” Bank (closed joint-stock company). All rights reserved.
//

#import "TCSBaseObject.h"
#import "TCSCurrency.h"

@interface TCSCurrenciesList : TCSBaseObject

@property (nonatomic, strong, readonly) NSArray * currenciesArray;
@property (nonatomic, strong) NSDate * lastUpdate;

@end
