//
//  TCSSession.h
//  TCSiCore
//
//  Created by a.v.kiselev on 14.02.14.
//  Copyright (c) 2014 “Tinkoff Credit Systems” Bank (closed joint-stock company). All rights reserved.
//

#import "TCSBaseObject.h"

@interface TCSSession : TCSBaseObject

@property (nonatomic, readonly) NSString *sessionId;
@property (nonatomic, readonly) NSNumber *sessionTimeout;
@property (nonatomic, readonly) NSTimeInterval sessionTimoutInSeconds;
@property (nonatomic, readonly) BOOL isNewUser;
@property (nonatomic, readonly, getter=isPinSet) BOOL pinSet;

@end
