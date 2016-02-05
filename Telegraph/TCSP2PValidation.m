//
//  TCSP2PValidation.m
//  TCSP2P
//
//  Created by a.v.kiselev on 12.08.13.
//  Copyright (c) 2013 “Tinkoff Credit Systems” Bank (closed joint-stock company). All rights reserved.
//

#import "TCSP2PValidation.h"

@implementation TCSP2PValidation

- (void)clearAllProperties
{

}

- (NSString *)maxLength
{
	return [_dictionary objectForKey:kMaxLength];
}

- (NSString *)regexp
{
	return [_dictionary objectForKey:kRegexp];
}

- (NSInteger)minLength
{
    return [[_dictionary objectForKey:kMinLength] integerValue];
}

@end
