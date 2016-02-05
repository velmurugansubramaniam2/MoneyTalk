//
//  TCSP2PDueDate.h
//  TCSP2P
//
//  Created by a.v.kiselev on 31.07.13.
//  Copyright (c) 2013 “Tinkoff Credit Systems” Bank (closed joint-stock company). All rights reserved.
//

#import "TCSBaseObject.h"

@interface TCSMillisecondsTimestamp : TCSBaseObject

@property (nonatomic, readonly) NSTimeInterval milliseconds;
@property (nonatomic, readonly) NSTimeInterval seconds;
@property (nonatomic, copy,readonly) NSDate *date;

@end
