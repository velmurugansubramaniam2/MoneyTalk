//
//  TCSRequestInfo.m
//  TCSiCore
//
//  Created by Gleb Ustimenko on 04.08.14.
//  Copyright (c) 2014 “Tinkoff Credit Systems” Bank (closed joint-stock company). All rights reserved.
//

#import "TCSRequestInfo.h"

@implementation TCSRequestInfo

@synthesize url = _url;
@synthesize bytes = _bytes;

- (NSString *)description
{
    return [NSString stringWithFormat:@"\n\n Request info log URL: %@ \n %@ \n\n", self.url, [NSByteCountFormatter stringFromByteCount:[self.bytes integerValue] countStyle:NSByteCountFormatterCountStyleFile]];
}

@end
