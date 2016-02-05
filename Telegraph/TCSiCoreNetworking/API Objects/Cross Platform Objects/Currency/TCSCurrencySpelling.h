//
//  TCSCurrencySpelling.h
//  TCSP2P
//
//  Created by Gleb Ustimenko on 8/21/13.
//  Copyright (c) 2013 “Tinkoff Credit Systems” Bank (closed joint-stock company). All rights reserved.
//

#import "TCSBaseObject.h"

@interface TCSCurrencySpelling : TCSBaseObject

@property (nonatomic, strong, readonly) NSString *plural;
@property (nonatomic, strong, readonly) NSString *fullName;
@property (nonatomic, strong, readonly) NSString *shortMillion;
@property (nonatomic, strong, readonly) NSString *shortThousand;
@property (nonatomic, strong, readonly) NSString *shortName;

@end
