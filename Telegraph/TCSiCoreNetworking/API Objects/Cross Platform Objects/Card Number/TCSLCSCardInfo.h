//
//  TCSLCSCardInfo.h
//  TCSiCore
//
//  Created by Max Zhdanov on 13.02.15.
//  Copyright (c) 2015 “Tinkoff Credit Systems” Bank (closed joint-stock company). All rights reserved.
//

#import "TCSBaseObject.h"

@interface TCSLCSCardInfo : TCSBaseObject

@property (nonatomic, strong, readonly) NSString *bankLogo;
@property (nonatomic, strong, readonly) NSString *bankName;
@property (nonatomic, strong, readonly) NSString *rusBankName;

@end
