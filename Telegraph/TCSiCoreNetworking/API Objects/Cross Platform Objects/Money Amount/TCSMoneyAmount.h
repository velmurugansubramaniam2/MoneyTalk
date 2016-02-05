//
//  TCSMoneyAmount.h
//  TCSP2P
//
//  Created by a.v.kiselev on 31.07.13.
//  Copyright (c) 2013 “Tinkoff Credit Systems” Bank (closed joint-stock company). All rights reserved.
//

#import "TCSBaseObject.h"
#import "TCSCurrencyCode.h"

@interface TCSMoneyAmount : TCSBaseObject

@property (nonatomic, strong, readonly) TCSCurrencyCode * currency;
@property (nonatomic, strong, readonly) NSNumber * value;


@end
