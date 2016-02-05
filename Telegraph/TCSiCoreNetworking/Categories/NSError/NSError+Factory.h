//
//  NSError+Factory.h
//  card2card
//
//  Created by Zabelin Konstantin on 13.02.15.
//  Copyright (c) 2015 “Tinkoff Credit Systems” Bank (closed joint-stock company). All rights reserved.
//

#import <Foundation/Foundation.h>



@interface NSError (Factory)

+ (NSError *)errorWithCode:(NSInteger)code message:(NSString *)messag;
+ (NSError *)errorWithCode:(NSInteger)code;

@end
