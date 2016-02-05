//
//  NSError+TCSNetworking.m
//  TCSiCore
//
//  Created by Andrey Ilskiy on 11/06/15.
//  Copyright (c) 2015 “Tinkoff Credit Systems” Bank (closed joint-stock company). All rights reserved.
//

#import "NSError+TCSNetworking.h"
#import "TCSAPIStrings.h"

@implementation NSError (TCSNetworking)

- (void)logToAPI
{
    NSDictionary * const userInfo = self.userInfo;

    NSError *error = nil;
    NSData * const jsonData = [NSJSONSerialization dataWithJSONObject:userInfo options:0 error:&error];

    NSParameterAssert(error == nil);
    if (error == nil) {
        NSString * const jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    }
}

@end
