//
//  TCSSingleton.h
//  TCSiCore
//
//  Created by Andrey Ilskiy on 25/08/14.
//  Copyright (c) 2014 “Tinkoff Credit Systems” Bank (closed joint-stock company). All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TCSSingleton : NSObject

+ (instancetype)sharedInstance;

@end
