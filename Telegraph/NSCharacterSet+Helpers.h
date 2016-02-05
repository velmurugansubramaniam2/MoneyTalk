//
//  NSCharacterSet+Helpers.h
//  TCSiCore
//
//  Created by a.v.kiselev on 05/06/15.
//  Copyright (c) 2015 “Tinkoff Credit Systems” Bank (closed joint-stock company). All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSCharacterSet (Helpers)

- (void)printToConsole;
+ (NSCharacterSet *)characterSetAllExceptDecimalDigits;

@end
