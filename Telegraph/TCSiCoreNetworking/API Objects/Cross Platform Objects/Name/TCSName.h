//
//  TCSName.h
//  TCSP2P
//
//  Created by a.v.kiselev on 13.08.13.
//  Copyright (c) 2013 “Tinkoff Credit Systems” Bank (closed joint-stock company). All rights reserved.
//

#import "TCSBaseObject.h"

@interface TCSName : TCSBaseObject

@property (nonatomic, strong) NSString * firstName;
@property (nonatomic, strong) NSString * lastName;
@property (nonatomic, strong) NSString * patronymic;
@property (nonatomic, strong, readonly) NSString * fullName;
@property (nonatomic, strong, readonly) NSString * firstLastName;
@property (nonatomic, strong, readonly) NSString * lastFirstName;

@end
