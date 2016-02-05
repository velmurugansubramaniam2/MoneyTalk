//
//  TCSCommission.h
//  TCSP2P
//
//  Created by Max Zhdanov on 27.08.13.
//  Copyright (c) 2013 “Tinkoff Credit Systems” Bank (closed joint-stock company). All rights reserved.
//

#import "TCSBaseObject.h"
#import "TCSCurrency.h"

@interface TCSCommission : TCSBaseObject

@property (nonatomic,strong,readonly) NSString    *providerId;
@property (nonatomic,strong,readonly) NSString    *description; // Errorprone - overrides NSObject method TODO: rename
@property (nonatomic,strong,readonly) TCSCurrency *commissionCurrency;
@property (nonatomic,strong,readonly) TCSCurrency *totalCurrency;
@property (nonatomic,strong,readonly) NSNumber    *commissionAmount;
@property (nonatomic,strong,readonly) NSNumber    *totalAmount;
@property (nonatomic,strong,readonly) NSNumber    *minAmount;
@property (nonatomic,strong,readonly) NSNumber    *maxAmount;
@property (nonatomic,strong,readonly) NSNumber    *limitAmount;


//{"payload":{
//       "providerId":"279",
//       "value":{
//             "value":0.0000,
//             "currency":{
//                   "code":643,
//                   "name":"RUB"
//                 }
//           },
//       "description":"комиссия не взимается",
//       "minAmount":10.00,
//       "maxAmount":1000000.00,
//       "limit":1000000.00,
//       "total":{
//             "value":15001.00,
//             "currency":{
//                   "code":643,
//                   "name":"RUB"
//                 }
//           },
//     },
//     "resultCode":"OK"
//}

@end

