//
//  NSString.h
//  TCSP2PiPhone
//
//  Created by a.v.kiselev on 17.04.13.
//  Copyright (c) 2013 “Tinkoff Credit Systems” Bank (closed joint-stock company). All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (Luhn)

+ (BOOL) luhnCheck:(NSString *)stringToTest;
@end
