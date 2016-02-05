//
//  TCSFeedbackType.h
//  TCSP2P
//
//  Created by Max Zhdanov on 21.08.13.
//  Copyright (c) 2013 “Tinkoff Credit Systems” Bank (closed joint-stock company). All rights reserved.
//

#import "TCSBaseObject.h"

@interface TCSFeedbackType : TCSBaseObject

@property (nonatomic, strong, readonly) NSString    * type;
@property (nonatomic, strong, readonly) NSString    * subject;

@end
