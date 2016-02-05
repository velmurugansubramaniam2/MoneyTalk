//
//  TCSP2PCard.h
//  TCSP2P
//
//  Created by a.v.kiselev on 31.07.13.
//  Copyright (c) 2013 “Tinkoff Credit Systems” Bank (closed joint-stock company). All rights reserved.
//

#import "TCSBaseObject.h"
#import "TCSMillisecondsTimestamp.h"
#import "TCSLCSCardInfo.h"

@interface TCSCard : TCSBaseObject

@property (nonatomic, strong, readonly) NSString *name;
@property (nonatomic, strong, readonly) NSString *value;
@property (nonatomic, strong, readonly) NSString *statusCode;
@property (nonatomic, readonly) BOOL primary;
@property (nonatomic, readonly) BOOL cvcConfirmRequired;
@property (nonatomic, strong, readonly) NSString *identifier;
@property (nonatomic, strong, readonly) NSString *numberShort;
@property (nonatomic, strong, readonly) NSString *numberExtraShort;
@property (nonatomic, strong, readonly) TCSMillisecondsTimestamp *expiration;
@property (nonatomic, strong, readonly) TCSLCSCardInfo *lcsCardInfo;

@end
