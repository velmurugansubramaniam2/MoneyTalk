//
//  TCSPhoneNumber.h
//  TCSP2P
//
//  Created by a.v.kiselev on 15.10.13.
//  Copyright (c) 2013 “Tinkoff Credit Systems” Bank (closed joint-stock company). All rights reserved.
//

#import "TCSBaseObject.h"

@interface TCSPhoneNumber : TCSBaseObject

@property (nonatomic, readonly) NSNumber * countryCode;
@property (nonatomic, readonly) NSNumber * innerCode;
@property (nonatomic, readonly) NSString * number;

- (NSString *)forrmatedNumber;

@end
