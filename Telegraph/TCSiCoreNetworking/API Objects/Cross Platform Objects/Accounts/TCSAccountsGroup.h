//
//  TCSP2PGroup.h
//  TCSP2P
//
//  Created by a.v.kiselev on 31.07.13.
//  Copyright (c) 2013 “Tinkoff Credit Systems” Bank (closed joint-stock company). All rights reserved.
//

#import "TCSBaseObject.h"
#import "TCSAccount.h"

@interface TCSAccountsGroup : TCSBaseObject

@property (nonatomic, strong, readonly) NSString * name;
@property (nonatomic, strong, readonly) NSArray * accounts;

@end
