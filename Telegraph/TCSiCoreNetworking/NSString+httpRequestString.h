//
//  NSString+httpRequestString.h
//  TCSiCore
//
//  Created by a.v.kiselev on 05/06/15.
//  Copyright (c) 2015 “Tinkoff Credit Systems” Bank (closed joint-stock company). All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (httpRequestString)

- (NSString *)stringWithServiceNameFromURLString;
- (NSString *)stringFromURLStringWithValueForParameter:(NSString *)parameter;

@end
