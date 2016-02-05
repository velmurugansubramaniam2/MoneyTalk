//
//  NSString+encoding.h
//  TCSiCore
//
//  Created by a.v.kiselev on 08/06/15.
//  Copyright (c) 2015 “Tinkoff Credit Systems” Bank (closed joint-stock company). All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (encoding)

- (NSString *)encodeURL;

+ (NSStringEncoding)stringEncodingFromEncodingName:(NSString*)encodingName; //for example koi8-r, cp-1251, ...

@end
