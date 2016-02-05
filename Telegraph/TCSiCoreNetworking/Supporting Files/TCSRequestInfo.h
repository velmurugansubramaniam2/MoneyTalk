//
//  TCSRequestInfo.h
//  TCSiCore
//
//  Created by Gleb Ustimenko on 04.08.14.
//  Copyright (c) 2014 “Tinkoff Credit Systems” Bank (closed joint-stock company). All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TCSRequestInfo : NSObject

@property (nonatomic, strong) NSString *url;
@property (nonatomic, strong) NSNumber *bytes;

@end
