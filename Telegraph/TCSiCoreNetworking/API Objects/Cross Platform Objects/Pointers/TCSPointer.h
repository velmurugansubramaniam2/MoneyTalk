//
//  TCSPointer.h
//  TCSP2P
//
//  Created by a.v.kiselev on 13.08.13.
//  Copyright (c) 2013 “Tinkoff Credit Systems” Bank (closed joint-stock company). All rights reserved.
//

#import "TCSBaseObject.h"
#import "TCSName.h"

@interface TCSPointer : TCSBaseObject

@property (nonatomic, strong, readonly) NSString *networkId;
@property (nonatomic, strong, readonly) NSString *networkAccountId;
@property (nonatomic, strong, readonly) TCSName *name;
@property (nonatomic, strong, readonly) NSString *photo;

@end
